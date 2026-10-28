USE DeliverySystem;
GO

-- Виправляємо знаки питання за допомогою оператора UPDATE (з пункту 4 лаби)
UPDATE Clients
SET ClientType = N'Фізична особа'
WHERE ClientType LIKE '%?%';
GO

-- Додамо ще один UPDATE для різноманітності в звіті:
-- Наприклад, Тарас Шевченко став VIP-клієнтом
UPDATE Clients
SET ClientType = N'VIP'
WHERE LastName = N'Шевченко';
GO

-- Перевіряємо результат
SELECT * FROM Clients;
GO