USE DeliverySystem;
GO

-- ==========================================
-- ПУНКТ 9 ЛАБИ: ВКЛАДЕНІ ЗАПИТИ
-- ==========================================

-- 1. Оператор IN
-- Знайти клієнтів, які відправляли хоча б одну посилку (їх ClientId є в списку SenderId)
SELECT LastName, FirstName, Phone
FROM Clients
WHERE ClientId IN (SELECT SenderId FROM Shipments);
GO

-- 2. Оператор EXISTS
-- Знайти відділення, за якими закріплений хоча б один кур'єр. 
-- EXISTS повертає TRUE, якщо підзапит знаходить хоча б один рядок.
SELECT Address, City 
FROM Branches b
WHERE EXISTS (SELECT 1 FROM Couriers c WHERE c.BranchId = b.BranchId);
GO

-- 3. Оператор ALL
-- Знайти послугу з найвищою базовою ціною 
-- (ціна якої більша або дорівнює ВСІМ іншим цінам у таблиці)
SELECT Name, BasePrice 
FROM ServiceTypes
WHERE BasePrice >= ALL (SELECT BasePrice FROM ServiceTypes);
GO

-- 4. Оператор ANY 
-- Знайти послуги, які дорожчі за БУДЬ-ЯКУ (ANY) послугу з назвою 'Стандарт'
-- (тобто дорожчі за мінімальну ціну Стандарту)
SELECT Name, BasePrice 
FROM ServiceTypes
WHERE BasePrice > ANY (SELECT BasePrice FROM ServiceTypes WHERE Name = N'Стандарт');
GO