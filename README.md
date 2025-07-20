# SQL-Project-Elevate-Labs
Library Management System

# 📚 Library Management System – SQL Project

A simple SQL-based **Library Management System** developed using MySQL Workbench. This project covers essential database concepts such as schema creation, many-to-many relationships, triggers, views, and report generation using SQL queries.

## 🔧 Tools Used
- MySQL Workbench
- SQL (DDL, DML, Triggers, Views)

## 📂 Project Structure
📁 Library-Management-System  
 ┣ 📄 `library_management.sql`   — Main SQL script with DDL, sample data, trigger, views, and reports  
 ┗ 📄 `README.md`                 — Project documentation  

## 🗃️ Database Schema
- **Authors** – stores author details  
- **Books** – stores book titles and publication years  
- **BookAuthors** – bridge table for M:N relation between books and authors  
- **Members** – stores library member information  
- **Loans** – tracks borrowing details, including due dates and return status  

## 🚀 Key Features
- Fully normalized schema (1NF, 2NF, 3NF)
- Many-to-many relationship between books and authors
- Pre-populated with **10 test rows per table**
- **Trigger** to auto-calculate `due_date` if not provided
- **Views** to display:
  - `borrowed_books` – all books currently borrowed
  - `overdue_books` – all books past their due date
- Predefined **report queries**:
  - Most borrowed books
  - Books borrowed by each member
  - Overdue books list

## 🧪 How to Run
1. Open **MySQL Workbench** or any SQL client connected to a MySQL server.
2. Copy and execute the `library_management.sql` file.
3. Explore the views and run the report queries provided at the bottom of the script.

## 📈 Sample Report Queries
```sql
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

-- 3. View all currently borrowed books
SELECT * FROM borrowed_books ORDER BY due_date;

-- 4. View all overdue books
SELECT * FROM overdue_books ORDER BY due_date;

