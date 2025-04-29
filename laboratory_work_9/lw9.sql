--Просмотр информации о табличных пространствах
SELECT * FROM pg_tablespace;

--9.1 Просмотр информации о файлах базы данных
SELECT
    datname AS database_name,
    pg_tablespace_location(dattablespace) AS tablespace_location
FROM
    pg_database;

--Просмотр информации о файлах таблиц
SELECT
    relname AS table_name,
    pg_relation_filepath(oid) AS file_path
FROM
    pg_class
WHERE
    relkind = 'r'; 

-- 9.2 Напишите запрос, выводящий
-- расположение файла (файлов) журнала на диске. Чтобы
-- отобрать нужные записи, используйте условие на столбец
SELECT setting
FROM pg_settings
WHERE name = 'data_directory';

-- Задание 9.3. Напишите запрос, подсчитывающий
-- количество файловых групп базы данных, доступных на
-- чтение и запись
SELECT COUNT(*)
FROM pg_tablespace
WHERE spcname NOT IN ('pg_default', 'pg_global');

--Задание 9.4. Используя системные представления sys.schemas, sys.tables, sys.views, получите сведения о схемах, таблицах и представлениях, определенных в базе данных STUDENTS.
-- Схемы
SELECT nspname
FROM pg_namespace
WHERE nspname NOT IN ('pg_catalog', 'information_schema');

-- Таблицы
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public';

-- Представления
SELECT viewname
FROM pg_views
WHERE schemaname = 'public';

-- Задание 9.5. Создайте новую схему. Проверьте, что
-- данные о созданной схеме отображаются в представлении
-- sys.schemas.
CREATE SCHEMA newsch;
-- Проверка
SELECT nspname
FROM pg_namespace
WHERE nspname = 'newsch';

--Задание 9.6. В схеме newsch создайте представление vSTUDENT, содержащее один столбец, в котором перечислены ФИО студентов из таблицы STUDENT. Посмотрите данные из представления. Не забудьте, что newsch не является схемой по умолчанию, поэтому надо указывать имя представления вместе с схемой.
CREATE VIEW newsch.vSTUDENT AS
SELECT student_name
FROM students;

-- Просмотр данных
SELECT *
FROM newsch.vSTUDENT;

--Задание 9.7. Используя рассмотренные ранее системные представления, посчитайте количество представлений в схеме newsch.
SELECT COUNT(*)
FROM pg_views
WHERE schemaname = 'newsch'