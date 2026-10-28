-- Створюємо саму базу даних та робимо її активною
CREATE DATABASE DeliverySystem;
GO
USE DeliverySystem;
GO

-- 1. Таблиця "Клієнт"
CREATE TABLE Clients (
    ClientId INT PRIMARY KEY IDENTITY, -- Номер_клієнта (автоматичний лічильник)
    LastName NVARCHAR(50) NOT NULL,    -- Прізвище
    FirstName NVARCHAR(50) NOT NULL,   -- Ім'я
    MiddleName NVARCHAR(50),           -- По батькові (може бути пустим)
    ClientType NVARCHAR(20) DEFAULT 'Фізична особа', -- Тип клієнта
    Phone VARCHAR(20) UNIQUE NOT NULL, -- Телефон (унікальний)
    Email VARCHAR(50) UNIQUE,          -- Email (унікальний)
    Address NVARCHAR(200)              -- Адреса
);
GO

-- 2. Таблиця "Відділення"
CREATE TABLE Branches (
    BranchId INT PRIMARY KEY IDENTITY, -- Номер_відділення
    Address NVARCHAR(200) NOT NULL,    -- Адреса
    City NVARCHAR(50) NOT NULL,        -- Місто
    Phone VARCHAR(20),                 -- Телефон
    Schedule NVARCHAR(100)             -- Графік роботи (наприклад, 'Пн-Нд 08:00-20:00')
);
GO

-- 3. Таблиця "Тип послуги"
CREATE TABLE ServiceTypes (
    ServiceCode INT PRIMARY KEY IDENTITY, -- Код_послуги
    Name NVARCHAR(100) NOT NULL,          -- Назва
    Description NVARCHAR(MAX),            -- Опис
    BasePrice MONEY NOT NULL CHECK (BasePrice >= 0) -- Базова ціна (тип MONEY і перевірка, щоб ціна не була від'ємною)
);
GO