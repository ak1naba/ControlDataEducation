--Задание 9.9. В окне Object Explorer (Обозреватель
-- объектов) откройте список учетных записей (logins). На
-- выполнение каких серверных ролей авторизована
-- 81
-- используемая вами учетная запись? В каких базах данных
-- сервера вашей учетной записи сопоставлены пользователи?
-- На выполнение каких ролей они авторизованы?
SELECT rolname
FROM pg_roles
WHERE pg_has_role(current_user, oid, 'USAGE');

-- Задание 9.10. Создайте новую базу данных Newbase.
-- Откройте список пользователей и ролей. Убедитесь, что
-- учетная запись, под которой вы работаете, сопоставлена
-- пользователю dbo, авторизованному на роль db_owner.
CREATE DATABASE Newbase;

-- Проверьте роли
SELECT rolname
FROM pg_roles
WHERE pg_has_role(current_user, oid, 'USAGE');


-- Задание 9.11. Используя приведенный ниже скрипт,
-- создайте в базе данных таблицы. Обратите внимание, что
-- приведенный скрипт создает не только три таблицы, но и
-- схему Stud с помощью оператора CREATE SCHEME.
CREATE SCHEMA Stud;

-- Создание таблицы STUDENT_STATUS в схеме public
CREATE TABLE public.STUDENT_STATUS (
    StatusID serial PRIMARY KEY,
    StatusName varchar(50) NOT NULL UNIQUE
);

-- Создание таблицы PROFILE в схеме public
CREATE TABLE public.PROFILE (
    ProfileID serial PRIMARY KEY,
    ProfileName varchar(50) NOT NULL UNIQUE
);

-- Создание таблицы STUDENT в схеме Stud
CREATE TABLE Stud.STUDENT (
    StudentId varchar(15) PRIMARY KEY,
    StudentName varchar(100) NOT NULL,
    BirthDate date,
    PhoneNumber bigint NOT NULL,
    Address varchar(255),
    FormOfEducation varchar(20) NOT NULL,
    ProfileID int REFERENCES public.PROFILE(ProfileID),
    StatusID int REFERENCES public.STUDENT_STATUS(StatusID)
);

-- Задание 9.13. Создайте пользователя в вашей базе
-- данных (в примерах ниже имя пользователя – «ns»), в качестве
-- схемы по умолчанию выберите public (dbo mssql). 
CREATE USER ns WITH PASSWORD 'your_password';
ALTER ROLE ns SET search_path TO public;
SHOW search_path;

-- Задание 9.14. Добавьте этого пользователя в роль
-- db_datareader. Это можно сделать через графический
-- интерфейс или с помощью системной хранимой процедуры
-- sp_addrolemember, первым параметром которой будет имя
-- роли, а вторым – имя пользователя
CREATE ROLE db_datareader;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO db_datareader;

GRANT SELECT ON ALL TABLES IN SCHEMA Stud TO db_datareader;

GRANT db_datareader TO ns;

-- Задание 9.15. Создайте новую роль уровня базы данных
-- и добавьте ей разрешение на удаление (DELETE), изменение
-- (UPDATE) и добавление данных (INSERT) в объекты схемы
-- Stud. Добавьте нашего пользователя к этой роли. 

CREATE ROLE db_datawriter;
GRANT DELETE, UPDATE, INSERT ON ALL TABLES IN SCHEMA Stud TO db_datawriter;
GRANT db_datawriter TO ns;

