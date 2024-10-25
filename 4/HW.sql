CREATE INDEX idx_last_name
ON employees (last_name);
CREATE VIEW employee_department_view AS
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;
SELECT * FROM employee_department_view;
SELECT * FROM employees WHERE last_name = 'Smith';
---------------------*---------------------------
CREATE VIEW professors_faculty AS
SELECT p.first_name, p.last_name, f.faculty_name, SUM(c.credits) AS total_credits
FROM professors p
JOIN courses c ON p.professor_id = c.professor_id
JOIN faculties f ON p.faculty_id = f.faculty_id
GROUP BY p.first_name, p.last_name, f.faculty_name
HAVING COUNT(distinct f.faculty_name) > 1;
SELECT * FROM professors_faculty;


BEGIN;
UPDATE courses SET professor_id = 1 WHERE course_id = 1;
DO $$
BEGIN
    IF (SELECT f.faculty_id FROM faculties f 
        JOIN professors p ON f.faculty_id = p.faculty_id 
        JOIN courses c ON p.professor_id = c.professor_id 
        WHERE c.course_id = 1) != (SELECT p.faculty_id FROM professors p WHERE professor_id = 1) THEN
        RAISE EXCEPTION 'Error';
    END IF;
END $$;
COMMIT;
ROLLBACK;


CREATE INDEX idx_courses_professor ON courses(course_name, professor_id);


SELECT p.first_name, p.last_name, AVG(c.credits) AS average_credits
FROM professors p
JOIN courses c ON p.professor_id = c.professor_id
GROUP BY p.first_name, p.last_name
HAVING AVG(c.credits) > 4;

SELECT f.faculty_name, p.first_name, p.last_name, p.salary
FROM professors p
JOIN faculties f ON p.faculty_id = f.faculty_id
WHERE p.salary = (SELECT MAX(salary) FROM professors WHERE faculty_id = f.faculty_id);

SELECT p.first_name, p.last_name
FROM professors p
LEFT JOIN courses c ON p.professor_id = c.professor_id
WHERE c.professor_id IS NULL;

WITH max_credits AS (
    SELECT credits_per_professor.faculty_id, MAX(credits_per_professor.total_credits) AS max_total_credits
    FROM (
        SELECT p2.faculty_id, p2.professor_id, SUM(c.credits) AS total_credits
        FROM professors p2
        JOIN courses c ON p2.professor_id = c.professor_id
        GROUP BY p2.faculty_id, p2.professor_id
    ) AS credits_per_professor
    GROUP BY credits_per_professor.faculty_id
)
SELECT f.faculty_name, p.first_name, p.last_name, SUM(c.credits) AS total_credits
FROM professors p
JOIN courses c ON p.professor_id = c.professor_id
JOIN faculties f ON p.faculty_id = f.faculty_id
JOIN max_credits mc ON p.faculty_id = mc.faculty_id
GROUP BY f.faculty_name, p.first_name, p.last_name, mc.max_total_credits
HAVING SUM(c.credits) = mc.max_total_credits;


SELECT f.faculty_name
FROM faculties f
LEFT JOIN professors p ON f.faculty_id = p.faculty_id
LEFT JOIN courses c ON p.professor_id = c.professor_id
WHERE c.course_id IS NULL;




