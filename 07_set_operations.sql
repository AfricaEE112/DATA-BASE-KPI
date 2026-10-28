USE DeliverySystem;
GO

-- ==========================================
-- ПУНКТ 7 ЛАБИ: UNION, EXCEPT, INTERSECT
-- ==========================================

-- 1. Оператор UNION (Об'єднання)
-- Об'єднує результати двох запитів і видаляє дублікати (якщо треба залишити дублікати, пишуть UNION ALL).
-- Наприклад, зберемо всі контактні номери телефонів (і клієнтів, і відділень) у єдиний довідник
SELECT Phone AS ContactPhone, N'Клієнт' AS OwnerType 
FROM Clients
UNION
SELECT Phone, N'Відділення' 
FROM Branches;
GO

-- 2. Оператор INTERSECT (Перетин)
-- Повертає лише ті рядки, які присутні одночасно в обох запитах.
-- Знайдемо ідентифікатори клієнтів, які одночасно є VIP і мають пошту на '@example.com'
SELECT ClientId FROM Clients WHERE ClientType = N'VIP'
INTERSECT
SELECT ClientId FROM Clients WHERE Email LIKE '%@example.com%';
GO

-- 3. Оператор EXCEPT (Різниця)
-- Повертає рядки з першого запиту, яких НЕМАЄ у другому.
-- Отримаємо всіх клієнтів, КРІМ тих, хто є VIP (тобто отримаємо звичайних клієнтів)
SELECT ClientId, LastName, FirstName FROM Clients
EXCEPT
SELECT ClientId, LastName, FirstName FROM Clients WHERE ClientType = N'VIP';
GO