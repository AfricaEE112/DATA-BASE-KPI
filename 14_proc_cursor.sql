USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 6: ЗБЕРЕЖЕНА ПРОЦЕДУРА З КУРСОРОМ
-- ==========================================

-- Процедура проходить курсором по всіх відділеннях і для кожного
-- формує рядок звіту: кількість кур'єрів, вихідних і вхідних відправлень.
-- Етапи роботи з курсором: DECLARE -> OPEN -> FETCH -> CLOSE -> DEALLOCATE.
CREATE OR ALTER PROCEDURE usp_BranchReport
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BranchId INT,
            @City     NVARCHAR(50),
            @Address  NVARCHAR(200),
            @Couriers INT,
            @Outgoing INT,
            @Incoming INT,
            @Total    INT = 0;

    -- 1. Оголошення курсору (FAST_FORWARD = лише вперед і лише читання, найшвидший тип)
    DECLARE branch_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT BranchId, City, Address
        FROM Branches
        ORDER BY City, Address;

    -- 2. Відкриття
    OPEN branch_cursor;

    -- 3. Читання першого рядка
    FETCH NEXT FROM branch_cursor INTO @BranchId, @City, @Address;

    PRINT N'===== ЗВІТ ПО ВІДДІЛЕННЯХ =====';

    -- @@FETCH_STATUS = 0, поки рядки успішно зчитуються
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @Couriers = COUNT(*) FROM Couriers  WHERE BranchId          = @BranchId;
        SELECT @Outgoing = COUNT(*) FROM Shipments WHERE DepartureBranchId = @BranchId;
        SELECT @Incoming = COUNT(*) FROM Shipments WHERE ArrivalBranchId   = @BranchId;

        PRINT CONCAT(@City, N', ', @Address,
                     N' | кур''єрів: ', @Couriers,
                     N' | відправлено: ', @Outgoing,
                     N' | очікується: ', @Incoming,
                     CASE WHEN @Couriers = 0 THEN N' | УВАГА: немає кур''єрів!' ELSE N'' END);

        SET @Total = @Total + @Outgoing;

        FETCH NEXT FROM branch_cursor INTO @BranchId, @City, @Address;
    END;

    -- 4. Закриття та 5. звільнення ресурсів
    CLOSE branch_cursor;
    DEALLOCATE branch_cursor;

    PRINT CONCAT(N'Всього відправлень у системі: ', @Total);
END;
GO

EXEC usp_BranchReport;
GO
