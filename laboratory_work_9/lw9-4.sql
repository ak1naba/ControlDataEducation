-- Задание 9.24. Объявите три целочисленные переменные.
-- Первой из них присвойте значение, равное количеству
-- студентов в таблице STUDENT, второй – минимальный года
-- рождения (самые старшие студенты); третьей – максимальный
-- (самые младшие студенты).
-- Выведите оператором print строку «В таблице Student N
-- студентов, родившихся с X по Y годы.», где вместо N, X и Y
-- подставлены соответствующие значения. Переменным
-- присваивайте значения по отдельности в операторах SET. При
-- формировании выводимой строки не забудьте про
-- преобразование типов. Случай, когда ни у студентов не указан
-- год рождения мы не рассматриваем.
DO $$
DECLARE
    student_count INT;
    min_birth_year INT;
    max_birth_year INT;
BEGIN
    SELECT COUNT(*) INTO student_count FROM public.temp_students;

    SELECT EXTRACT(YEAR FROM MIN(birthdate)) INTO min_birth_year FROM public.temp_students;

    SELECT EXTRACT(YEAR FROM MAX(birthdate)) INTO max_birth_year FROM public.temp_students;

    RAISE NOTICE 'В таблице Student % студентов, родившихся с % по % годы.', student_count, min_birth_year, max_birth_year;
END $$;

-- Задание 9.25. Перепишите результат выполнения
-- задания 9.24 таким образом, чтобы все три переменные
-- получали значения в результате выполнения одного оператора
SELECT
DO $$
DECLARE
    student_count INT;
    min_birth_year INT;
    max_birth_year INT;
BEGIN
    SELECT COUNT(*),
		EXTRACT(YEAR FROM MIN(birthdate)),
		EXTRACT(YEAR FROM MAX(birthdate))
	INTO student_count,
		 min_birth_year,
		 max_birth_year
	FROM public.temp_students;

    RAISE NOTICE 'В таблице Student % студентов, родившихся с % по % годы.', student_count, min_birth_year, max_birth_year;
END $$;

-- Задание 9.26. Основываясь на полученном при
-- выполнении заданий 9.24 и 9.25 результате, напишите код,
-- выводящий в цикле по годам от минимального к
-- максимальному студентов, родившихся в соответствующий
-- год (на каждый год выполняется отдельный SELECT,
-- возвращающий только студентов, родившихся в этом году)
DO $$
DECLARE
    min_birth_year INT;
    max_birth_year INT;
    current_year INT;
    student_record RECORD;
BEGIN
    -- Присвоение значения второй переменной (минимальный год рождения)
    SELECT EXTRACT(YEAR FROM MIN(birthdate)) INTO min_birth_year FROM public.temp_students;

    -- Присвоение значения третьей переменной (максимальный год рождения)
    SELECT EXTRACT(YEAR FROM MAX(birthdate)) INTO max_birth_year FROM public.temp_students;

    -- Цикл по годам от минимального до максимального
    FOR current_year IN min_birth_year..max_birth_year LOOP
        -- Вывод студентов, родившихся в текущем году
        RAISE NOTICE 'Студенты, родившиеся в % год:', current_year;
        FOR student_record IN
            SELECT id_student, student_name, birthdate, contact_number, form_education, status_id, profile_id, created_at, updated_at, address
            FROM public.temp_students
            WHERE EXTRACT(YEAR FROM birthdate) = current_year
        LOOP
            RAISE NOTICE '%', student_record;
        END LOOP;
    END LOOP;
END $$;

-- 9.27
DO $$
DECLARE
    min_birth_year INT;
    max_birth_year INT;
    current_year INT;
    student_record RECORD;
    skip_year INT := 2003; -- Год, для которого SELECT не будет выполняться
BEGIN
    SELECT EXTRACT(YEAR FROM MIN(birthdate)) INTO min_birth_year FROM public.temp_students;

    SELECT EXTRACT(YEAR FROM MAX(birthdate)) INTO max_birth_year FROM public.temp_students;

    FOR current_year IN min_birth_year..max_birth_year LOOP
        -- Пропуск выполнения SELECT для заданного года
        IF current_year = skip_year THEN
            CONTINUE;
        END IF;

        -- Вывод студентов, родившихся в текущем году
        RAISE NOTICE 'Студенты, родившиеся в % год:', current_year;
        FOR student_record IN
            SELECT id_student, student_name, birthdate, contact_number, form_education, status_id, profile_id, created_at, updated_at, address
            FROM public.temp_students
            WHERE EXTRACT(YEAR FROM birthdate) = current_year
        LOOP
            RAISE NOTICE '%', student_record;
        END LOOP;
    END LOOP;
END $$;

--9.28

-- Создание временной таблицы @STUDENTS
CREATE TEMP TABLE temp_students (
    id_student VARCHAR(15),
    student_name VARCHAR(100),
    birthdate DATE,
    contact_number VARCHAR(20),
    form_education TEXT,  -- Изменяем тип на TEXT
    status_id INT,
    profile_id INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    address VARCHAR(255)
);

-- Заполнение временной таблицы @STUDENTS данными из таблицы STUDENT
INSERT INTO temp_students
SELECT
    id_student,
    student_name,
    birthdate,
    contact_number,
    CASE
        WHEN form_education = 'Очная' THEN 'Очная'
        WHEN form_education IS NULL THEN 'формы обучения нет'
        ELSE 'форма обучения не очная'
    END AS form_education,
    status_id,
    profile_id,
    created_at,
    updated_at,
    address
FROM public.temp_students;

-- Создание переменной для хранения количества записей
DO $$
DECLARE
    student_count INT;
BEGIN
    SELECT COUNT(*) INTO student_count FROM temp_students;
    RAISE NOTICE 'Количество студентов во временной таблице: %', student_count;
END $$;

SELECT * FROM temp_students;


