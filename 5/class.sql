CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock INTEGER NOT NULL
);


CREATE TABLE inventory_audit (
    audit_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    operation VARCHAR(10) NOT NULL,
    old_stock INTEGER,
    new_stock INTEGER,
    changed_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT SESSION_USER
);


CREATE TABLE participants (
    participant_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE,
    bonus_points INTEGER DEFAULT 0
);

CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) UNIQUE NOT NULL,
    team_leader_id INTEGER UNIQUE,
    registration_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (team_leader_id) REFERENCES participants(participant_id)
);

CREATE TABLE registrations (
    registration_id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    UNIQUE (participant_id, team_id)
);

CREATE TABLE scores (
    score_id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL,
    challenge_name VARCHAR(100) NOT NULL,
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    submission_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id)
);

CREATE TABLE audit_log (
    audit_id SERIAL PRIMARY KEY,
    operation VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    affected_row INTEGER NOT NULL,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(50) DEFAULT SESSION_USER
);

CREATE TABLE team_scores (
    team_id INTEGER PRIMARY KEY,
    total_score INTEGER DEFAULT 0,
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE high_score_audit (
    audit_id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    challenge_name VARCHAR(100) NOT NULL,
    score INTEGER NOT NULL,
    achievement_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id)
);
INSERT INTO participants (first_name, last_name, email)
VALUES
('Alice', 'Johnson', 'alice.johnson@example.com'),
('Bob', 'Smith', 'bob.smith@example.com'),
('Charlie', 'Lee', 'charlie.lee@example.com'),
('Diana', 'Prince', 'diana.prince@example.com'),
('Ethan', 'Hunt', 'ethan.hunt@example.com'),
('Fiona', 'Gallagher', 'fiona.gallagher@example.com');

INSERT INTO teams (team_name, team_leader_id)
VALUES
('Code Warriors', 1),
('Bug Busters', 4);

INSERT INTO registrations (participant_id, team_id)
VALUES
(1, 1), 
(2, 1), 
(3, 2), 
(4, 2), 
(5, 1), 
(6, 2); 

INSERT INTO team_scores (team_id, total_score)
VALUES
(1, 0),
(2, 0);

INSERT INTO scores (participant_id, challenge_name, score)
VALUES
(1, 'Algorithm Challenge', 85),
(2, 'Debugging Challenge', 90),
(3, 'UI Design Challenge', 75),
(4, 'Algorithm Challenge', 95),
(5, 'Debugging Challenge', 80),
(6, 'UI Design Challenge', 70);

create procedure add_new_book(
	in p_title varchar,
	in p_author varchar,
	in p_price numeric,
	in p_stock integer
)
language plpgsql
as $$
begin
	insert into books (title,author,price,stock)
	values(p_title,p_author,p_price,p_stock);
	raise notice 'Book "%" by % added successfully.',p_title,p_author;
end;
$$;

create procedure update_book_stock(
	in p_book_id integer,
	in p_new_stock integer
)
language plpgsql
as $$
begin
	update books
	set stock = p_new_stock
	where book_id=p_book_id;
end;
$$;

call add_new_book ('The Best Programmer','Andrew Hunt',39.99,50);

drop procedure add_new_book,update_book_stock;

create or replace function add_new_book(
	p_title varchar,
	p_author varchar,
	p_price numeric,
	p_stock integer
) returns integer
language plpgsql
as $$
declare
	new_book_id integer;
begin
	insert into books (title,author,price,stock)
	values (p_title,p_author,p_price,p_stock)
	returning book_id into new_book_id;

	return new_book_id;
end;
$$;

create or replace function update_book_stock(
	p_book_id integer,
	p_new_stock integer
) returns boolean
language plpgsql
as $$
begin
	update books
	set stock=p_new_stock
	where book_id=p_book_id;
end;
$$;

select add_new_book('The Best Programmer','Andrew Hunt',39.99,50) as add_new_id;

drop function add_new_book, update_book_stock;

create or replace function prevent_negative_stock()
returns trigger
language plpgsql
as $$
begin
	if new.stock<0 then
		raise exception 'Stock cannot be negative. Attempted to set stock to % for book_id %.', new.stock,new.book_id;
	end if;
	return new;
end;
$$;

create or replace function log_inventory_changes()
returns trigger
language plpgsql
as $$
begin
	if TG_OP='INSERT' then
		insert into inventory_audit(book_id,operation,new_stock)
		values (new.book_id,TG_OP,new.stock);
	elsif TG_OP= 'UPDATE' then
		insert into inventory_audit (book_id,operation,old_stock,new_stock)
		values (new.book_id,TG_OP,old.stock,new.stock);
	elseif TG_OP='DELETE' then
		insert into inventory_audit (book_id,operation,old_stock)
		values (old.book_id,TG_OP,old.stock);
	end if;
	return null;
end;
$$;

create trigger trg_prevent_negative_stock
before insert or update on books
for each row
execute function prevent_negative_stock();


insert into books (title,author,price,stock)
values ('Book 2','Author Unknown',20.00,-5);

