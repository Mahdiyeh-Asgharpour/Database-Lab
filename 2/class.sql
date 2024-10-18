CREATE TABLE schools (
	school_id SERIAL,
	school_name VARCHAR(100),
	address VARCHAR(255),
	city VARCHAR(50),
	state VARCHAR(50),
	zip_code VARCHAR(10),
	school_type VARCHAR(50),
	established_year INT,
	phone_number VARCHAR(15),
	email VARCHAR(100)
);
ALTER TABLE schools RENAME TO
school;
ALTER TABLE school ADD COLUMN
students_number INT;
ALTER TABLE school DROP COLUMN
state;
ALTER TABLE school RENAME COLUMN
zip_code TO postal_code;
ALTER TABLE school ALTER COLUMN school_id
SET DATA TYPE INT;
ALTER TABLE school ALTER COLUMN
city SET DEFAULT 'Babol';
ALTER TABLE school ALTER COLUMN
city DROP DEFAULT;
ALTER TABLE school ALTER COLUMN
school_name SET NOT NULL;
ALTER TABLE school ALTER COLUMN
school_name DROP NOT NULL;
ALTER TABLE school
ADD CONSTRAINT unique_school_name UNIQUE (school_name);
ALTER TABLE school
ADD CONSTRAINT check_school_type CHECK
	(school_type IN ('Public','Private'));
INSERT INTO school
(school_id,school_name,address,city,postal_code,school_type,established_year,phone_number,email)
VALUES
	(1,'zabihi','kiakola square','Babol','123456',
	'Public',1954,'123-456-7890','zabihi@school.edu'),
	(2,'parvin','pasdaran','Sari','123789',
	'Public',1936,'987-654-3210','parvin@school.edu'),
	(3,'alghadir','ferdows 4th','Babol','789456',
	'Private',2001,'555-123-4567','alghadir@school.edu');