call update_book_stock(p_book_id := 1, p_new_stock := 50);
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
	return p_book_id;
end;
$$;
SELECT update_book_stock(1, 20) as p_book_id;
create or replace function prevent_negative_price()
returns trigger
language plpgsql
as $$
begin
	if new.price<0 then
		raise exception 'Stock cannot be negative. Attempted to set stock to % for book_id %.', new.stock,new.book_id;
	end if;
	return new;
end;
$$;
--page 20 answer:
--ERROR:  Stock cannot be negative. Attempted to set stock to -5 for book_id 3.
--CONTEXT:  PL/pgSQL function prevent_negative_stock() line 4 at RAISE 
--SQL state: P0001
create trigger log_inventory_changes
before insert or update on books
for each row
execute function log_inventory_changes();

INSERT INTO books (title, author, price, stock)
VALUES 
('Book A', 'Author 1', 19.99, 100),
('Book B', 'Author 2', 29.99, 50);

UPDATE books
SET stock = 75
WHERE book_id = 1;

DELETE FROM books
WHERE book_id = 2;

SELECT * FROM inventory_audit;


----------------------------------------
CREATE OR REPLACE PROCEDURE register_participant(
    p_first_name VARCHAR(50),
    p_last_name VARCHAR(50),
    p_email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO participants (first_name, last_name, email)
    VALUES (p_first_name, p_last_name, p_email);
END;
$$;

CREATE OR REPLACE FUNCTION calculate_avg_score(participant_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    avg_score NUMERIC;
BEGIN
    SELECT AVG(score) INTO avg_score
    FROM scores
    WHERE participant_id = participant_id;
    RETURN avg_score;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_new_registration()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO audit_log (operation, table_name, affected_row, performed_by)
    VALUES ('INSERT', 'participants', NEW.participant_id, SESSION_USER);
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_register_participant
AFTER INSERT ON participants
FOR EACH ROW
EXECUTE FUNCTION log_new_registration();

CREATE OR REPLACE PROCEDURE assign_team_leader(
    p_team_id INTEGER,
    p_leader_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE teams
    SET team_leader_id = p_leader_id
    WHERE team_id = p_team_id;
END;
$$;

CREATE OR REPLACE FUNCTION get_team_members(p_team_id INTEGER)
RETURNS TABLE(participant_id INTEGER, first_name VARCHAR, last_name VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT p.participant_id, p.first_name, p.last_name
    FROM participants p
    JOIN registrations r ON p.participant_id = r.participant_id
    WHERE r.team_id = p_team_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE update_participant_email(
    p_participant_id INTEGER,
    p_new_email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE participants
    SET email = p_new_email
    WHERE participant_id = p_participant_id;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_team_avg_score(p_team_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    avg_score NUMERIC;
BEGIN
    SELECT AVG(s.score) INTO avg_score
    FROM scores s
    JOIN registrations r ON s.participant_id = r.participant_id
    WHERE r.team_id = p_team_id;
    RETURN avg_score;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION top_performers()
RETURNS TABLE (
    participant_id INTEGER,
    first_name VARCHAR,
    last_name VARCHAR,
    challenge_name VARCHAR,
    score INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT p.participant_id, p.first_name, p.last_name, s.challenge_name, s.score
    FROM participants p
    JOIN scores s ON p.participant_id = s.participant_id
    WHERE (s.participant_id, s.challenge_name, s.score) IN (
        SELECT s2.participant_id, s2.challenge_name, MAX(s2.score)
        FROM scores s2
        GROUP BY s2.challenge_name
    );
END;
$$;

--امتیاز تیم تغییر کند و افزایش یابد امتیاز مدیر هم افزایش می یابد
CREATE OR REPLACE FUNCTION add_bonus_to_team_leader2()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE participants
    SET bonus_points = bonus_points + 10 
    WHERE participant_id = (SELECT team_leader_id FROM teams WHERE team_id = NEW.team_id);
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_add_bonus_to_team_leader2
AFTER UPDATE OF total_score ON team_scores
FOR EACH ROW
EXECUTE FUNCTION add_bonus_to_team_leader2();

--اگر شرکت کننده جدید اضافه شود
CREATE OR REPLACE FUNCTION add_bonus_to_team_leader()
RETURNS TRIGGER AS $$
DECLARE
    leader_id INTEGER;
BEGIN
    SELECT team_leader_id INTO leader_id
    FROM teams
    WHERE team_id = NEW.team_id;

    IF leader_id IS NOT NULL THEN
        UPDATE participants
        SET bonus_points = bonus_points + 10
        WHERE participant_id = leader_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_bonus
AFTER INSERT ON registrations
FOR EACH ROW
EXECUTE FUNCTION add_bonus_to_team_leader();

CREATE OR REPLACE FUNCTION log_high_score()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.score > 90 THEN
        INSERT INTO high_score_audit (participant_id, first_name, last_name, challenge_name, score)
        SELECT p.participant_id, p.first_name, p.last_name, NEW.challenge_name, NEW.score
        FROM participants p
        WHERE p.participant_id = NEW.participant_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_high_score
AFTER INSERT ON scores
FOR EACH ROW
EXECUTE FUNCTION log_high_score();

