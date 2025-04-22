-- Самый юный студент
SELECT
    students.id_student,
    students.student_name,
    students.birthdate,
    students.contact_number,
    students.form_education,
    students.status_id,
    students.created_at,
    students.updated_at,
    students.address
FROM students
ORDER BY age(now(), students.birthdate) ASC
LIMIT 1;

-- Стундент фамилия которого начинается с К
SELECT
    students.id_student,
    students.student_name,
    students.birthdate,
    students.contact_number,
    students.form_education,
    students.status_id,
    students.created_at,
    students.updated_at,
    students.address
FROM students
WHERE students.student_name LIKE 'К%'

-- Напишите запрос, который выведет в
-- обратном алфавитном порядке студентов, обучающихся на
-- очной форме и проживающих в городе Перми
SELECT
    students.id_student,
    students.student_name,
    students.birthdate,
    students.contact_number,
    students.form_education,
    students.status_id,
    students.created_at,
    students.updated_at,
    students.address
FROM students
WHERE students.address LIKE '%Пермь%'
ORDER BY  students.student_name ASC

-- Количество студентов в академе
SELECT Count(id_student) as "Стунденты в кадемическим отпуске"
FROM temp_students
WHERE status_id = (
    SELECT id_status
    FROM temp_student_statuses
    WHERE status_name = 'академисечкий отпуск'
);

-- Количестов студнетов по статусам
SELECT
    temp_student_statuses.status_name,
    COUNT(temp_students.id_student) AS student_count
FROM
    temp_students
JOIN
    temp_student_statuses ON temp_students.status_id = temp_student_statuses.id_status
GROUP BY
    temp_student_statuses.status_name
ORDER BY
    temp_student_statuses.status_name;

-- Студенты по направлению ИС
SELECT id_student, student_name, birthdate, contact_number, form_education, status_id, profile_id, created_at, updated_at, address
FROM temp_students
WHERE profile_id = (
    SELECT id_profile
    FROM temp_profiles
    WHERE profile_name = 'Информационные системы и технологии'
);

-- Сутденты по напрвлению экномика
SELECT id_student, student_name, birthdate, contact_number, form_education, status_id, profile_id, created_at, updated_at, address
FROM temp_students
WHERE profile_id = (
    SELECT id_profile
    FROM temp_profiles
    WHERE profile_name = 'Экономика предприятий и организаций'
);

-- Пустые направления
SELECT
    temp_profiles.id_profile,
    temp_profiles.profile_name
FROM
    temp_profiles
LEFT JOIN
    temp_students ON temp_profiles.id_profile = temp_students.profile_id
WHERE
    temp_students.profile_id IS NULL;


-- Декартово произвдение 
SELECT DISTINCT
    s1.profile_id AS profile_id_1,
    s2.profile_id AS profile_id_2
FROM
    students s1
JOIN
    students s2 ON s1.profile_id < s2.profile_id;
