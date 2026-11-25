USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 8: ФУНКЦІЯ, ЩО ПОВЕРТАЄ ТАБЛИЧНЕ ЗНАЧЕННЯ
-- ==========================================

-- 1. Вбудована (inline) таблична функція: тіло — один SELECT.
--    Повертає всі відправлення клієнта (і надіслані, і отримані) із зазначенням ролі.
CREATE OR ALTER FUNCTION dbo.fn_ClientShipments (@ClientId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT s.ShipmentId,
           s.ShipmentDate,
           CASE WHEN s.SenderId = @ClientId THEN N'Відправник' ELSE N'Отримувач' END AS Role,
           s.Weight,
           s.DeclaredValue,
           s.Status
    FROM Shipments s
    WHERE s.SenderId = @ClientId OR s.ReceiverId = @ClientId
);
GO

-- Таблична функція використовується у FROM, як звичайна таблиця
DECLARE @Id INT = (SELECT ClientId FROM Clients WHERE LastName = N'Шевченко');
SELECT * FROM dbo.fn_ClientShipments(@Id)
ORDER BY ShipmentDate;
GO

-- Можна з'єднувати з іншими таблицями через OUTER APPLY:
-- для кожного клієнта — кількість його відправлень
SELECT c.LastName, c.FirstName, COUNT(f.ShipmentId) AS ShipmentsCount
FROM Clients c
OUTER APPLY dbo.fn_ClientShipments(c.ClientId) f
GROUP BY c.LastName, c.FirstName;
GO

-- 2. Багатооператорна (multi-statement) таблична функція:
--    явно описуємо структуру результату і заповнюємо її кількома інструкціями.
--    Повертає статистику по відділеннях вказаного міста (NULL = всі міста).
CREATE OR ALTER FUNCTION dbo.fn_BranchStats (@City NVARCHAR(50) = NULL)
RETURNS @Result TABLE
(
    BranchId      INT,
    Address       NVARCHAR(200),
    CouriersCount INT,
    Outgoing      INT,
    TotalWeight   DECIMAL(10,2),
    LoadLevel     NVARCHAR(20)
)
AS
BEGIN
    INSERT INTO @Result (BranchId, Address, CouriersCount, Outgoing, TotalWeight)
    SELECT b.BranchId,
           b.Address,
           (SELECT COUNT(*) FROM Couriers c WHERE c.BranchId = b.BranchId),
           (SELECT COUNT(*) FROM Shipments s WHERE s.DepartureBranchId = b.BranchId),
           (SELECT ISNULL(SUM(s.Weight), 0) FROM Shipments s WHERE s.DepartureBranchId = b.BranchId)
    FROM Branches b
    WHERE @City IS NULL OR b.City = @City;

    -- Друга інструкція: визначаємо рівень завантаженості відділення
    UPDATE @Result
    SET LoadLevel = CASE
                   WHEN Outgoing = 0 THEN N'Немає'
                   WHEN Outgoing < 3 THEN N'Низька'
                   ELSE N'Висока'
               END;

    RETURN;
END;
GO

SELECT * FROM dbo.fn_BranchStats(N'Київ');
SELECT * FROM dbo.fn_BranchStats(DEFAULT);
GO
