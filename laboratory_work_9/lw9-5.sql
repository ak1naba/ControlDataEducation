--Задание 9.30: Проверка и удаление временной таблицы #S
DO $$
BEGIN
    -- Проверка наличия временной таблицы #S
    IF EXISTS (
        SELECT 1
        FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'temp_s'
          AND n.nspname = 'pg_temp_1' -- Схема для временных таблиц
    ) THEN
        -- Удаление временной таблицы, если она существует
        EXECUTE 'DROP TABLE IF EXISTS temp_s';
        RAISE NOTICE 'Временная таблица temp_s удалена.';
    ELSE
        RAISE NOTICE 'Временная таблица temp_s не существует.';
    END IF;
END $$;

--Задание 9.31: Создание временной таблицы #S
CREATE TEMP TABLE temp_s (
    id_status INT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    status_num INT
);

--Задание 9.32. Заполните таблицу #S данными из таблицы STUDENT_STATUS.
INSERT INTO temp_s (id_status, status_name)
SELECT id_status, status_name
FROM public.student_statuses;

-- Задание 9.33: Создание функции для подсчета студентов по статусу
CREATE OR REPLACE FUNCTION count_students_by_status(status_id_param INT)
RETURNS INT AS $$
DECLARE
    student_count INT;
BEGIN
    SELECT COUNT(*) INTO student_count
    FROM public.temp_students
    WHERE status_id = status_id_param;

    RETURN COALESCE(student_count, 0);
END;
$$ LANGUAGE plpgsql;

-- Задание 9.34: Заполнение столбца StatusNum в таблице #S
UPDATE temp_s
SET status_num = count_students_by_status(id_status);

-- Проверка результата
SELECT * FROM temp_s;

--Задание 9.36: Создание хранимой процедуры
CREATE OR REPLACE PROCEDURE process_student_profile(
    IN profile_name_param VARCHAR(100), 
    OUT student_count INT,
    OUT return_code INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Если входной параметр NULL, завершаем с кодом -1
    IF profile_name_param IS NULL THEN
        student_count := 0;
        return_code := -1;
        RETURN;
    END IF;

    -- Проверяем существование профиля
    IF EXISTS (SELECT 1 FROM public.profiles WHERE profile_name = profile_name_param) THEN
        -- Если профиль существует, считаем студентов
        SELECT COUNT(*) INTO student_count
        FROM public.temp_students
        WHERE profile_id = (SELECT profile_id FROM public.profiles WHERE profile_name = profile_name_param);

        return_code := 0;
    ELSE
        -- Если профиля нет, добавляем его
        INSERT INTO public.profiles (profile_name)
        VALUES (profile_name_param);

        student_count := 0;
        return_code := 1;
    END IF;
END;
$$;


--Задание 9.37: Проверка работы процедуры
-- Тест 1: NULL параметр
DO $$
DECLARE
    cnt INT;
    rc INT;
BEGIN
    CALL process_student_profile(NULL, cnt, rc);
    RAISE NOTICE 'Test 1: NULL parameter. Return code: %, Student count: %', rc, cnt;
END $$;

-- Тест 2: Существующий профиль
DO $$
DECLARE
    cnt INT;
    rc INT;
BEGIN
    CALL process_student_profile('Информационные системы', cnt, rc);
    RAISE NOTICE 'Test 2: Existing profile. Return code: %, Student count: %', rc, cnt;
END $$;

-- Тест 3: Несуществующий профиль
DO $$
DECLARE
    cnt INT;
    rc INT;
BEGIN
    CALL process_student_profile('Новый профиль', cnt, rc);
    RAISE NOTICE 'Test 3: New profile. Return code: %, Student count: %', rc, cnt;
END $$;




--Задание 9.38: Создание триггера для таблицы STUDENT
-- Создание триггера
CREATE OR REPLACE FUNCTION check_status_change()
RETURNS TRIGGER AS $$
DECLARE
    expelled_status_id INT;
    graduate_status_id INT;
BEGIN
    -- Получаем ID статусов "Отчислен" и "Выпускник"
    SELECT status_id INTO expelled_status_id
    FROM public.student_status
    WHERE status_name = 'Отчислен';

    SELECT status_id INTO graduate_status_id
    FROM public.student_status
    WHERE status_name = 'Выпускник';

    -- Проверяем изменение статуса с "Отчислен" на "Выпускник"
    IF OLD.status_id = expelled_status_id AND NEW.status_id = graduate_status_id THEN
        RAISE EXCEPTION 'Нельзя изменять статус студента с "Отчислен" на "Выпускник"';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер
CREATE TRIGGER trg_check_status_change
BEFORE UPDATE ON public.temp_students
FOR EACH ROW
EXECUTE FUNCTION check_status_change();

-- Тестирование триггера
BEGIN;
-- Попытка изменить статус с "Отчислен" на "Выпускник" (должна вызвать ошибку)
UPDATE public.temp_students
SET status_id = (SELECT status_id FROM public.student_status WHERE status_name = 'Выпускник')
WHERE id_student = 'ИСб-2023-118'
AND status_id = (SELECT status_id FROM public.student_status WHERE status_name = 'Отчислен');
-- Должна возникнуть ошибка и транзакция откатится
ROLLBACK;

-- Тест с несколькими записями (одна из которых нарушает правило)
BEGIN;
-- Создаем тестовые данные
INSERT INTO public.temp_students (id_student, student_name, status_id)
VALUES
    ('TEST1', 'Тестовый студент 1', (SELECT status_id FROM public.student_statuses WHERE status_name = 'Отчислен')),
    ('TEST2', 'Тестовый студент 2', (SELECT status_id FROM public.student_statuses WHERE status_name = 'Учится'));

-- Попытка изменить статус (одна запись нарушает правило)
UPDATE public.temp_students
SET status_id = (SELECT status_id FROM public.student_status WHERE status_name = 'Выпускник')
WHERE id_student IN ('TEST1', 'TEST2');
-- Должна возникнуть ошибка и транзакция откатится
ROLLBACK;

-- Удаляем тестовые данные
DELETE FROM public.temp_students WHERE id_student IN ('TEST1', 'TEST2');
END;

--9.39
-- Создаем функцию для DDL-триггера
CREATE OR REPLACE FUNCTION prevent_table_changes()
RETURNS EVENT_TRIGGER AS $$
DECLARE
    obj_record RECORD;
BEGIN
    -- Проверяем тип события
    IF tg_event IN ('drop_table', 'alter_table', 'drop_view', 'alter_view') THEN
        -- Получаем информацию об объекте
        FOR obj_record IN
            SELECT * FROM pg_event_trigger_ddl_commands()
        LOOP
            RAISE EXCEPTION 'Запрещено % %: %',
                CASE obj_record.command_tag
                    WHEN 'DROP TABLE' THEN 'удалять таблицу'
                    WHEN 'ALTER TABLE' THEN 'изменять таблицу'
                    WHEN 'DROP VIEW' THEN 'удалять представление'
                    WHEN 'ALTER VIEW' THEN 'изменять представление'
                END,
                obj_record.object_identity,
                obj_record.command_tag;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Создаем DDL-триггер
CREATE EVENT TRIGGER trg_prevent_table_changes
ON DDL_COMMAND_END
EXECUTE FUNCTION prevent_table_changes();

-- Тестирование DDL-триггера
-- Попытка удалить таблицу (должна вызвать ошибку)
-- DROP TABLE public.temp_students;

-- Попытка изменить таблицу (должна вызвать ошибку)
-- ALTER TABLE public.temp_students ADD COLUMN test_column INT;

-- Попытка удалить временную таблицу (должна пройти успешно)
DROP TABLE IF EXISTS temp_s;

-- Попытка создать таблицу (должна пройти успешно)
CREATE TABLE test_table (id INT);
DROP TABLE test_table;
