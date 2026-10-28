USE DeliverySystem;
GO

-- 4. Таблиця "Кур'єр"
CREATE TABLE Couriers (
    CourierId INT PRIMARY KEY IDENTITY, -- Номер_кур'єра
    FullName NVARCHAR(100) NOT NULL,    -- ПІБ
    Phone VARCHAR(20) UNIQUE NOT NULL,  -- Телефон
    BranchId INT NOT NULL,              -- Номер_відділення (Зовнішній ключ)
    
    -- Встановлюємо зв'язок з таблицею Branches
    CONSTRAINT FK_Couriers_Branches FOREIGN KEY (BranchId) 
        REFERENCES Branches (BranchId)
);
GO

-- 5. Таблиця "Відправлення"
CREATE TABLE Shipments (
    ShipmentId INT PRIMARY KEY IDENTITY, -- Номер_відправлення
    ShipmentDate DATETIME DEFAULT GETDATE(), -- Дата_відправлення (за замовчуванням поточна дата/час)
    SenderId INT NOT NULL,               -- Номер_відправника
    ReceiverId INT NOT NULL,             -- Номер_отримувача
    DepartureBranchId INT NOT NULL,      -- Відділення_відправлення
    ArrivalBranchId INT NOT NULL,        -- Відділення_отримання
    Weight DECIMAL(6,2) CHECK (Weight > 0), -- Вага (з перевіркою, що вона більше нуля)
    DeclaredValue MONEY DEFAULT 0,       -- Оголошена вартість
    Status NVARCHAR(50) DEFAULT 'Створено', -- Статус

    -- Встановлюємо зв'язки (FOREIGN KEYS)
    CONSTRAINT FK_Shipments_Sender FOREIGN KEY (SenderId) 
        REFERENCES Clients (ClientId),
        
    CONSTRAINT FK_Shipments_Receiver FOREIGN KEY (ReceiverId) 
        REFERENCES Clients (ClientId),
        
    CONSTRAINT FK_Shipments_DepBranch FOREIGN KEY (DepartureBranchId) 
        REFERENCES Branches (BranchId),
        
    CONSTRAINT FK_Shipments_ArrBranch FOREIGN KEY (ArrivalBranchId) 
        REFERENCES Branches (BranchId)
);
GO

USE DeliverySystem;
GO

-- 6. Таблиця "Статус відправлення"
CREATE TABLE ShipmentStatuses (
    StatusRecordId INT PRIMARY KEY IDENTITY, -- Номер_запису
    ShipmentId INT NOT NULL,                 -- Номер_відправлення
    BranchId INT NULL,                       -- Номер_відділення (може бути NULL, якщо статус оновив кур'єр)
    Status NVARCHAR(50) NOT NULL,            -- Статус
    StatusDateTime DATETIME DEFAULT GETDATE(), -- Дата_час

    -- Використовуємо ON DELETE CASCADE: якщо видалити відправлення, всі його статуси видаляться автоматично
    CONSTRAINT FK_Status_Shipment FOREIGN KEY (ShipmentId) 
        REFERENCES Shipments (ShipmentId) ON DELETE CASCADE,
        
    CONSTRAINT FK_Status_Branch FOREIGN KEY (BranchId) 
        REFERENCES Branches (BranchId)
);
GO

-- 7. Таблиця "Послуги у відправленні"
CREATE TABLE ShipmentServices (
    ShipmentId INT NOT NULL,   -- Номер_відправлення
    ServiceCode INT NOT NULL,  -- Код_послуги
    Quantity INT DEFAULT 1 CHECK (Quantity > 0), -- Кількість
    Price MONEY NOT NULL,      -- Ціна

    -- Складений первинний ключ (обидва поля підкреслені на схемі)
    CONSTRAINT PK_ShipmentServices PRIMARY KEY (ShipmentId, ServiceCode),

    CONSTRAINT FK_Services_Shipment FOREIGN KEY (ShipmentId) 
        REFERENCES Shipments (ShipmentId) ON DELETE CASCADE,
        
    CONSTRAINT FK_Services_ServiceType FOREIGN KEY (ServiceCode) 
        REFERENCES ServiceTypes (ServiceCode)
);
GO

-- 8. Таблиця "Оплата"
CREATE TABLE Payments (
    PaymentId INT PRIMARY KEY IDENTITY, -- Номер_оплати
    ShipmentId INT NOT NULL,            -- Номер_відправлення
    Amount MONEY NOT NULL CHECK (Amount > 0), -- Сума
    PaymentDate DATETIME DEFAULT GETDATE(),   -- Дата_оплати
    PaymentMethod NVARCHAR(50) NOT NULL,      -- Спосіб_оплати

    CONSTRAINT FK_Payments_Shipment FOREIGN KEY (ShipmentId) 
        REFERENCES Shipments (ShipmentId)
);
GO