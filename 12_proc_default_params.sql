USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 4: ЗБЕРЕЖЕНА ПРОЦЕДУРА З ПАРАМЕТРАМИ ЗА ЗАМОВЧУВАННЯМ
--                  ТА УМОВНИМИ ОПЕРАТОРАМИ
-- ==========================================

-- Додамо ще одного клієнта, щоб було більше даних для прикладів
IF NOT EXISTS (SELECT 1 FROM Clients WHERE Phone = '+380631234567')
    INSERT INTO Clients (LastName, FirstName, MiddleName, Phone, Email)
    VALUES (N'Сковорода', N'Григорій', N'Савич', '+380631234567', 'skovoroda@example.com');
GO

-- Процедура створює відправлення та одразу додає до нього послугу.
-- Параметри @DeclaredValue, @ServiceCode та @Status мають значення за замовчуванням,
-- тому при виклику їх можна не передавати.
CREATE OR ALTER PROCEDURE usp_CreateShipment
    @SenderId          INT,
    @ReceiverId        INT,
    @DepartureBranchId INT,
    @ArrivalBranchId   INT,
    @Weight            DECIMAL(6,2),
    @DeclaredValue     MONEY         = 0,           -- за замовчуванням без оголошеної вартості
    @ServiceCode       INT           = NULL,        -- NULL => буде обрано послугу 'Стандарт'
    @Status            NVARCHAR(50)  = N'Створено'
AS
BEGIN
    SET NOCOUNT ON;

    -- Умова 1: відправник і отримувач мають бути різними людьми
    IF @SenderId = @ReceiverId
    BEGIN
        PRINT N'Помилка: відправник і отримувач не можуть співпадати.';
        RETURN -1;
    END;

    -- Умова 2: обидва клієнти повинні існувати
    IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientId = @SenderId)
       OR NOT EXISTS (SELECT 1 FROM Clients WHERE ClientId = @ReceiverId)
    BEGIN
        PRINT N'Помилка: відправника або отримувача не знайдено.';
        RETURN -2;
    END;

    -- Умова 3: якщо послугу не передали — беремо 'Стандарт'
    IF @ServiceCode IS NULL
        SELECT @ServiceCode = ServiceCode FROM ServiceTypes WHERE Name = N'Стандарт';

    -- Умова 4: коефіцієнт ціни залежить від ваги (IF ... ELSE IF ... ELSE)
    DECLARE @Coef DECIMAL(4,2);
    IF @Weight <= 5
        SET @Coef = 1.0;
    ELSE IF @Weight <= 20
        SET @Coef = 1.5;
    ELSE
    BEGIN
        SET @Coef = 2.0;
        PRINT N'Увага: вантажне відправлення (понад 20 кг), ціна подвоюється.';
    END;

    DECLARE @Price MONEY = (SELECT BasePrice FROM ServiceTypes WHERE ServiceCode = @ServiceCode) * @Coef;

    -- Обидві вставки виконуємо в одній транзакції: або все, або нічого
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Shipments (SenderId, ReceiverId, DepartureBranchId, ArrivalBranchId,
                               Weight, DeclaredValue, Status)
        VALUES (@SenderId, @ReceiverId, @DepartureBranchId, @ArrivalBranchId,
                @Weight, @DeclaredValue, @Status);

        DECLARE @NewId INT = SCOPE_IDENTITY();

        INSERT INTO ShipmentServices (ShipmentId, ServiceCode, Quantity, Price)
        VALUES (@NewId, @ServiceCode, 1, @Price);

        COMMIT TRANSACTION;
        PRINT CONCAT(N'Створено відправлення №', @NewId, N', вартість доставки: ', @Price, N' грн');
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT N'Помилка при створенні відправлення: ' + ERROR_MESSAGE();
        RETURN -3;
    END CATCH;
END;
GO

-- Виклики процедури
DECLARE @Shevchenko INT = (SELECT ClientId FROM Clients WHERE LastName = N'Шевченко');
DECLARE @Kosach     INT = (SELECT ClientId FROM Clients WHERE LastName = N'Косач');
DECLARE @Skovoroda  INT = (SELECT ClientId FROM Clients WHERE LastName = N'Сковорода');
DECLARE @B1 INT = (SELECT MIN(BranchId) FROM Branches);
DECLARE @B2 INT = (SELECT MAX(BranchId) FROM Branches);
DECLARE @Express INT = (SELECT ServiceCode FROM ServiceTypes WHERE Name = N'Експрес');

-- а) лише обов'язкові параметри — решта береться за замовчуванням
EXEC usp_CreateShipment @Kosach, @Skovoroda, @B2, @B1, 2.00;

-- б) явно передаємо всі параметри, вантаж > 20 кг
EXEC usp_CreateShipment
    @SenderId = @Skovoroda, @ReceiverId = @Shevchenko,
    @DepartureBranchId = @B1, @ArrivalBranchId = @B2,
    @Weight = 25.00, @DeclaredValue = 3000, @ServiceCode = @Express, @Status = N'В дорозі';

-- в) помилковий виклик: відправник = отримувач (спрацює умова 1)
DECLARE @rc INT;
EXEC @rc = usp_CreateShipment @Kosach, @Kosach, @B1, @B2, 1.00;
PRINT CONCAT(N'Код повернення: ', @rc);

SELECT * FROM vShipmentDetails;
SELECT * FROM ShipmentServices;
GO
