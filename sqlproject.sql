#CREATE DATABASE 
CREATE DATABASE cake_shop;
USE cake_shop;
CREATE table employee(
employee_ID INT NOT NULL,
employee_name VARCHAR(55) NOT NULL, 
employee_email VARCHAR(50) NOT NULL,
employee_department VARCHAR(50) NOT NULL,
CONSTRAINT pk_employee PRIMARY KEY (employee_ID)
);
INSERT INTO employee
(employee_ID,employee_name,employee_email,employee_department)
VALUES
(1, 'Adejoke', 'adejoke@gmail.com', 'Production'),
(2, 'Oyinda', 'oyinda@gmail.com', 'Production'),
(3, 'Neemah', 'neemah@gmail.com', 'Sales'),
(4, 'Habibah', 'habibah@gmail.com', 'Sales');
CREATE TABLE customers (
customers_id INT NOT NULL,
name VARCHAR(50) NOT NULL,
email_address VARCHAR(50),
mobile_number INT, 
CONSTRAINT pk_customers PRIMARY KEY (customers_id)
);
ALTER TABLE customers
MODIFY COLUMN mobile_number VARCHAR(20);
INSERT INTO customers 
(customers_id, name, email_address, mobile_number)
VALUES
(1, 'Martha', 'martha@gmail.com',07753437456),
(2, 'Zen','zen@gmail.com', 07753437467),
(3, 'Ade', 'ade@gmail.com', 07856437456),
(4, 'Zain', 'zain@gmail.com', 07756438456);
CREATE TABLE customer_address(
customer_id INT NOT NULL,
customer_address_id VARCHAR(50) NOT NULL PRIMARY KEY,
house_no VARCHAR(50) NOT NULL,
street VARCHAR(50),
city VARCHAR(50),
country VARCHAR(50),
postcode VARCHAR(50),
CONSTRAINT pk_customer_address FOREIGN KEY (customer_id) references customers (customers_id)
);
ALTER TABLE customer_address
RENAME COLUMN country to county;
ALTER TABLE customer_address
ADD CONSTRAINT fk_customer_address FOREIGN KEY (customer_id) references customers (customers_id);
INSERT INTO customer_address
(customer_id,customer_address_id,house_no,street,city,county,postcode)
VALUES
(1, 1,50,'Bury road','Bolton','Greater Manchester', 'BL5 4AR'),
(2, 2,11,'Surbiton ','Manchester','Greater Manchester', 'M45 2UA'),
(3, 3,315,'Bury road','Bolton','Greater Manchester', 'BL2 4AR'),
(4, 4,416,'Bury road','Bolton','Greater Manchester', 'BL2 6AR');
CREATE TABLE cake(
cake_id INT NOT NULL PRIMARY KEY,
cake_size INT NOT NULL,
price VARCHAR(50) NOT NULL
);
ALTER TABLE cake
MODIFY COLUMN cake_size VARCHAR(50);
INSERT INTO cake 
(cake_id,cake_size,price)
VALUES
(1, 'size 6', '$20'),
(2, 'size 8', '$30'),
(3, 'size 10', '$40'),
(4, 'size 12', '$70'),
(5, 'size 14', 100);
ALTER TABLE cake
DROP COLUMN price;
ALTER TABLE cake
ADD price INT;
UPDATE cake
SET price = 20
WHERE cake_id =1;
UPDATE cake
SET price = 30
WHERE cake_id =2;
UPDATE cake
SET price = 40
WHERE cake_id =3;
UPDATE cake
SET price = 70
WHERE cake_id =4;
UPDATE cake
SET price = 100
WHERE cake_id =5;
CREATE TABLE orders(
order_id VARCHAR(50)NOT NULL PRIMARY KEY,
cake_id INT NOT NULL,
filling VARCHAR(50),
flavour VARCHAR(50),
CONSTRAINT fk_orders FOREIGN KEY (cake_id) REFERENCES cake (cake_id)
);
INSERT INTO orders
(order_id,cake_id,filling,flavour)
VALUES
('1a',2,'caramel','strawberry'),
('2b',4,'chocolate mouse','carrot'),
('3b',1,'white chocolate mouse', 'red velvet'),
('4b', 3,NULL,'vanilla');
CREATE TABLE customers_orders(
customers_orders_id INT NOT NULL PRIMARY KEY,
order_id VARCHAR(50) NOT NULL ,
customer_id INT NOT NULL,
CONSTRAINT fk_customers_orders FOREIGN KEY(order_id) REFERENCES orders(order_id), 
CONSTRAINT fk_customer_orders FOREIGN KEY(customer_id) REFERENCES customers(customers_id)
);
INSERT INTO customers_orders
(customers_orders_id, order_id,customer_id)
VALUES 
(1,'3b',4),
(2,'1a',1),
(3,'4b',3),
(4,'2b',2);

#QUERYING DATABASE
-- a query to know the numbers of customers within Bolton
SELECT customer_id,
street,
city,
postcode
FROM customer_address
WHERE city ='Bolton';
-- a query to know highest order 
SELECT o.order_id,c.customer_id,ca.cake_size,ca.price
FROM orders o
INNER JOIN customers_orders c 
ON o.order_id = c.order_id 
INNER JOIN cake ca
ON ca.cake_id = o.cake_id
GROUP BY price
ORDER BY price DESC;
--  a sub query to extract customers with city not stated  
SELECT customers_orders_id,
order_id,
customer_id
FROM customers_orders
WHERE customer_id =(
SELECT customer_id
FROM customer_address
WHERE city IS NULL);
-- creating view with joins of different tables 
-- join view 1: joining customer and customer_address tables to show customers address and contact details
CREATE VIEW customers_details
AS 
SELECT c.name,
c.email_address,
c.mobile_number,
cu.house_no,
cu.street,
cu.city,
cu.county
FROM customers c 
JOIN customer_address cu
ON 
c.customers_id = cu.customer_id;
-- join view 2: joining the cake table and customers_orders table to show the ordered cake details
CREATE VIEW cake_details
AS
SELECT o.order_id,
o.filling,
o.flavour,
ca.cake_size,
ca.price
FROM orders o
INNER JOIN cake ca
ON o.cake_id = ca.cake_id
INNER JOIN  customers_orders co
ON o.order_id = co.order_id;
-- Creating a stored function to determine if a customer is eligible for discount
DELIMITER //
CREATE FUNCTION discount_eligible(price INT)
RETURNS VARCHAR(20)
deterministic

BEGIN
DECLARE discount_eligible VARCHAR(20);
IF price >50 THEN 
SET discount_eligible = "YES";
ELSEIF price < 50 THEN 
SET discount_eligible ="No";
END IF;
RETURN (discount_eligible);
END //
	
DELIMITER ;

-- using the created stored function with a view to determine eligible customers for discount using HAVING
SELECT order_id,
cake_size,
price,
discount_eligible(price) as discount
FROM cake_details
HAVING discount = 'YES';

-- a view that uses 3 tables
CREATE VIEW orders_full_detail
AS
SELECT cu.customer_id,
o.order_id,
o.filling,
o.flavour,
c.cake_size,
c.price,
ca.city,
ca.postcode,
cust.name,
cust.email_address,
cust.mobile_number 
FROM customers_orders cu
INNER JOIN
orders o
ON 
cu.order_id = o.order_id
INNER JOIN
cake c
ON 
o.order_id = c.cake_id
INNER JOIN 
customers cust
ON cu.customer_id = cust.customers_id
INNER JOIN 
customer_address ca
ON cu.customer_id = ca.customer_id;
-- using the created view to show all orders essential details 
SELECT order_id,
 flavour,
 filling,
 cake_size,
 price,
 name,
 mobile_number,
 postcode,
 email_address
FROM orders_full_detail;

-- to determine the customer elligible for discount using the created view
SELECT customer_id, name, city, discount_eligible(price) as discount
FROM orders_full_detail
WHERE price > 50;

DELIMITER //
CREATE FUNCTION discount_amount(price INT)
RETURNS INT 
Deterministic
BEGIN
	DECLARE discount_amount INT;
	IF price >50 THEN 
	SET discount_amount = 0.05 * price;
	ELSEIF price < 50 THEN 
	SET discount_amount = 0;
	END IF;
	RETURN (discount_amount);
END //

DELIMITER ;





