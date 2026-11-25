USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 3: СТВОРЕННЯ І ВИКОРИСТАННЯ VIEW
-- ==========================================

-- 1. Представлення, що збирає повну інформацію про відправлення з кількох таблиць.
--    Замість того, щоб щоразу писати 4 JOIN, звертаємось до представлення як до таблиці.
CREATE OR ALTER VIEW vShipmentDetails
AS
SELECT
    s.ShipmentId,
    s.ShipmentDate,
    CONCAT(snd.LastName, N' ', snd.FirstName) AS Sender,
    CONCAT(rcv.LastName, N' ', rcv.FirstName) AS Receiver,
    CONCAT(dep.City, N', ', dep.Address)      AS DepartureBranch,
    CONCAT(arr.City, N', ', arr.Address)      AS ArrivalBranch,
    s.Weight,
    s.DeclaredValue,
    s.Status
FROM Shipments s
INNER JOIN Clients  snd ON s.SenderId          = snd.ClientId
INNER JOIN Clients  rcv ON s.ReceiverId        = rcv.ClientId
INNER JOIN Branches dep ON s.DepartureBranchId = dep.BranchId
INNER JOIN Branches arr ON s.ArrivalBranchId   = arr.BranchId;
GO

-- Використання: працюємо з представленням як зі звичайною таблицею
SELECT * FROM vShipmentDetails;
GO

-- ORDER BY не можна писати всередині VIEW, тому сортуємо при вибірці
SELECT Sender, Receiver, Weight, Status
FROM vShipmentDetails
WHERE Weight > 1
ORDER BY Weight DESC;
GO

-- 2. Оновлюване представлення з WITH CHECK OPTION.
--    Показує лише відділення Києва; через нього можна додавати/змінювати рядки,
--    але CHECK OPTION не дасть вставити відділення з іншого міста.
CREATE OR ALTER VIEW vKyivBranches
AS
SELECT BranchId, Address, City, Phone, Schedule
FROM Branches
WHERE City = N'Київ'
WITH CHECK OPTION;
GO

SELECT * FROM vKyivBranches;
GO

-- Оновлення даних через представлення (зміна потрапляє в базову таблицю Branches)
UPDATE vKyivBranches
SET Schedule = N'Пн-Нд 08:00-22:00'
WHERE Address = N'вул. Хрещатик, 1';
GO

-- Ця вставка буде ВІДХИЛЕНА через WITH CHECK OPTION (місто не Київ):
-- INSERT INTO vKyivBranches (Address, City) VALUES (N'вул. Городоцька, 5', N'Львів');

SELECT * FROM Branches;
GO
