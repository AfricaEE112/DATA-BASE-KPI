-- Створення бази даних
CREATE DATABASE university;
GO

-- Встановлення її як поточної
USE university;
GO

-- Створення таблиці студентів
CREATE TABLE Students
(
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(20) NOT NULL,
    LastName NVARCHAR(20) NOT NULL,
    Age INT DEFAULT 18,
    Email VARCHAR(30) UNIQUE,
    Phone VARCHAR(20) UNIQUE
);
GO