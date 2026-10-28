USE DeliverySystem;
GO

-- 1. Гарантовано видаляємо всі старі "зламані" записи
DELETE FROM Shipments;
DELETE FROM Couriers;
DELETE FROM Clients;
DELETE FROM Branches;
DELETE FROM ServiceTypes;
GO

-- 2. Додаємо дані з префіксом N (National) для кирилиці
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