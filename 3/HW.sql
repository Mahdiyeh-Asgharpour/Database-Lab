SELECT 
    SUM(salary) AS total_salary,
    AVG(salary) AS average_salary
FROM Players;
SELECT player_name, salary
FROM Players
WHERE salary > (SELECT AVG(salary) FROM Players);
SELECT expense_type, amount
FROM Expenses 
ORDER BY amount ASC;
SELECT revenue_type, amount
FROM Revenues
ORDER BY amount DESC;
SELECT *
FROM Revenues , Expenses
WHERE Revenues.amount > Expenses.amount
Select * 
from Revenues 
INNER join Expenses 
on Revenues.amount > Expenses.amount
SELECT player_name , salary
FROM Players ,Expenses 
where salary > amount;
Select player_name , salary 
from Players 
INNER join Expenses 
on salary > amount;
select * from players
select * from Expenses