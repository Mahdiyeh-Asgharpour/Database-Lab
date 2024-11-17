drop table public.books;
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(50),       
    last_name VARCHAR(50),        
    birth_date DATE               
);

CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY, 
    name VARCHAR(100),               
    address VARCHAR(255),            
    phone VARCHAR(20)                
);
select * from publishers;
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY, 
    name VARCHAR(50)                
);
select * from categories;
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,          
    title VARCHAR(255),                  
    author_id INTEGER REFERENCES authors(author_id),       
    publisher_id INTEGER REFERENCES publishers(publisher_id), 
    category_id INTEGER REFERENCES categories(category_id),    
    price DECIMAL(10,2),                  
    stock INTEGER,                        
    publication_date DATE                 
);
select * from books;
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,        
    first_name VARCHAR(50),                
    last_name VARCHAR(50),                 
    email VARCHAR(100) UNIQUE,             
    join_date DATE                         
);
select * from customers;
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,           
    customer_id INTEGER REFERENCES customers(customer_id), 
    order_date DATE,                       
    status VARCHAR(20)                     
);
select * from orders;
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,      
    order_id INTEGER REFERENCES orders(order_id),      
    book_id INTEGER REFERENCES books(book_id),          
    quantity INTEGER,                      
    unit_price DECIMAL(10,2)               
);
select * from order_items;
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,          
    book_id INTEGER REFERENCES books(book_id),           
    customer_id INTEGER REFERENCES customers(customer_id), 
    rating INTEGER CHECK (rating >=1 AND rating <=5),    
    comment TEXT,                          
    review_date DATE                       
);
select * from reviews;
INSERT INTO authors (first_name, last_name, birth_date) VALUES
('George', 'Orwell', '1903-06-25'),
('J.K.', 'Rowling', '1965-07-31'),
('J.R.R.', 'Tolkien', '1892-01-03'),
('Agatha', 'Christie', '1890-09-15'),
('Stephen', 'King', '1947-09-21');

INSERT INTO publishers (name, address, phone) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', '212-782-9000'),
('HarperCollins', '195 Broadway, New York, NY', '212-207-7000'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY', '212-698-7000');

INSERT INTO categories (name) VALUES
('Fiction'),
('Fantasy'),
('Mystery'),
('Horror'),
('Science Fiction');

INSERT INTO books (title, author_id, publisher_id, category_id, price, stock, publication_date) VALUES
('1984', 1, 1, 1, 15.99, 120, '1949-06-08'),
('Animal Farm', 1, 1, 1, 9.99, 200, '1945-08-17'),
('Harry Potter and the Sorcerer Stone', 2, 2, 2, 12.99, 150, '1997-06-26'),
('Harry Potter and the Chamber of Secrets', 2, 2, 2, 12.99, 130, '1998-07-02'),
('The Hobbit', 3, 1, 2, 14.99, 100, '1937-09-21'),
('Murder on the Orient Express', 4, 3, 3, 11.99, 80, '1934-01-01'),
('The Shining', 5, 2, 4, 13.99, 90, '1977-01-28'),
('It', 5, 3, 4, 18.99, 60, '1986-09-15'),
('The Lord of the Rings', 3, 1, 2, 25.99, 70, '1954-07-29'),
('And Then There Were None', 4, 3, 3, 10.99, 110, '1939-11-06');

INSERT INTO customers (first_name, last_name, email, join_date) VALUES
('John', 'Doe', 'john.doe@example.com', '2020-01-15'),
('Jane', 'Smith', 'jane.smith@example.com', '2020-03-22'),
('Alice', 'Johnson', 'alice.johnson@example.com', '2021-07-19'),
('Bob', 'Brown', 'bob.brown@example.com', '2022-05-30'),
('Charlie', 'Davis', 'charlie.davis@example.com', '2023-02-10');

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2023-10-01', 'Shipped'),
(2, '2023-10-03', 'Processing'),
(3, '2023-10-05', 'Delivered'),
(4, '2023-10-07', 'Cancelled'),
(5, '2023-10-09', 'Shipped');

INSERT INTO order_items (order_id, book_id, quantity, unit_price) VALUES
(1, 1, 2, 15.99),
(1, 3, 1, 12.99),
(2, 2, 1, 9.99),
(2, 5, 2, 14.99),
(3, 4, 1, 12.99),
(3, 7, 1, 13.99),
(4, 6, 3, 11.99),
(5, 8, 1, 18.99),
(5, 10, 2, 10.99);

INSERT INTO reviews (book_id, customer_id, rating, comment, review_date) VALUES
(1, 1, 5, 'A thought-provoking masterpiece.', '2023-10-02'),
(3, 2, 4, 'Loved the magical elements!', '2023-10-04'),
(5, 3, 5, 'An incredible adventure.', '2023-10-06'),
(7, 4, 3, 'It was okay, a bit too long.', '2023-10-08'),
(10, 5, 4, 'Engaging and thrilling.', '2023-10-10');

------------------------------------
SELECT title
FROM books
JOIN authors ON books.author_id = authors.author_id
WHERE authors.first_name = 'J.K.' AND authors.last_name = 'Rowling';
SELECT title
FROM books
WHERE stock > 100;
SELECT first_name, last_name, email
FROM customers
WHERE EXTRACT(YEAR FROM join_date) = 2023;
SELECT orders.*
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id
WHERE customers.email = 'alice.johnson@example.com';
SELECT title
FROM books
JOIN categories ON books.category_id = categories.category_id
WHERE categories.name = 'Mystery';
SELECT order_id, SUM(quantity * unit_price) AS total_value
FROM order_items
GROUP BY order_id;
SELECT books.title
FROM books
JOIN reviews ON books.book_id = reviews.book_id
GROUP BY books.title
HAVING AVG(reviews.rating) >= 4;
SELECT books.title, publishers.name AS publisher_name
FROM books
JOIN publishers ON books.publisher_id = publishers.publisher_id
WHERE publication_date > '2000-01-01';
SELECT customers.first_name, customers.last_name, COUNT(orders.order_id) AS order_count
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.first_name, customers.last_name
HAVING COUNT(orders.order_id) > 2;
SELECT categories.name AS category_name, SUM(books.stock * books.price) AS total_inventory_value
FROM books
JOIN categories ON books.category_id = categories.category_id
GROUP BY categories.name;
SELECT first_name, last_name, email
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);
SELECT categories.name AS category_name, SUM(order_items.quantity) AS total_sales
FROM order_items
JOIN books ON order_items.book_id = books.book_id
JOIN categories ON books.category_id = categories.category_id
GROUP BY categories.name
ORDER BY total_sales DESC
LIMIT 1;
SELECT publishers.name AS publisher_name, SUM(order_items.quantity * order_items.unit_price) AS total_sales
FROM order_items
JOIN books ON order_items.book_id = books.book_id
JOIN publishers ON books.publisher_id = publishers.publisher_id
GROUP BY publishers.name
ORDER BY total_sales DESC;
SELECT customers.first_name, customers.last_name, COUNT(DISTINCT books.category_id) AS category_count
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN books ON order_items.book_id = books.book_id
JOIN customers ON orders.customer_id = customers.customer_id
GROUP BY customers.first_name, customers.last_name
HAVING COUNT(DISTINCT books.category_id) >= 3;
SELECT EXTRACT(MONTH FROM orders.order_date) AS month, SUM(order_items.quantity * order_items.unit_price) AS total_sales
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
WHERE EXTRACT(YEAR FROM orders.order_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
GROUP BY EXTRACT(MONTH FROM orders.order_date)
ORDER BY total_sales DESC
LIMIT 1;
SELECT customers.first_name, customers.last_name, SUM(order_items.quantity * order_items.unit_price) AS total_value
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
JOIN order_items ON orders.order_id = order_items.order_id
GROUP BY customers.first_name, customers.last_name
ORDER BY total_value DESC
LIMIT 1;
