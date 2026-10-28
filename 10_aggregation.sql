USE DeliverySystem;
GO

-- ==========================================
-- ПУНКТ 10 ЛАБИ: ГРУПУВАННЯ ТА АГРЕГАТНІ ФУНКЦІЇ
-- ==========================================

-- 1. COUNT та GROUP BY
-- Порахуємо кількість відправлень для кожного статусу (згрупуємо за статусом)
SELECT Status, COUNT(ShipmentId) AS ShipmentsCount
FROM Shipments
GROUP BY Status;
GO

-- 2. SUM
-- Знайдемо загальну суму оголошеної вартості всіх відправлень у базі
SELECT SUM(DeclaredValue) AS TotalDeclaredValue
FROM Shipments;
GO

-- 3. MIN, MAX, AVG
-- Знайдемо мінімальну, максимальну та середню базову ціну на наші послуги
SELECT 
    MIN(BasePrice) AS MinPrice,
    MAX(BasePrice) AS MaxPrice,
    AVG(BasePrice) AS AveragePrice
FROM ServiceTypes;
GO

-- 4. GROUP BY + HAVING
-- HAVING працює так само як WHERE, але застосовується вже до згрупованих даних.
-- Знайдемо відправників (SenderId), які відправили сумарно 5 або більше кілограмів (Weight)
SELECT SenderId, SUM(Weight) AS TotalWeight
FROM Shipments
GROUP BY SenderId
HAVING SUM(Weight) >= 5.00;
GO