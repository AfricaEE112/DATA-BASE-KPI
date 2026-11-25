USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 5: ЗБЕРЕЖЕНА ПРОЦЕДУРА З ВИХІДНИМИ ПАРАМЕТРАМИ
-- ==========================================

-- Процедура рахує статистику клієнта і повертає її через OUTPUT-параметри
CREATE OR ALTER PROCEDURE usp_GetClientStats
    @ClientId      INT,
    @SentCount     INT           OUTPUT,  -- скільки відправлень надіслав
    @ReceivedCount INT           OUTPUT,  -- скільки відправлень отримав
    @TotalWeight   DECIMAL(10,2) OUTPUT,  -- сумарна вага надісланого
    @TotalCost     MONEY         OUTPUT   -- сумарна вартість послуг у його відправленнях
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @SentCount   = COUNT(*),
           @TotalWeight = ISNULL(SUM(Weight), 0)
    FROM Shipments
    WHERE SenderId = @ClientId;

    SELECT @ReceivedCount = COUNT(*)
    FROM Shipments
    WHERE ReceiverId = @ClientId;

    SELECT @TotalCost = ISNULL(SUM(ss.Price * ss.Quantity), 0)
    FROM ShipmentServices ss
    INNER JOIN Shipments s ON ss.ShipmentId = s.ShipmentId
    WHERE s.SenderId = @ClientId;
END;
GO

-- Виклик: для OUTPUT-параметрів заздалегідь оголошуємо змінні
-- і передаємо їх із ключовим словом OUTPUT
DECLARE @Id INT = (SELECT ClientId FROM Clients WHERE LastName = N'Сковорода');
DECLARE @Sent INT, @Received INT, @Weight DECIMAL(10,2), @Cost MONEY;

EXEC usp_GetClientStats
    @ClientId      = @Id,
    @SentCount     = @Sent     OUTPUT,
    @ReceivedCount = @Received OUTPUT,
    @TotalWeight   = @Weight   OUTPUT,
    @TotalCost     = @Cost     OUTPUT;

PRINT CONCAT(N'Надіслано відправлень: ', @Sent);
PRINT CONCAT(N'Отримано відправлень: ', @Received);
PRINT CONCAT(N'Загальна вага надісланого: ', @Weight, N' кг');
PRINT CONCAT(N'Сума за послуги: ', @Cost, N' грн');

SELECT @Sent AS SentCount, @Received AS ReceivedCount, @Weight AS TotalWeight, @Cost AS TotalCost;
GO
