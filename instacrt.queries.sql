CREATE TABLE orders (
    order_id INT,
    user_id INT,
    eval_set VARCHAR(20),
    order_number INT,
    order_dow INT,
    order_hour_of_day INT,
    days_since_prior_order FLOAT
);

CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(255),
    aisle_id INT,
    department_id INT
);

CREATE TABLE aisles (
    aisle_id INT,
    aisle VARCHAR(255)
);

CREATE TABLE departments (
    department_id INT,
    department VARCHAR(255)
);

CREATE TABLE order_products_train (
    order_id INT,
    product_id INT,
    add_to_cart_order INT,
    reordered INT
);
CREATE TABLE order_product_prior(
    order_id INT,
    product_id INT,
    add_to_cart_order INT,
    recordered INT
   
);

select * from orders;
select * from order_product_prior;
select * from order_products_train;
select * from departments;
select * from aisles;
select * from products;

--IMORTING ORDERS DATA
copy
orders(order_id,user_id,eval_set,order_number,order_dow,order_hour_of_day,days_since_prior_order
)
from 'D:\archive\orders.csv'
delimiter ','
csv header;

--importing order_product_prior
copy
order_product_prior(order_id,product_id,add_to_cart_order,recordered)
from '‪D:\archive\order_products_prior.csv'
delimiter ','
csv header;

-- importing order_products_train
select * from order_products_train;

-- importing data from departments
select * from departments;

-- importing data from aisels
select * from aisles;

-- importing data from products
select * from products

--check row count of the tables
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM order_products_train;
SELECT COUNT(*) FROM aisles;
SELECT COUNT(*) FROM departments;

-- checking null value
SELECT
COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_null,
COUNT(*) FILTER (WHERE user_id IS NULL) AS user_id_null,
COUNT(*) FILTER (WHERE days_since_prior_order IS NULL) AS days_null
FROM orders;

-- 
select * from products 
where product_id is null;
-- check duplicates
select order_id ,
count(*) from orders group by order_id 
having count (*)>1;
-- 
select product_id , count(*) from products group by product_id
having count(*)>1;

-- creating primary keys
ALTER TABLE orders
ADD PRIMARY KEY(order_id);

ALTER TABLE products
ADD PRIMARY KEY(product_id);

ALTER TABLE aisles
ADD PRIMARY KEY(aisle_id);

ALTER TABLE departments
ADD PRIMARY KEY(department_id);

-- creating foreign keys
ALTER TABLE products
ADD CONSTRAINT fk_department
FOREIGN KEY(department_id)
REFERENCES departments(department_id);

ALTER TABLE products
ADD CONSTRAINT fk_aisle
FOREIGN KEY(aisle_id)
REFERENCES aisles(aisle_id);

ALTER TABLE order_products_train
ADD CONSTRAINT fk_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE order_products_train
ADD CONSTRAINT fk_order
FOREIGN KEY(order_id)
REFERENCES orders(order_id);


-- ALTER TABLE order_products_train
-- ADD CONSTRAINT fk_order
-- FOREIGN KEY(order_id)
-- REFERENCES orders(order_id);

SELECT order_id
FROM order_products_train
WHERE order_id NOT IN (
    SELECT order_id
    FROM orders
)
LIMIT 20;



-- SELECT COUNT(*)
-- FROM order_products_train
-- WHERE order_id NOT IN (
--     SELECT order_id
--     FROM orders
-- );

SELECT
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;
-- 
SELECT
    eval_set,
    COUNT(*) AS total_orders
FROM orders
GROUP BY eval_set;
-- top 10 most ordered products
SELECT
    p.product_name,
    COUNT(*) AS total_orders
FROM order_products_train opt
JOIN products p
ON opt.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC
LIMIT 10;

-- top 10 departments
SELECT
    d.department,
    COUNT(*) AS total_orders
FROM order_products_train opt
JOIN products p
ON opt.product_id = p.product_id
JOIN departments d
ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY total_orders DESC
LIMIT 10;

-- reorder rate 
SELECT
    ROUND(
        100.0 * SUM(reordered) / COUNT(*),
        2
    ) AS reorder_rate
FROM order_products_train;

-- orders by day of week 
SELECT
    order_dow,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_dow
ORDER BY order_dow;

-- top 10 aisles
SELECT
    a.aisle,
    COUNT(*) AS total_orders
FROM order_products_train opt
JOIN products p
ON opt.product_id = p.product_id
JOIN aisles a
ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY total_orders DESC
LIMIT 10;

-- peak ordering hour
SELECT
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC;


-- top customers
SELECT
    user_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY user_id
ORDER BY total_orders DESC
LIMIT 10;

-- avg basket size
SELECT
    ROUND(AVG(product_count),2) AS avg_products_per_order
FROM
(
    SELECT
        order_id,
        COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id
) t;

-- most reordered products
SELECT
    p.product_name,
    SUM(opt.reordered) AS reorder_count
FROM order_products_train opt
JOIN products p
ON opt.product_id = p.product_id
GROUP BY p.product_name
ORDER BY reorder_count DESC
LIMIT 10;