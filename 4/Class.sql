CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);


CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT REFERENCES departments(department_id),
    salary DECIMAL(10, 2) NOT NULL
);

CREATE TABLE faculties (
    faculty_id SERIAL PRIMARY KEY,
    faculty_name VARCHAR(100) NOT NULL
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    faculty_id INT REFERENCES faculties(faculty_id),
    salary DECIMAL(10, 2) NOT NULL
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
    professor_id INT REFERENCES professors(professor_id)
);
INSERT INTO departments (department_name) VALUES
('HR'),
('Finance'),
('IT'),
('Marketing'),
('Sales');


INSERT INTO employees (first_name, last_name, department_id, salary) VALUES
('John', 'Doe', 1, 4000),
('Jane', 'Smith', 2, 5000),
('Sam', 'Johnson', 1, 6000),
('Chris', 'Lee', 2, 7000),
('Emma', 'Brown', 3, 5500),
('Liam', 'Davis', 3, 6200),
('Sophia', 'Wilson', 4, 4800),
('Mia', 'Martinez', 5, 4500),
('Oliver', 'Garcia', 4, 5300),
('Lucas', 'Clark', 1, 3900),
('Charlotte', 'Lopez', 2, 5200),
('Amelia', 'Gonzalez', 5, 6300),
('Harper', 'Lewis', 4, 4700),
('Evelyn', 'Young', 3, 5900),
('James', 'Allen', 1, 4100),
('William', 'Scott', 2, 5400),
('Benjamin', 'Walker', 3, 5600),
('Elijah', 'Robinson', 4, 4900),
('Mason', 'Rodriguez', 5, 5700),
('Ella', 'Green', 1, 4300),
('Avery', 'Hall', 2, 5800),
('Sofia', 'Perez', 3, 6100),
('Isabella', 'Hill', 5, 4400),
('Ethan', 'Baker', 4, 5200),
('Alexander', 'Carter', 1, 4600),
('Sebastian', 'King', 2, 6500),
('David', 'Wright', 3, 4700),
('Daniel', 'Torres', 5, 6100),
('Logan', 'Evans', 1, 4300),
('Lucas', 'Hernandez', 4, 5300),
('Aiden', 'Cruz', 2, 4900),
('Grace', 'Cooper', 5, 4500),
('Chloe', 'Reed', 1, 4800),
('Zoe', 'Morris', 2, 4700),
('Nora', 'Murphy', 3, 5400),
('Stella', 'Rivera', 5, 5600),
('Hannah', 'Cook', 4, 5100),
('Levi', 'Bell', 1, 4900),
('Owen', 'Gomez', 2, 6100),
('Jack', 'Kelly', 3, 5800),
('Luke', 'Howard', 5, 5900),
('Avery', 'Ward', 4, 4700),
('Mila', 'Cox', 1, 4600),
('Scarlett', 'Diaz', 2, 5100),
('Abigail', 'Flores', 3, 5600),
('Victoria', 'Reyes', 4, 5300),
('Madison', 'Rogers', 5, 6000),
('Elizabeth', 'James', 1, 4200),
('Lily', 'Stewart', 3, 5500),
('Aria', 'Ross', 4, 4900),
('Emily', 'Patterson', 5, 5700);


INSERT INTO faculties (faculty_name)
VALUES
('Computer Science'),
('Mathematics'),
('Physics'),
('Engineering'),
('Literature'),
('History');


INSERT INTO professors (first_name, last_name, faculty_id, salary)
VALUES
('John', 'Doe', 1, 7500.00),  
('Jane', 'Smith', 2, 8000.00), 
('Emily', 'Johnson', 1, 7200.00),
('Robert', 'Williams', 3, 6800.00), 
('Michael', 'Brown', 4, 8500.00), 
('Sarah', 'Davis', 5, 6000.00), 
('David', 'Wilson', 6, 7000.00); 


INSERT INTO courses (course_name, credits, professor_id)
VALUES
('Introduction to Algorithms', 3, 1),  
('Calculus I', 4, 2),                  
('Data Structures', 3, 1),             
('Physics 101', 4, 4),                 
('Thermodynamics', 3, 5),              
('Shakespearean Literature', 3, 6),    
('World History', 4, 7);               

select e.first_name,e.last_name,d.department_name,e.salary
from employees e
join departments d on e.department_id = d.department_id;

select first_name , salary
from employees 
where salary >(select AVG(salary) from employees);

select e.first_name , e.last_name , e.salary,
	(select COUNT(*) from employees e2 
	where e2.department_id=e.department_id) as department_count
from employees e;

select first_name , last_name , salary
from employees e1
where salary >(select AVG(salary) 
				from employees e2
				where e1.department_id=e2.department_id);
select department_id
from departments d
where EXISTS (select 1
			  from employees e
			  where e.department_id= d.department_id); 
select first_name , last_name
from employees
where department_id IN (select department_id from departments
 where department_name in ('HR','Finance'));

select first_name , last_name , salary
from employees
where salary>ANY(select salary from employees where department_id=2);

select d.department_name , sum(e.salary) as total_salary
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name;

select d.department_name , avg(e.salary) as total_salary
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name;

select d.department_name,
	case
		when e.salary < 4000 then 'Low'
		when e.salary between 4000 and 6000 then 'Medium'
		else 'High'
	end as salary_range,
	count(e.employee_id) as employee_count
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name,salary_range;

select d.department_name , avg(e.salary) as avg_salary
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name
having avg(e.salary)>5500;

select d.department_name , sum(e.salary) as total_salary
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name
order by total_salary desc;

select d.department_name , count(e.employee_id) as employee_count
from employees e
join departments d on e.department_id=d.department_id
group by d.department_name
having count(e.employee_id)>10;

begin;
insert into departments (department_name)
values ('Research');
insert into employees (first_name,last_name,department_id,salary)
values ('Alice','Johnson',(select department_id from departments where department_name='Research'),6000);
insert into employees (first_name,last_name,department_id,salary)
values ('Bob','Smith',(select department_id from departments where department_name='Research'),5500);
commit;

