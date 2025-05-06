-- Step 0: Create and use a fresh database
DROP DATABASE IF EXISTS NormalizationDB;
CREATE DATABASE NormalizationDB;
USE NormalizationDB;

-- Step 1: Create and populate the original ProductDetail table
DROP TABLE IF EXISTS ProductDetail;
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 2: Create helper numbers table for splitting
DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers (n INT);
INSERT INTO numbers (n) VALUES (1), (2), (3), (4);

-- Step 3: Create OrderDetails table (1NF)
DROP TABLE IF EXISTS OrderDetails;
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);

-- Step 4: Insert into OrderDetails from split ProductDetail
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity)
SELECT
    pd.OrderID,
    pd.CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pd.Products, ',', n.n), ',', -1)) AS Product,
    CASE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pd.Products, ',', n.n), ',', -1))
        WHEN 'Laptop' THEN 2
        WHEN 'Mouse' THEN 1
        WHEN 'Tablet' THEN 3
        WHEN 'Keyboard' THEN 1
        WHEN 'Phone' THEN 1
        ELSE 1
    END AS Quantity
FROM ProductDetail pd
JOIN numbers n
  ON LENGTH(pd.Products) - LENGTH(REPLACE(pd.Products, ',', '')) >= n.n - 1;

-- Step 5: Create 2NF Tables
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

-- Step 6: Insert into Orders and OrderItems
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName FROM OrderDetails;

INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity FROM OrderDetails;

-- Optional: Check results
SELECT * FROM Orders;
SELECT * FROM OrderItems;
