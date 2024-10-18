TRUNCATE TABLE school;
TRUNCATE TABLE assassins;
TRUNCATE TABLE my_table;
TRUNCATE TABLE cars;
-- CREATE TABLE transactions;
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,              
    transaction_date DATE NOT NULL,        
    transaction_amount DECIMAL(15, 2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, 
    account_id INT NOT NULL,
    description TEXT                       
);

CREATE TABLE Officers (
    officer_id SERIAL PRIMARY KEY,
    officer_name VARCHAR(50),
    rank VARCHAR(30)
);

CREATE TABLE Cases (
    case_id SERIAL PRIMARY KEY,
    case_title VARCHAR(100),
    case_status VARCHAR(20)
);

CREATE TABLE Assignments (
    assignment_id SERIAL PRIMARY KEY,
    officer_id INT,
    case_id INT,
    FOREIGN KEY (officer_id) REFERENCES Officers(officer_id),
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);




CREATE TABLE Players (
    player_id SERIAL PRIMARY KEY,
    player_name VARCHAR(50),
    position VARCHAR(30),
    salary NUMERIC
);

CREATE TABLE Expenses (
    expense_id SERIAL PRIMARY KEY,
    expense_type VARCHAR(100),
    amount NUMERIC
);

CREATE TABLE Revenues (
    revenue_id SERIAL PRIMARY KEY,
    revenue_type VARCHAR(100),
    amount NUMERIC
);


INSERT INTO transactions (customer_id, transaction_date, transaction_amount, transaction_type, account_id, description)
VALUES 
    (101, '2024-10-01', 100000, 'Transfer', 201, 'Large international transfer'),
    (102, '2024-10-02', 9999, 'Deposit', 202, 'Cash deposit'),
    (101, '2024-10-03', 95000, 'Transfer', 201, 'Round-number transaction'),
    (103, '2024-10-05', 500000, 'Deposit', 203, 'Multiple cash deposits'),
    (101, '2024-10-06', 85000, 'Transfer', 201, 'Large local transfer'),
    (104, '2024-10-08', 1200, 'Withdrawal', 204, 'Small ATM withdrawal'),
    (101, '2024-10-10', 150000, 'Transfer', 201, 'Unusually large transfer'),
    (102, '2024-10-11', 5000, 'Deposit', 202, 'Cash deposit for regular expenses'),
    (103, '2024-10-12', 75000, 'Deposit', 203, 'Lump sum deposit'),
    (105, '2024-10-13', 1000000, 'Transfer', 205, 'Million dollar transfer'),
    (106, '2024-10-14', 3000, 'Deposit', 206, 'Frequent small deposits'),
    (107, '2024-10-15', 250000, 'Transfer', 207, 'Large corporate transfer'),
    (108, '2024-10-16', 15000, 'Deposit', 208, 'High-value deposit'),
    (109, '2024-10-17', 500000, 'Transfer', 209, 'Suspiciously large transfer'),
    (110, '2024-10-18', 98000, 'Transfer', 210, 'Near round-number transfer'),
    (101, '2024-10-19', 125000, 'Transfer', 201, 'Large transfer to offshore account'),
    (111, '2024-10-20', 2200, 'Withdrawal', 211, 'Small withdrawal for groceries'),
    (102, '2024-10-21', 8000, 'Deposit', 202, 'Deposit from unknown source'),
    (103, '2024-10-22', 450000, 'Deposit', 203, 'Another high-value deposit'),
    (104, '2024-10-23', 35000, 'Transfer', 204, 'Business transaction'),
    (105, '2024-10-24', 600000, 'Transfer', 205, 'Large overseas transfer'),
    (106, '2024-10-25', 5000, 'Deposit', 206, 'Regular cash deposit'),
    (107, '2024-10-26', 100000, 'Transfer', 207, 'High-value corporate payment'),
    (108, '2024-10-27', 18000, 'Deposit', 208, 'Unusually high deposit'),
    (109, '2024-10-28', 470000, 'Transfer', 209, 'Suspicious large money movement'),
    (110, '2024-10-29', 99000, 'Transfer', 210, 'Large transfer avoiding reporting threshold'),
    (111, '2024-10-30', 2400, 'Withdrawal', 211, 'ATM withdrawal for personal expenses'),
    (101, '2024-11-01', 100000, 'Transfer', 201, 'Another large transfer'),
    (102, '2024-11-02', 7500, 'Deposit', 202, 'Frequent small deposits'),
    (103, '2024-11-03', 600000, 'Deposit', 203, 'Another large deposit'),
    (104, '2024-11-04', 7000, 'Transfer', 204, 'Business transaction'),
    (105, '2024-11-05', 30000, 'Transfer', 205, 'Corporate client payment'),
    (106, '2024-11-06', 3500, 'Deposit', 206, 'Frequent deposits under reporting threshold'),
    (107, '2024-11-07', 1000000, 'Transfer', 207, 'Suspiciously large transfer to foreign account'),
    (108, '2024-11-08', 50000, 'Deposit', 208, 'Unexpected large deposit'),
    (109, '2024-11-09', 400000, 'Transfer', 209, 'Large suspicious transfer'),
    (110, '2024-11-10', 96000, 'Transfer', 210, 'Almost round-number transfer'),
    (111, '2024-11-11', 2200, 'Withdrawal', 211, 'Withdrawal for unknown reason'),
    (101, '2024-11-12', 25000, 'Transfer', 201, 'Medium-sized transfer'),
    (102, '2024-11-13', 7800, 'Deposit', 202, 'Cash deposit from unknown source'),
    (103, '2024-11-14', 550000, 'Deposit', 203, 'Another large deposit'),
    (104, '2024-11-15', 3000, 'Transfer', 204, 'Business-related payment'),
    (105, '2024-11-16', 480000, 'Transfer', 205, 'Corporate client settlement'),
    (106, '2024-11-17', 7500, 'Deposit', 206, 'Frequent small deposits'),
    (107, '2024-11-18', 950000, 'Transfer', 207, 'Unusually high-value transfer'),
    (108, '2024-11-19', 15000, 'Deposit', 208, 'High-value deposit with unknown origin'),
    (109, '2024-11-20', 650000, 'Transfer', 209, 'Large-scale transfer between accounts'),
    (110, '2024-11-21', 89000, 'Transfer', 210, 'Near round-number transaction'),
    (111, '2024-11-22', 2600, 'Withdrawal', 211, 'Regular ATM withdrawal'),
    (101, '2024-11-23', 700000, 'Transfer', 201, 'Large offshore transfer'),
    (102, '2024-11-24', 4000, 'Deposit', 202, 'Frequent cash deposit under threshold'),
    (103, '2024-11-25', 1000000, 'Deposit', 203, 'Large deposit possibly laundered money'),
    (104, '2024-11-26', 18000, 'Transfer', 204, 'Business-related money transfer'),
    (105, '2024-11-27', 550000, 'Transfer', 205, 'Suspiciously large transaction'),
    (106, '2024-11-28', 1200, 'Deposit', 206, 'Small ATM deposit'),
    (107, '2024-11-29', 820000, 'Transfer', 207, 'High-value corporate payment'),
    (108, '2024-11-30', 22000, 'Deposit', 208, 'Suspiciously high-value deposit'),
    (109, '2024-12-01', 500000, 'Transfer', 209, 'Potential money laundering transfer'),
    (110, '2024-12-02', 87000, 'Transfer', 210, 'Large transfer slightly below reporting limit'),
    (111, '2024-12-03', 2900, 'Withdrawal', 211, 'Regular ATM withdrawal for personal use');







INSERT INTO Officers (officer_name, rank) VALUES
('Officer Jane', 'Detective'),
('Officer John', 'Sergeant'),
('Officer Max', 'Officer'),
('Officer Lily', 'Captain');

INSERT INTO Officers (officer_id, officer_name) VALUES (5, 'Officer Without Case');


INSERT INTO Cases (case_title, case_status) VALUES
('The Great Cookie Caper', 'Open'),
('The Missing Unicorn', 'Closed'),
('The Case of the Lost Cat', 'Open'),
('The Robot Bandit', 'Open');

INSERT INTO Cases (case_id, case_title) VALUES (5, 'Unassigned Case');


INSERT INTO Assignments (officer_id, case_id) VALUES
(1, 1), 
(2, 3),  
(4, 2), 
(3, 4); 



INSERT INTO Players (player_name, position, salary) VALUES
('Marcus Rashford', 'Forward', 200000),
('Bruno Fernandes', 'Midfielder', 250000),
('Harry Maguire', 'Defender', 180000),
('André Onana', 'Goalkeeper', 200000),
('Casemiro', 'Midfielder', 300000),
('Rasmus Højlund', 'Forward', 150000),
('Raphael Varane', 'Defender', 250000),
('Luke Shaw', 'Defender', 160000),
('Christian Eriksen', 'Midfielder', 150000),
('Antony', 'Forward', 200000);



INSERT INTO Expenses (expense_type, amount) VALUES
('Stadium Maintenance', 500000),
('Transfer Fees', 800000),
('Travel Costs', 150000),
('Marketing', 200000);


INSERT INTO Revenues (revenue_type, amount) VALUES
('Ticket Sales', 1000000),
('Merchandise', 600000),
('TV Rights', 1200000),
('Sponsorship', 400000);

SELECT * from transactions;
SELECT * from transactions
WHERE customer_id=101;
SELECT * from transactions
WHERE transaction_amount>100000;
SELECT * from transactions
WHERE transaction_date='2024-10-10';
SELECT * from transactions
WHERE transaction_type='Deposit';
SELECT * from transactions
WHERE transaction_date BETWEEN '2024-10-02' and '2024-10-10';
SELECT * from transactions
ORDER BY transaction_amount DESC;
SELECT COUNT(*) AS total_transactions from transactions;
SELECT SUM(transaction_amount) AS total_amount
FROM transactions;
SELECT MAX(transaction_amount) FROM transactions;
SELECT COUNT(DISTINCT customer_id) FROM transactions;
SELECT COUNT(*) AS large_transaction_count, SUM(transaction_amount) FROM transactions
WHERE transaction_amount >100000;
SELECT AVG(transaction_amount) FROM transactions;
DROP TABLE transactions;
SELECT o.officer_name , c.case_title
FROM Officers o
INNER JOIN Assignments a on o.officer_id = a.officer_id
inner join Cases c on a.case_id=c.case_id;
SELECT o.officer_name , c.case_title
FROM Officers o
LEFT JOIN Assignments a on o.officer_id = a.officer_id
LEFT join Cases c on a.case_id=c.case_id;
SELECT o.officer_name , c.case_title
FROM Officers o
RIGHT JOIN Assignments a on o.officer_id = a.officer_id
RIGHT join Cases c on a.case_id=c.case_id;
