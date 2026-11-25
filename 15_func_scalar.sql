USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 7: ФУНКЦІЯ З ПАРАМЕТРАМИ, ЩО ПОВЕРТАЄ СКАЛЯРНЕ ЗНАЧЕННЯ
-- ==========================================

-- Функція розраховує повну вартість доставки:
--   базова ціна послуги
-- + 10 грн за кожен кілограм понад перший
-- + страхування 0.5% від оголошеної вартості
CREATE OR ALTER FUNCTION dbo.fn_CalcDeliveryCost
(
    @Weight        DECIMAL(6,2),
    @ServiceCode   INT,
    @DeclaredValue MONEY = 0
)
RETURNS MONEY
AS
BEGIN
    DECLARE @BasePrice MONEY = (SELECT BasePrice FROM ServiceTypes WHERE ServiceCode = @ServiceCode);

    IF @BasePrice IS NULL
        RETURN NULL;   -- невідома послуга

    DECLARE @WeightFee MONEY = CASE WHEN @Weight > 1 THEN (@Weight - 1) * 10 ELSE 0 END;
    DECLARE @Insurance MONEY = ISNULL(@DeclaredValue, 0) * 0.005;

    RETURN ROUND(@BasePrice + @WeightFee + @Insurance, 2);
END;
GO

-- Виклик скалярної функції: обов'язково вказуємо схему dbo.
-- Для параметра зі значенням за замовчуванням у функції пишемо DEFAULT
DECLARE @Express INT = (SELECT ServiceCode FROM ServiceTypes WHERE Name = N'Експрес');
SELECT dbo.fn_CalcDeliveryCost(3.00, @Express, DEFAULT) AS CostWithoutInsurance,
       dbo.fn_CalcDeliveryCost(3.00, @Express, 2000)    AS CostWithInsurance;
GO

-- Використання функції у запиті: порівняємо реально нараховану ціну з розрахунковою
SELECT s.ShipmentId,
       s.Weight,
       s.DeclaredValue,
       st.Name                                                         AS Service,
       ss.Price                                                        AS ChargedPrice,
       dbo.fn_CalcDeliveryCost(s.Weight, ss.ServiceCode, s.DeclaredValue) AS FullCost
FROM Shipments s
INNER JOIN ShipmentServices ss ON s.ShipmentId   = ss.ShipmentId
INNER JOIN ServiceTypes     st ON ss.ServiceCode = st.ServiceCode;
GO
