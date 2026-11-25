USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 9: ТРИГЕР, ЩО ВИКОРИСТОВУЄ ТАБЛИЦІ inserted ТА deleted
-- ==========================================

-- AFTER-тригер на таблиці Shipments автоматично веде історію статусів
-- у таблиці ShipmentStatuses.
--   inserted — нові значення рядків (після INSERT/UPDATE)
--   deleted  — старі значення рядків (до UPDATE/DELETE)
-- При INSERT таблиця deleted порожня, тому LEFT JOIN дає d.ShipmentId IS NULL.
CREATE OR ALTER TRIGGER trg_Shipments_StatusHistory
ON Shipments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ShipmentStatuses (ShipmentId, BranchId, Status, StatusDateTime)
    SELECT i.ShipmentId,
           -- якщо посилку доставлено — фіксуємо відділення отримання, інакше відправлення
           CASE WHEN i.Status IN (N'Прибуло у відділення', N'Доставлено')
                THEN i.ArrivalBranchId ELSE i.DepartureBranchId END,
           i.Status,
           GETDATE()
    FROM inserted i
    LEFT JOIN deleted d ON i.ShipmentId = d.ShipmentId
    WHERE d.ShipmentId IS NULL          -- новий рядок (INSERT)
       OR d.Status <> i.Status;         -- статус змінився (UPDATE)

    -- Інформаційне повідомлення про зміну статусу (старе -> нове значення)
    DECLARE @msg NVARCHAR(400);
    SELECT TOP 1 @msg = CONCAT(N'Відправлення №', i.ShipmentId, N': ', d.Status, N' -> ', i.Status)
    FROM inserted i
    INNER JOIN deleted d ON i.ShipmentId = d.ShipmentId
    WHERE d.Status <> i.Status;

    IF @msg IS NOT NULL PRINT @msg;
END;
GO

-- Перевірка 1: нове відправлення -> у журнал потрапляє статус 'Створено'
DECLARE @S INT = (SELECT ClientId FROM Clients WHERE LastName = N'Косач');
DECLARE @R INT = (SELECT ClientId FROM Clients WHERE LastName = N'Шевченко');
DECLARE @B1 INT = (SELECT MIN(BranchId) FROM Branches);
DECLARE @B2 INT = (SELECT MAX(BranchId) FROM Branches);
EXEC usp_CreateShipment @S, @R, @B2, @B1, 1.20;
GO

-- Перевірка 2: змінюємо статус останнього відправлення двічі
DECLARE @LastId INT = (SELECT MAX(ShipmentId) FROM Shipments);

UPDATE Shipments SET Status = N'В дорозі'             WHERE ShipmentId = @LastId;
UPDATE Shipments SET Status = N'Прибуло у відділення' WHERE ShipmentId = @LastId;

-- Оновлення без зміни статусу (змінюємо лише вагу) НЕ додає запис до історії
UPDATE Shipments SET Weight = 1.25 WHERE ShipmentId = @LastId;

SELECT ss.StatusRecordId, ss.ShipmentId, ss.Status, b.Address AS Branch, ss.StatusDateTime
FROM ShipmentStatuses ss
LEFT JOIN Branches b ON ss.BranchId = b.BranchId
WHERE ss.ShipmentId = @LastId
ORDER BY ss.StatusRecordId;
GO
