--Просмотр информации о табличных пространствах
SELECT * FROM pg_tablespace;

--Просмотр информации о файлах базы данных
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
