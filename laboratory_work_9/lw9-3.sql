-- Задание 9.17. Обновите две записи о студентах в таблице
-- STUDENT одним оператором UPDATE так, чтобы одно из
-- изменений не могло быть произведено (транзакция должна
-- быть целиком откачена).

-- Начало транзакции
BEGIN;

UPDATE public.temp_students
SET form_education = CASE
                        WHEN id_student = 'ИСб-2023-118' THEN 'Очная' -- Корректное обновление
                        WHEN id_student = 'Эб-2023-118' THEN 'Вечерняя' -- Некорректное обновление
                      END
WHERE id_student IN ('ИСб-2023-118', 'Эб-2023-118');

-- Откат транзакции
ROLLBACK;

-- Задание 9.18. Оформите те же по сути изменения в виде
-- отдельных операторов, проверьте их работу.
-- СКИП
-- Начало транзакции


--Задание 9.19. Измените данные в таблице STUDENT так,
-- чтобы они были в первоначальном стоянии. Оформите
-- последовательность из одного оператора UPDATE и одного
-- оператора INSERT в виде именованной явной транзакции, поотдельности эти операторы должны выполняться успешно.
-- Транзакцию завершите откатом, проверьте результат.
BEGIN TRANSACTION restore_data;

-- Обновление данных в таблице STUDENT
UPDATE temp_students
SET StudentName = 'Иванов Иван Иванович',
    BirthDate = '2001-01-01',
    PhoneNumber = 1234567890,
    Address = 'ул. Ленина, д. 1, кв. 1',
    FormOfEducation = 'Очная',
    ProfileID = 1,
    StatusID = 1
WHERE StudentId = 'ИСб-2023-118';

-- Вставка данных в таблицу STUDENT
INSERT INTO temp_students (StudentId, StudentName, BirthDate, PhoneNumber, Address, FormOfEducation, ProfileID, StatusID)
VALUES ('Эб-2023-118', 'Петров Петр Петрович', '2002-02-02', '+7 (999) 111 22 33', 'ул. Пушкина, д. 2, кв. 2', 'Очно-заочная', 2, 2);

-- Откат транзакции
ROLLBACK TRANSACTION restore_data;

-- Задание 9.20. Между операторами UPDATE и INSERT
-- кода транзакции, созданной на предыдущем шаге, поставьте
-- оператор SELECT, выбирающий все записи из
-- соответствующей таблицы. После отката транзакции
-- выполните аналогичный SELECT. Убедитесь, что внутренний
-- SELECT «видит» производимые изменения, т.е. внутри
-- транзакции эти данные доступны.

BEGIN;

-- Обновление записи
UPDATE public.temp_students
SET form_education = 'Очная'
WHERE id_student = 'ИСб-2023-118';

-- Вставка корректной записи 
INSERT INTO public.temp_students (id_student, student_name, birthdate, contact_number, form_education, status_id, profile_id, created_at, updated_at, address)
VALUES ('ИСб-2023-125', 'New Student', '2002-01-01', '+7 (923) 456 78 90', 'Очная', 1, 1, NOW(), NOW(), 'Address');

-- Выборка данных внутри транзакции
SELECT * FROM public.temp_students;

-- Откат транзакции
ROLLBACK;

-- Выборка данных после отката транзакции
SELECT * FROM public.temp_students;


-- Задание 9.21. Дополните транзакцию точкой
-- сохранения, установленной после внутреннего SELECT;
-- выполните откат до точки сохранения (в ROLLBACK TRAN
-- указываете имя точки сохранения, а не транзакции)
BEGIN;

SELECT * FROM public.temp_students WHERE id_student = 'ИСб-2023-118';

-- Установка точки сохранения после внутреннего SELECT
SAVEPOINT after_select;

-- Обновление данных в таблице temp_students
UPDATE public.temp_students
SET student_name = 'Иванов Иван Иванович',
    birthdate = '2001-01-01',
    contact_number = '+7 (999) 111 22 33',
    address = 'ул. Ленина, д. 1, кв. 1',
    form_education = 'Очная',
    profile_id = 1,
    status_id = 1
WHERE id_student = 'ИСб-2023-118';

-- Вставка данных в таблицу temp_students
INSERT INTO public.temp_students (id_student, student_name, birthdate, contact_number, address, form_education, profile_id, status_id)
VALUES ('Эб-2023-119', 'Петров Петр Петрович', '2002-02-02', '+7 (999) 222 33 44', 'ул. Пушкина, д. 2, кв. 2', 'Очно-заочная', 2, 2);

-- Откат до точки сохранения
ROLLBACK TO SAVEPOINT after_select;

-- Завершение транзакции
COMMIT;

-- 9.23 скип