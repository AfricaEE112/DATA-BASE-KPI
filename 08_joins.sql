USE DeliverySystem;
GO

-- Отримуємо реальні існуючі ID за допомогою вкладених запитів
DECLARE @FirstBranchId INT = (SELECT TOP 1 BranchId FROM Branches ORDER BY BranchId ASC);
DECLARE @SecondBranchId INT = (SELECT TOP 1 BranchId FROM Branches ORDER BY BranchId DESC);
DECLARE @SenderId INT = (SELECT TOP 1 ClientId FROM Clients WHERE LastName = N'Шевченко');
DECLARE @ReceiverId INT = (SELECT TOP 1 ClientId FROM Clients WHERE LastName = N'Косач');

-- Додаємо кур'єра, прив'язуючи його до реального першого відділення
INSERT INTO Couriers (FullName, Phone, BranchId)
VALUES (N'Іван Франко', '+380991112233', @FirstBranchId);

-- Робимо відправлення з реальними ID клієнтів та відділень
INSERT INTO Shipments (SenderId, ReceiverId, DepartureBranchId, ArrivalBranchId, Weight, DeclaredValue, Status)
VALUES (@SenderId, @ReceiverId, @FirstBranchId, @SecondBranchId, 5.50, 1000.00, N'В дорозі');
GO

-- ==========================================
-- ПУНКТ 8 ЛАБИ: З'ЄДНАННЯ ТАБЛИЦЬ (JOIN)
-- ==========================================

-- 1. INNER JOIN (Внутрішнє з'єднання)
SELECT s.ShipmentId, c.LastName + ' ' + c.FirstName AS SenderName, s.Status
FROM Shipments s
INNER JOIN Clients c ON s.SenderId = c.ClientId;
GO

-- 2. LEFT JOIN (Ліве з'єднання)
SELECT c.LastName, s.ShipmentId, s.Weight
FROM Clients c
LEFT JOIN Shipments s ON c.ClientId = s.SenderId;
GO

-- 3. RIGHT JOIN (Праве з'єднання)
SELECT cr.FullName AS CourierName, b.Address AS BranchAddress
FROM Couriers cr
RIGHT JOIN Branches b ON cr.BranchId = b.BranchId;
GO

-- 4. FULL JOIN (Повне з'єднання)
SELECT c.LastName, s.ShipmentId
FROM Clients c
FULL JOIN Shipments s ON c.ClientId = s.SenderId;
GO

-- 5. CROSS JOIN (Декартовий добуток)
SELECT b.Address AS BranchAddress, st.Name AS ServiceName
FROM Branches b
CROSS JOIN ServiceTypes st;
GO