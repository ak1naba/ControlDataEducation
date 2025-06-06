-- Создание БД
create database students;

create table student_statuses (
	id_status SERIAL PRIMARY KEY,
	status_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

create table profiles (
	id_profile SERIAL PRIMARY KEY,
	profile_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TYPE types_education AS ENUM ('Очная', 'Заочная', 'Очно-заочная');

create table students (
	id_student VARCHAR(25) PRIMARY KEY UNIQUE,
	student_name VARCHAR(255) NOT NULL,
	birthdate DATE NOT NULL,
	contact_number VARCHAR(20) NOT NULL
        CHECK (contact_number ~ '^\+7 \([0-9]{3}\) [0-9]{3} [0-9]{2} [0-9]{2}$'),
    address VARCHAR(255) NOT NULL,
	form_education types_education NOT NULL,
	status_id INTEGER NOT NULL,
	profile_id INTEGER NOT NULL,
	created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
)

-- Внешние ключи
ALTER TABLE students
ADD CONSTRAINT fk_student_status
FOREIGN KEY (status_id) REFERENCES student_statuses (id_status);

ALTER TABLE students
ADD CONSTRAINT fk_student_profile
FOREIGN KEY (profile_id) REFERENCES profiles (id_profile);

-- Вставка
INSERT into profiles (profile_name)
VALUES ('Информационные системы и технологии'),
('Прикладная информатика в экономике'), ('Экономика
предприятий и организаций');

INSERT into student_statuses (status_name)
VALUES ('обучается'), ('выпускник'), ('отчислен');

INSERT INTO students (id_student, student_name, birthdate, contact_number, address, form_education, status_id, profile_id)
VALUES
('Пиб-2024-128', 'Казанцева Анна Сергеевна', '2003-03-13', '+7 (932) 746 61 28', 'г.Пермь, ул. Ленина, 18-34', 'Очная', 1, 2),
('Эб-2023-118', 'Смирнова Екатерина Александровна', '2003-01-02', '+7 (922) 746 61 28', 'г.Пермь, ул. Луначарского, 18-34', 'Очная', 1, 3)


-- Вставка в дуюликаты таблиц
create table temp_student_statuses (
	id_status SERIAL PRIMARY KEY,
	status_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

insert into temp_student_statuses 
select * from student_statuses

create table temp_profiles (
	id_profile SERIAL PRIMARY KEY,
	profile_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

insert into temp_profiles 
select * from profiles

create table temp_students (
	id_student VARCHAR(25) PRIMARY KEY UNIQUE,
	student_name VARCHAR(255) NOT NULL,
	birthdate DATE NOT NULL,
	contact_number VARCHAR(20) NOT NULL
        CHECK (contact_number ~ '^\+7 \([0-9]{3}\) [0-9]{3} [0-9]{2} [0-9]{2}$'),
	form_education types_education NOT NULL,
	status_id INTEGER NULL,
	profile_id INTEGER NULL,
	created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
	address VARCHAR(255) NOT NULL
);

-- Обновленные внешние ключи

ALTER TABLE temp_students
ADD CONSTRAINT fk_student_status
FOREIGN KEY (status_id) REFERENCES temp_student_statuses (id_status)
ON DELETE SET NULL;

ALTER TABLE temp_students
ADD CONSTRAINT fk_student_profile
FOREIGN KEY (profile_id) REFERENCES temp_profiles (id_profile)
ON DELETE SET NULL;

INSERT into temp_students 
select * from students

-- Вставка новых статусов
INSERT INTO temp_student_statuses(
	status_name)
	VALUES ('академический отпуск'),
			('переведн в другой ВУЗ');

-- Результат выборки до обновления
SELECT
    temp_students.id_student,
    temp_students.student_name,
    temp_students.birthdate,
    temp_students.contact_number,
    temp_students.form_education,
    temp_students.status_id,
    temp_students.profile_id,
    temp_students.created_at,
    temp_students.updated_at,
    temp_students.address,
	temp_student_statuses.id_status,
	temp_student_statuses.status_name
FROM
    temp_students
JOIN
    temp_student_statuses
ON
    temp_students.status_id = temp_student_statuses.id_status;

-- Обновление 
UPDATE temp_students
SET status_id = (
    SELECT id_status
    FROM temp_student_statuses
    WHERE status_name = 'академический отпуск'
)
WHERE status_id = (
    SELECT id_status
    FROM temp_student_statuses
    WHERE status_name = 'обучается'
);
