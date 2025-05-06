-- Step 1: Simulate the original unnormalized table
WITH ProductDetail AS (
    SELECT 101 AS OrderID, 'John Doe' AS CustomerName, 'Laptop, Mouse' AS Products
    UNION ALL
    SELECT 102, 'Jane Smith', 'Tablet, Keyboard, Mouse'
    UNION ALL
    SELECT 103, 'Emily Clark', 'Phone'
),
numbers AS (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
),

-- Step 2: Transform to 1NF - one product per row
OneNF AS (
    SELECT
        OrderID,
        CustomerName,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1)) AS Product
    FROM
        ProductDetail
    JOIN numbers
        ON n <= 1 + LENGTH(Products) - LENGTH(REPLACE(Products, ',', ''))
),

-- Step 3: Add sample quantity and simulate a 1NF table called OrderDetails
OrderDetails AS (
    SELECT OrderID, CustomerName, Product,
        CASE Product
            WHEN 'Laptop' THEN 2
            WHEN 'Mouse' THEN 1
            WHEN 'Tablet' THEN 3
            WHEN 'Keyboard' THEN 1
            WHEN 'Phone' THEN 1
            ELSE 1
        END AS Quantity
    FROM OneNF
)

-- Step 4: Select from OrderDetails (optional view)
SELECT * FROM OrderDetails;

-- Step 5: Create tables for 2NF decomposition
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS OrderItems;

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Step 6: Insert data into Orders and OrderItems
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName FROM OrderDetails;

INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity FROM OrderDetails;
