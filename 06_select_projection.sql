USE DeliverySystem;
GO

-- ==========================================
-- ПУНКТ 6 ЛАБИ: ПРОЄКЦІЯ ТА СОРТУВАННЯ
-- ==========================================

-- 1. Використання AS (Псевдоніми)
-- За допомогою оператора AS можна визначити псевдонім вихідного стовпця або змінити його назву у вибірці
SELECT 
    LastName + ' ' + FirstName AS FullName, 
    Phone AS ContactNumber
FROM Clients;
GO

-- 2. Використання DISTINCT
-- Оператор DISTINCT дозволяє вибрати лише унікальні рядки (прибирає дублікати)
SELECT DISTINCT ClientType 
FROM Clients;
GO

-- 3. Використання ORDER BY (Сортування)
-- Сортуємо відділення за містом (за замовчуванням за зростанням) та за адресою за спаданням (DESC)
SELECT * FROM Branches
ORDER BY City ASC, Address DESC;
GO

-- 4. Використання TOP
-- Оператор TOP дозволяє вибрати певну кількість рядків із таблиці (наприклад, 1 найдорожчу послугу)
SELECT TOP 1 * FROM ServiceTypes
ORDER BY BasePrice DESC;
GO

-- 5. Використання OFFSET та FETCH (Посторінкова навігація)
-- Ці оператори застосовуються лише у відсортованому наборі після ORDER BY. 
-- OFFSET вказує скільки рядків пропустити, а FETCH NEXT - скільки отримати.
-- Пропускаємо першого клієнта і беремо наступного (другого)
SELECT * FROM Clients
ORDER BY ClientId
OFFSET 1 ROWS
FETCH NEXT 1 ROWS ONLY;
GO