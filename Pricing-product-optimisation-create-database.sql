CREATE DATABASE IF NOT EXISTS project_MySQL;

USE project_MySQL;

CREATE TABLE `Customers` (
  `Customer_PK` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Customer_ID` VARCHAR(40),
  `Country` VARCHAR(40),
  `City` VARCHAR(40),
  `State` VARCHAR(40),
  `Postal_code` VARCHAR(40),
  `Region` VARCHAR(40)
);

CREATE TABLE `Orders` (
  `Order_PK` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Order_ID` VARCHAR(40),
  `Order_date` DATE,
  `Ship_date` DATE,
  `Ship_mode` VARCHAR(40),
  `Customer_PK` INT NOT NULL,
  FOREIGN KEY (`Customer_PK`)
      REFERENCES `Customers`(`Customer_PK`)
);

-- later discovered that column Order_ID doesn't exist, so we drop it
ALTER TABLE Orders
DROP COLUMN Order_ID;

ALTER TABLE Orders
ADD UNIQUE (Customer_PK, Order_date, Ship_date, Ship_mode);


CREATE TABLE `Factories` (
  `Factory_PK` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Factory_name` VARCHAR(40),
  `Division_name` VARCHAR(40),
  `Latitude` VARCHAR(40),
  `Longitude` VARCHAR(40)
);

ALTER TABLE Factories
ADD UNIQUE (Factory_name, Division_name);


CREATE TABLE `Products` (
  `Product_PK` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Product_name` VARCHAR(40),
  `Factory_PK` INT NOT NULL,
  FOREIGN KEY (`Factory_PK`)
      REFERENCES `Factories`(`Factory_PK`)
);

CREATE TABLE `Sales_bridge_table` (
  `Unit` INT,
  `Cost` DECIMAL(10,2),
  `Sales` DECIMAL(10,2),
  `Profit` DECIMAL(10,2),
  `Product_PK` INT NOT NULL,
  `Order_PK` INT NOT NULL,
  PRIMARY KEY (`Order_PK`, `Product_PK`),
  FOREIGN KEY (`Order_PK`) 
	REFERENCES `Orders`(`Order_PK`),
  FOREIGN KEY (`Product_PK`) 
	REFERENCES `Products`(`Product_PK`)
);

-- load grouped_factories.csv

SELECT * FROM factories;

-- to create a _FK from existing Factory_PK in table Products we need to make a temporary table products_tmp

CREATE TABLE Products_tmp (
  Product_name VARCHAR(40),
  Factory_name VARCHAR(40),
  Division_name VARCHAR(40)
);

-- load grouped_products.csv

SELECT * FROM Products_tmp;

-- now we can JOIN the temporary table on the factory table to get products table

INSERT INTO Products (Product_name, Factory_PK)
SELECT
  pt.Product_name,
  f.Factory_PK
FROM Products_tmp pt
JOIN Factories f
  ON f.Factory_name = pt.Factory_name
 AND f.Division_name = pt.Division_name;


-- after that we can drop temporary table products_tmp
-- SET FOREIGN_KEY_CHECKS = 0;
-- DROP TABLE Products_tmp;
-- SET FOREIGN_KEY_CHECKS = 1;


SELECT * FROM products;
SELECT * FROM factories;

-- then we load customers_unique.csv
SELECT * FROM customers;

-- for orders and sales tables we first need to create temporary tables to correctly transfer the data
-- temporary table for orders - Orders_tmp
DROP TABLE IF EXISTS Orders_tmp;
CREATE TABLE Orders_tmp (
  Customer_ID VARCHAR(40),
  Order_date  DATE,
  Ship_date   DATE,
  Ship_mode   VARCHAR(40)
);

-- temporary table for sales - Sales_tmp
DROP TABLE IF EXISTS Sales_tmp;
CREATE TABLE Sales_tmp (
  Product_name  VARCHAR(40),
  Customer_ID   VARCHAR(40),
  Units         INT,
  Sales         DECIMAL(10,2),
  Cost          DECIMAL(10,2),
  Gross_profit  DECIMAL(10,2),
  Order_date    DATE,
  Ship_date     DATE,
  Ship_mode     VARCHAR(40)
);

-- loading orders_unique.csv to the Orders_tmp
-- loading sales.csv to the Sales_tmp

-- now we can insert data into Orders from temporary table and using the Customer_PK from Customers table
INSERT INTO Orders (Order_date, Ship_date, Ship_mode, Customer_PK)
SELECT
  ot.Order_date,
  ot.Ship_date,
  ot.Ship_mode,
  c.Customer_PK
FROM Orders_tmp ot
JOIN Customers c
  ON c.Customer_ID = ot.Customer_ID
GROUP BY
  c.Customer_PK,
  ot.Order_date,
  ot.Ship_date,
  ot.Ship_mode;
  
  SELECT * FROM orders;
  
  -- now we can insert data into Sales from temporary table and using the Product_PK and Order_PK from Products table and Orders table
INSERT INTO Sales_bridge_table (Unit, Cost, Sales, Profit, Product_PK, Order_PK)
SELECT
  SUM(st.Units)        AS Unit,
  SUM(st.Cost)         AS Cost,
  SUM(st.Sales)        AS Sales,
  SUM(st.Gross_profit) AS Profit,
  p.Product_PK,
  o.Order_PK
FROM Sales_tmp st
JOIN Customers c
  ON c.Customer_ID = st.Customer_ID
JOIN Orders o
  ON o.Customer_PK = c.Customer_PK
 AND o.Order_date  = st.Order_date
 AND o.Ship_date   = st.Ship_date
 AND o.Ship_mode   = st.Ship_mode
JOIN Products p
  ON p.Product_name = st.Product_name
GROUP BY
  o.Order_PK,
  p.Product_PK;

-- eventually we can drop temporary tables orders_tmp and sales_tmp
-- SET FOREIGN_KEY_CHECKS = 0;
-- DROP TABLE Orders_tmp;
-- DROP TABLE Sales_tmp;
-- SET FOREIGN_KEY_CHECKS = 1;

-- renaming the bridge table
RENAME TABLE sales_bridge_table TO sales;
