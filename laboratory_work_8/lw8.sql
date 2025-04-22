-- ФИО самого .ного студента
SELECT
    students.student_name
FROM students
ORDER BY age(now(), students.birthdate) ASC
LIMIT 1;

-- ФИО и направление подготовки
SELECT
    temp_students.student_name,
	temp_profiles.profile_name
FROM
    temp_students
JOIN
    temp_profiles
ON
    temp_students.profile_id = temp_profiles.id_profile;

-- Кол-во студентов по направлениям подготовки
SELECT
    temp_profiles.profile_name,
    COUNT(temp_students.id_student) AS student_count
FROM
    temp_students
JOIN
    temp_profiles ON temp_students.profile_id = temp_profiles.id_profile
GROUP BY
    temp_profiles.profile_name
ORDER BY
    temp_profiles.profile_name;

-- Изменение формы обучения как у другого сутдента
UPDATE temp_students
SET form_education = (
    SELECT form_education
    FROM temp_students
    WHERE id_student = 'Эб-2023-118'
)
WHERE id_student = 'Пиб-2024-128'


-- Изменеие экономистам формы обучения
UPDATE temp_students
SET form_education = 'Очно-заочная'
WHERE profile_id = (
    SELECT id_profile
    FROM temp_profiles
    WHERE profile_name = 'Экономика предприятий и организаций'
);

-- Вывод студентов наряду с самым юным
SELECT
    temp_students.student_name,
    temp_students.birthdate,
	(SELECT
    	CONCAT(temp_students.student_name, ' ', temp_students.birthdate)
	FROM temp_students
	ORDER BY age(now(), temp_students.birthdate) ASC
	LIMIT 1
	) as small_student
FROM temp_students
ORDER BY age(now(), temp_students.birthdate) DESC
LIMIT (SELECT COUNT(*) - 1 FROM temp_students);

-- Вывод студентов имеющих старших
SELECT
    temp_students.id_student,
    temp_students.student_name,
    temp_students.birthdate,
    temp_students.profile_id
FROM
    temp_students
WHERE
    EXISTS (
        SELECT 1
        FROM temp_students s2
        WHERE s2.profile_id = temp_students.profile_id
          AND s2.birthdate < temp_students.birthdate
    );



-- Операции с множественными операциями
select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate < '2005-01-01';
select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate > '1999-01-06';

-- Объединенеи
select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate < '2005-01-01'

union

select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate > '1999-01-06';

-- Перечесечение
select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate < '2005-01-01'

intersect

select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate > '1999-01-06';

-- Вычитание
select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate < '2005-01-01'

except

select temp_students.id_student,
		temp_students.student_name
from temp_students
where temp_students.birthdate > '1999-01-06';