
USE retail_sales_db;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
SHOW TABLES;

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (order_id, product_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
SHOW TABLES;


USE retail_sales_db;

INSERT INTO customers
(customer_name, email, city, signup_date)
VALUES
('Arun', 'arun@gmail.com', 'Chennai', '2026-01-10'),
('Priya', 'priya@gmail.com', 'Coimbatore', '2026-01-15'),
('Karthik', 'karthik@gmail.com', 'Chennai', '2026-02-05'),
('Divya', 'divya@gmail.com', 'Madurai', '2026-02-20'),
('Rahul', 'rahul@gmail.com', 'Salem', '2026-03-01');

SELECT * FROM customers;


INSERT INTO products
(product_name, category, unit_price, stock_quantity)
VALUES
('Laptop', 'Electronics', 50000.00, 10),
('Headphones', 'Electronics', 2000.00, 25),
('Office Chair', 'Furniture', 7000.00, 15),
('Notebook', 'Stationery', 100.00, 100),
('Keyboard', 'Electronics', 1500.00, 30);

SELECT * FROM products;


INSERT INTO orders
(customer_id, order_date, order_status)
VALUES
(1, '2026-03-05', 'Delivered'),
(2, '2026-03-07', 'Delivered'),
(1, '2026-03-10', 'Delivered'),
(3, '2026-03-12', 'Pending'),
(4, '2026-03-15', 'Delivered'),
(5, '2026-03-18', 'Cancelled');

SELECT 
    *
FROM
    orders
INSERT INTO orders
(customer_id, order_date, order_status)
VALUES
(1, '2026-03-05', 'Delivered'),
(2, '2026-03-07', 'Delivered'),
(1, '2026-03-10', 'Delivered'),
(3, '2026-03-12', 'Pending'),
(4, '2026-03-15', 'Delivered'),
(5, '2026-03-18', 'Cancelled');

SELECT * FROM orders;


INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 50000.00),
(1, 2, 2, 2000.00),
(2, 4, 5, 100.00),
(2, 5, 1, 1500.00),
(3, 3, 1, 7000.00),
(3, 2, 1, 2000.00),
(4, 1, 1, 50000.00),
(5, 4, 10, 100.00),
(6, 5, 2, 1500.00);

SELECT * FROM order_items;

SELECT SUM(quantity * unit_price) AS total_revenue
FROM order_items;

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;
SELECT * FROM order_items;


SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1;

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 3;

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS sales_rank
FROM product_sales;


WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_spent,
    DENSE_RANK() OVER (
        ORDER BY total_spent DESC
    ) AS customer_rank
FROM customer_sales
ORDER BY customer_rank;

WITH customer_sales AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name
),
ranked_customers AS (
    SELECT
        customer_name,
        total_spent,
        DENSE_RANK() OVER (
            ORDER BY total_spent DESC
        ) AS customer_rank
    FROM customer_sales
)
SELECT *
FROM ranked_customers
WHERE customer_rank <= 2
ORDER BY customer_rank;

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
ranked_products AS (
    SELECT
        product_name,
        category,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM product_sales
)
SELECT *
FROM ranked_products
WHERE product_rank = 1
ORDER BY category;
INSERT INTO orders (customer_id, order_date, order_status)
VALUES
(2, '2026-01-12', 'Delivered'),
(3, '2026-02-10', 'Delivered'),
(5, '2026-02-18', 'Delivered');

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
(7, 5, 2, 1500.00),
(8, 2, 3, 2000.00),
(9, 4, 20, 100.00);
SELECT order_id, customer_id, order_date, order_status
FROM orders
ORDER BY order_date;
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY month) AS previous_month_revenue
FROM monthly_sales
ORDER BY month;
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
revenue_comparison AS (
    SELECT
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (ORDER BY month)
            AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    month,
    monthly_revenue,
    previous_month_revenue,
    ROUND(
        (monthly_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY month;
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_delivered_orders,
    CASE
        WHEN COUNT(o.order_id) > 1 THEN 'Repeat Customer'
        WHEN COUNT(o.order_id) = 1 THEN 'One-time Customer'
        ELSE 'No Delivered Orders'
    END AS customer_type
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Delivered'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_delivered_orders DESC;
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spending,
    ROUND(
        AVG(oi.quantity * oi.unit_price),
        2
    ) AS avg_line_item_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spending DESC;
WITH order_revenue AS (
    SELECT
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.order_id, o.order_date
)
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(order_id) AS total_orders,
    SUM(order_value) AS total_revenue,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_revenue
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
SELECT *
FROM customers
WHERE customer_name IS NULL
   OR email IS NULL
   OR city IS NULL
   OR signup_date IS NULL;
SELECT *
FROM products
WHERE unit_price < 0
   OR stock_quantity < 0
   OR unit_price IS NULL
   OR stock_quantity IS NULL;
   
SELECT *
FROM order_items
WHERE quantity <= 0
   OR unit_price < 0
   OR quantity IS NULL
   OR unit_price IS NULL;
   
SELECT
    email,
    COUNT(*) AS email_count
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;

SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.order_date,
    o.order_status
ORDER BY order_total DESC;

SELECT oi.*
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_id IS NULL
   OR p.product_id IS NULL;


SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_revenue DESC
LIMIT 5;

SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT o.customer_id) AS customers_with_delivered_orders,
    SUM(oi.quantity * oi.unit_price) AS total_delivered_revenue,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(
        SUM(oi.quantity * oi.unit_price)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered';
SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items;

SELECT
    o.order_id,
    o.order_status,
    COUNT(oi.order_id) AS item_rows
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_status
ORDER BY o.order_id;

SELECT DATABASE();

SHOW DATABASES;
USE retail_sales_db;
SHOW TABLES;

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

INSERT INTO customers
    (customer_name, email, city, signup_date)
VALUES
    ('Arun', 'arun@gmail.com', 'Chennai', '2026-01-10'),
    ('Priya', 'priya@gmail.com', 'Coimbatore', '2026-01-15'),
    ('Karthik', 'karthik@gmail.com', 'Chennai', '2026-02-05'),
    ('Divya', 'divya@gmail.com', 'Madurai', '2026-02-20'),
    ('Rahul', 'rahul@gmail.com', 'Salem', '2026-03-01');
    
SELECT * FROM customers;

INSERT INTO products
    (product_name, category, unit_price, stock_quantity)
VALUES
    ('Laptop', 'Electronics', 50000.00, 10),
    ('Headphones', 'Electronics', 2000.00, 25),
    ('Office Chair', 'Furniture', 7000.00, 15),
    ('Notebook', 'Stationery', 100.00, 100),
    ('Keyboard', 'Electronics', 1500.00, 30);
    
SELECT * FROM products;

INSERT INTO orders (customer_id, order_date, order_status)
VALUES
(1, '2026-01-12', 'Delivered'),
(2, '2026-02-10', 'Delivered'),
(3, '2026-02-18', 'Delivered'),
(1, '2026-03-05', 'Delivered'),
(2, '2026-03-07', 'Delivered'),
(1, '2026-03-10', 'Delivered'),
(3, '2026-03-12', 'Pending'),
(4, '2026-03-15', 'Delivered'),
(5, '2026-03-18', 'Cancelled');

SELECT * FROM orders ORDER BY order_id;

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
(1, 5, 2, 1500.00),
(2, 2, 3, 2000.00),
(3, 4, 20, 100.00),
(4, 1, 1, 50000.00),
(4, 2, 2, 2000.00),
(5, 4, 5, 100.00),
(5, 5, 1, 1500.00),
(6, 3, 1, 7000.00),
(6, 2, 1, 2000.00),
(7, 1, 1, 50000.00),
(8, 4, 10, 100.00),
(9, 5, 2, 1500.00);
USE retail_sales_db;

SELECT order_id, customer_id, order_date, order_status
FROM orders
ORDER BY order_id;
SELECT product_id, product_name
FROM products
ORDER BY product_id;

SELECT order_id, customer_id, order_date, order_status
FROM retail_sales_db.orders
ORDER BY order_id;
INSERT INTO order_items
    (order_id, product_id, quantity, unit_price)
VALUES
(4, 5, 2, 1500.00),
(5, 2, 3, 2000.00),
(6, 4, 20, 100.00),
(7, 1, 1, 50000.00),
(7, 2, 2, 2000.00),
(8, 4, 5, 100.00),
(8, 5, 1, 1500.00),
(9, 3, 1, 7000.00),
(9, 2, 1, 2000.00),
(10, 1, 1, 50000.00),
(11, 4, 10, 100.00),
(12, 5, 2, 1500.00);

SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT o.customer_id) AS customers_with_delivered_orders,
    SUM(oi.quantity * oi.unit_price) AS total_delivered_revenue,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(
        SUM(oi.quantity * oi.unit_price)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered';

USE retail_sales_db;

SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT o.customer_id) AS customers_with_delivered_orders,
    SUM(oi.quantity * oi.unit_price) AS total_delivered_revenue,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(
        SUM(oi.quantity * oi.unit_price)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered';
USE retail_sales_db;

SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    SUM(oi.quantity) AS total_units_sold,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    ROUND(
        SUM(oi.quantity * oi.unit_price) /
        COUNT(DISTINCT o.order_id), 2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered';

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;


SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;


SELECT
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;


SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT
    c.city,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city
ORDER BY total_revenue DESC;


WITH product_sales AS (
    SELECT
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_percentage
FROM product_sales
ORDER BY revenue DESC;


WITH product_sales AS (
    SELECT
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS product_rank
FROM product_sales;


WITH product_sales AS (
    SELECT
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_name,
    category,
    revenue,
    RANK() OVER (
        PARTITION BY category
        ORDER BY revenue DESC
    ) AS category_rank
FROM product_sales
ORDER BY category, category_rank;


WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
sales_comparison AS (
    SELECT
        sales_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    sales_month,
    revenue,
    previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percentage
FROM sales_comparison
ORDER BY sales_month;


WITH customer_sales AS (
    SELECT
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_spent,
    CASE
        WHEN total_spent >= 10000 THEN 'High Value'
        ELSE 'Regular'
    END AS customer_category
FROM customer_sales
ORDER BY total_spent DESC;


SELECT
    c.customer_id,
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;
