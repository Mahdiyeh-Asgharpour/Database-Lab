CREATE TABLE assassins(
	assassin_id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	weapon VARCHAR(100),
	skill_level INT,
	age INT,
	location VARCHAR(100),
	is_legendary BOOLEAN
);
ALTER TABLE assassins DROP COLUMN
age;
ALTER TABLE assassins ADD COLUMN
famous_quote VARCHAR(255);
ALTER TABLE assassins
ADD CONSTRAINT check_skill_level CHECK
	(skill_level>0);
ALTER TABLE assassins DROP COLUMN
is_legendary;
ALTER TABLE assassins ADD COLUMN
idol VARCHAR(255);
INSERT INTO assassins (name, weapon, skill_level, location, famous_quote, idol)
VALUES
('Shay Cormac', 'Rifle', 8, 'New York', 'Never compromise the Brotherhood', 'Haytham Kenway'),
('Bayek of Siwa', 'Sickle Sword', 7, 'Egypt', 'I fight for the ones I love', 'Amunet'),
('Kassandra', 'Spear of Leonidas', 9, 'Sparta', 'I will fight for justice', 'Leonidas');
select * from assassins;