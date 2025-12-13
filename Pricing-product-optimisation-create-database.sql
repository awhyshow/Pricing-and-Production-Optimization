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

CREATE TABLE `Factories` (
  `Factory_PK` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Factory_name` VARCHAR(40),
  `Division_name` VARCHAR(40),
  `Latitude` VARCHAR(40),
  `Longitude` VARCHAR(40)
);


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

SELECT * FROM factories;

-- to create a _FK from existing Factory_PK in table Products I need to make a temporary table

DROP TABLE Products_tmp;

CREATE TABLE Products_tmp (
  Product_name VARCHAR(40),
  Factory_name VARCHAR(40),
  Division_name VARCHAR(40)
);

SELECT * FROM Products_tmp;

-- now I can JOIN the temporary table on the factory table to get products table

INSERT INTO Products (Product_name, Factory_PK)
SELECT
  pt.Product_name,
  f.Factory_PK
FROM Products_tmp pt
JOIN Factories f
  ON f.Factory_name = pt.Factory_name
 AND f.Division_name = pt.Division_name;

SELECT * FROM products;
SELECT * FROM factories;
