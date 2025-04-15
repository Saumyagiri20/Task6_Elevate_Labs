CREATE DATABASE sales_db;
USE sales_db;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    amount DECIMAL(10, 2),
    product_id INT
);

INSERT INTO orders (order_id, order_date, amount, product_id) VALUES
(1, '2023-01-15', 250.00, 101),
(2, '2023-01-20', 300.00, 102),
(3, '2023-02-05', 150.00, 103),
(4, '2023-02-25', 500.00, 104),
(5, '2023-03-10', 700.00, 105),
(6, '2023-03-15', 100.00, 106),
(7, '2024-01-10', 400.00, 107),
(8, '2024-01-25', 350.00, 108),
(9, '2024-02-05', 200.00, 109),
(10, '2024-02-20', 250.00, 110);

SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    SUM(amount) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY
    order_year,
    order_month;

WITH monthly_data AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        DATE_FORMAT(MIN(order_date), '%M') AS month_name, -- use MIN to keep only grouped values
        SUM(amount) AS total_revenue,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(AVG(amount), 2) AS avg_order_value
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
),
with_cumulative AS (
    SELECT *,
        SUM(total_revenue) OVER (PARTITION BY order_year ORDER BY order_month) AS cumulative_revenue,
        LAG(total_revenue) OVER (PARTITION BY order_year ORDER BY order_month) AS previous_month_revenue
    FROM monthly_data
)
SELECT *,
    ROUND(
        (total_revenue - previous_month_revenue) * 100.0 / NULLIF(previous_month_revenue, 0), 2
    ) AS revenue_growth_percent,
    ROUND(
        AVG(total_revenue) OVER (PARTITION BY order_year ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2
    ) AS rolling_3_month_avg
FROM with_cumulative
ORDER BY order_year, order_month;








