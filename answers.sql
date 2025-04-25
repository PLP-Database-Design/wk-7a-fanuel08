--Question 1: Transforming into 1NF 

-- Simulate the original ProductDetail table using a Common Table Expression (CTE)
WITH ProductDetail AS (
    SELECT 101 AS OrderID, 'John Doe' AS CustomerName, 'Laptop, Mouse' AS Products
    UNION ALL
    SELECT 102, 'Jane Smith', 'Tablet, Keyboard, Mouse'
    UNION ALL
    SELECT 103, 'Emily Clark', 'Phone'
),

-- Generate a sequence of numbers to help split the comma-separated list
numbers AS (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
)

-- Extract one product per row by splitting the Products string
SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', numbers.n), ',', -1)) AS Product
FROM
    ProductDetail
JOIN numbers
-- Only join rows where the number of commas is at least (n - 1)
ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= numbers.n - 1;


--Question 2: Transforming into 2NF
-- Create Orders table to store customer info only once (remove partial dependency)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Insert unique OrderID and CustomerName pairs into the Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Create OrderItems table for the actual products and quantities
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product), -- Composite key
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert product-level order data into OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

