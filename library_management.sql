-- ================================================================
-- Library Management System (Simple Version with 6 Deliverables)
-- Schema: Books, Authors, Members, Loans + BookAuthors (M:N)
-- Includes: DDL, 10 test rows per table, trigger, views, report queries
-- Created: 2025-07-20
-- ================================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS library_simple;
USE library_simple;

-- Safety: drop objects if re-running script
DROP VIEW IF EXISTS overdue_books;
DROP VIEW IF EXISTS borrowed_books;

DROP TRIGGER IF EXISTS set_due_date;

DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS BookAuthors;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS Members;

-- ================================================================
-- 1. Authors Table
-- ================================================================
CREATE TABLE Authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- ================================================================
-- 2. Books Table
-- ================================================================
CREATE TABLE Books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  year INT
);

-- ================================================================
-- 3. Bridge Table: Books ↔ Authors (Many-to-Many)
-- ================================================================
CREATE TABLE BookAuthors (
  book_id INT,
  author_id INT,
  PRIMARY KEY (book_id, author_id),
  FOREIGN KEY (book_id) REFERENCES Books(book_id),
  FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);

-- ================================================================
-- 4. Members Table
-- ================================================================
/*
CREATE TABLE Members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  join_date DATE DEFAULT CURDATE()
);
*/

CREATE TABLE Members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  join_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- 5. Loans Table
-- ================================================================
CREATE TABLE Loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT,
  member_id INT,
  loan_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  due_date DATE,
  return_date DATE,
  FOREIGN KEY (book_id) REFERENCES Books(book_id),
  FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- ================================================================
-- SAMPLE DATA
-- (10 rows each table)
-- ================================================================

-- Insert Authors (10)
INSERT INTO Authors (name) VALUES
('J.K. Rowling'),
('Paulo Coelho'),
('Chetan Bhagat'),
('George Orwell'),
('Jane Austen'),
('Mark Twain'),
('Ernest Hemingway'),
('Agatha Christie'),
('Dan Brown'),
('Harper Lee');

-- Insert Books (10)
INSERT INTO Books (title, year) VALUES
('Harry Potter', 1997),
('The Alchemist', 1988),
('2 States', 2009),
('1984', 1949),
('Pride and Prejudice', 1813),
('Adventures of Tom Sawyer', 1876),
('The Old Man and the Sea', 1952),
('Murder on the Orient Express', 1934),
('The Da Vinci Code', 2003),
('To Kill a Mockingbird', 1960);

-- Link Books to Authors (1:1 mapping for simplicity; still demonstrates M:N)
INSERT INTO BookAuthors (book_id, author_id) VALUES
(1, 1),  -- Harry Potter -> J.K. Rowling
(2, 2),  -- The Alchemist -> Paulo Coelho
(3, 3),  -- 2 States -> Chetan Bhagat
(4, 4),  -- 1984 -> George Orwell
(5, 5),  -- Pride and Prejudice -> Jane Austen
(6, 6),  -- Tom Sawyer -> Mark Twain
(7, 7),  -- Old Man and the Sea -> Ernest Hemingway
(8, 8),  -- Murder on the Orient Express -> Agatha Christie
(9, 9),  -- The Da Vinci Code -> Dan Brown
(10,10); -- To Kill a Mockingbird -> Harper Lee

-- Insert Members (10)
INSERT INTO Members (name, email) VALUES
('Aarav Patel', 'aarav@example.com'),
('Isha Rao', 'isha@example.com'),
('Rohan Mehta', 'rohan@example.com'),
('Ananya Sharma', 'ananya@example.com'),
('Kabir Joshi', 'kabir@example.com'),
('Meera Desai', 'meera@example.com'),
('Vivaan Singh', 'vivaan@example.com'),
('Diya Kapoor', 'diya@example.com'),
('Arjun Nair', 'arjun@example.com'),
('Nisha Agarwal', 'nisha@example.com');

-- Insert Loans (10)
-- Mix of due dates; two returned examples (loan_id 4, 8) just to show variation.
INSERT INTO Loans (book_id, member_id, due_date, return_date) VALUES
(1, 1, DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL),
(2, 2, DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL),
(3, 3, DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL),
(4, 4, DATE_ADD(CURDATE(), INTERVAL 10 DAY), CURDATE()), -- returned today
(5, 5, DATE_ADD(CURDATE(), INTERVAL 12 DAY), NULL),
(6, 6, DATE_ADD(CURDATE(), INTERVAL 8 DAY), NULL),
(7, 7, DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL),
(8, 8, DATE_ADD(CURDATE(), INTERVAL -3 DAY), CURDATE()), -- overdue but returned
(9, 9, DATE_ADD(CURDATE(), INTERVAL -5 DAY), NULL),      -- overdue active
(10,10, DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL);

-- ================================================================
-- TRIGGER: Auto-set due_date to +14 days if not provided
-- ================================================================
DELIMITER //
CREATE TRIGGER set_due_date
BEFORE INSERT ON Loans
FOR EACH ROW
BEGIN
  IF NEW.due_date IS NULL THEN
    SET NEW.due_date = DATE_ADD(CURDATE(), INTERVAL 14 DAY);
  END IF;
END;
//
DELIMITER ;

-- ================================================================
-- VIEWS
-- ================================================================
CREATE VIEW borrowed_books AS
SELECT l.loan_id, b.title, m.name AS member_name, l.loan_date, l.due_date
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL;

CREATE VIEW overdue_books AS
SELECT l.loan_id, b.title, m.name AS member_name, l.loan_date, l.due_date
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id
WHERE l.return_date IS NULL
  AND l.due_date < CURDATE();

-- ================================================================
-- REPORT QUERIES (run as needed)
-- ================================================================

-- 1. Books borrowed by each member
SELECT m.name, COUNT(l.loan_id) AS books_borrowed
FROM Members m
LEFT JOIN Loans l ON m.member_id = l.member_id
GROUP BY m.member_id;

-- 2. Most borrowed books
SELECT b.title, COUNT(l.loan_id) AS times_borrowed
FROM Books b
LEFT JOIN Loans l ON b.book_id = l.book_id
GROUP BY b.book_id
ORDER BY times_borrowed DESC;

-- 3. Currently borrowed (same as borrowed_books view, but ordered)
SELECT * FROM borrowed_books ORDER BY due_date;

-- 4. Currently overdue (same as overdue_books view, but most overdue first)
SELECT * FROM overdue_books ORDER BY due_date;

-- ================================================================
-- END OF SCRIPT
-- ================================================================
