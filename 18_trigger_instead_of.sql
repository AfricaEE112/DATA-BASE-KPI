USE DeliverySystem;
GO

-- ==========================================
-- ЛАБА 3, ПУНКТ 10: ТРИГЕР INSTEAD OF
-- ==========================================

-- INSTEAD OF DELETE на таблиці Clients виконується ЗАМІСТЬ видалення.
-- Клієнтів, які мають відправлення (як відправники чи отримувачі), видаляти не можна —
-- тригер їх пропускає й виводить повідомлення. Решту клієнтів видаляє сам тригер.
CREATE OR ALTER TRIGGER trg_Clients_InsteadOfDelete
ON Clients
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Повідомляємо про клієнтів, яких видалити не можна
    DECLARE @Blocked NVARCHAR(MAX);
    SELECT @Blocked = STRING_AGG(CONCAT(d.LastName, N' ', d.FirstName), N', ')
    FROM deleted d
    WHERE EXISTS (SELECT 1 FROM Shipments s
                  WHERE s.SenderId = d.ClientId OR s.ReceiverId = d.ClientId);

    IF @Blocked IS NOT NULL
        PRINT N'Не можна видалити клієнтів, що мають відправлення: ' + @Blocked;

    -- 2. Реально видаляємо лише клієнтів без відправлень
    DELETE c
    FROM Clients c
    INNER JOIN deleted d ON c.ClientId = d.ClientId
    WHERE NOT EXISTS (SELECT 1 FROM Shipments s
                      WHERE s.SenderId = d.ClientId OR s.ReceiverId = d.ClientId);

    PRINT CONCAT(N'Видалено клієнтів: ', @@ROWCOUNT);
END;
GO

-- Перевірка: додаємо тимчасового клієнта без відправлень
IF NOT EXISTS (SELECT 1 FROM Clients WHERE Phone = '+380509999999')
    INSERT INTO Clients (LastName, FirstName, Phone)
    VALUES (N'Тестовий', N'Клієнт', '+380509999999');
GO

SELECT ClientId, LastName, FirstName FROM Clients;

-- Намагаємось видалити двох клієнтів одним запитом:
--  'Шевченко' має відправлення -> тригер його залишить
--  'Тестовий' відправлень не має -> буде видалений
DELETE FROM Clients
WHERE LastName IN (N'Шевченко', N'Тестовий');

SELECT ClientId, LastName, FirstName FROM Clients;
GO
