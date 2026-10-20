USE DeliverySystem;
GO

-- 1. Перевіряємо, чи створилися всі 8 таблиць
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';
GO

-- 2. Перевіряємо роботу обмежень (додаємо перші дані)
-- Команда INSERT додає нові рядки в таблицю
INSERT INTO Clients (LastName, FirstName, Phone, Email)
VALUES 
('Шевченко', 'Тарас', '+380501234567', 'taras@example.com'),
('Косач', 'Лариса', '+380671234567', 'lesia@example.com');
GO

INSERT INTO Branches (Address, City, Phone, Schedule)
VALUES 
('вул. Хрещатик, 1', 'Київ', '+380441112233', 'Пн-Нд 08:00-21:00'),
('вул. Політехнічна, 14', 'Київ', '+380449998877', 'Пн-Сб 09:00-19:00');
GO

INSERT INTO ServiceTypes (Name, Description, BasePrice)
VALUES 
('Стандарт', 'Доставка за 2-3 дні', 50.00),
('Експрес', 'Доставка на наступний день', 100.00);
GO

-- 3. Дивимося на результат (Вибірка даних командою SELECT)
SELECT * FROM Clients;
SELECT * FROM Branches;
SELECT * FROM ServiceTypes;
GO

USE DeliverySystem;
GO

-- 1. Видаляємо "зламані" дані (Оператор DELETE з пункту 4 лаби)
DELETE FROM Clients;
DELETE FROM Branches;
DELETE FROM ServiceTypes;
GO

-- 2. Додаємо дані правильно, використовуючи префікс N для кирилиці
INSERT INTO Clients (LastName, FirstName, Phone, Email)
VALUES 
(N'Шевченко', N'Тарас', '+380501234567', 'taras@example.com'),
(N'Косач', N'Лариса', '+380671234567', 'lesia@example.com');
GO

INSERT INTO Branches (Address, City, Phone, Schedule)
VALUES 
(N'вул. Хрещатик, 1', N'Київ', '+380441112233', N'Пн-Нд 08:00-21:00'),
(N'вул. Політехнічна, 14', N'Київ', '+380449998877', N'Пн-Сб 09:00-19:00');
GO

INSERT INTO ServiceTypes (Name, Description, BasePrice)
VALUES 
(N'Стандарт', N'Доставка за 2-3 дні', 50.00),
(N'Експрес', N'Доставка на наступний день', 100.00);
GO

-- 3. Перевіряємо результат
SELECT * FROM Clients;
SELECT * FROM Branches;
SELECT * FROM ServiceTypes;
GO