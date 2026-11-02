-- MIT 8103 Portfolio 3: READ-ONLY STATE VERIFICATION
-- Run on electronics_store_db.
-- Order #1 was committed successfully in the original exercise.

SELECT current_database() AS connected_database;

SELECT o.order_id,
       o.status AS order_status,
       pay.payment_status,
       pay.amount,
       p.product_name,
       p.stock_quantity,
       oi.quantity AS ordered_quantity
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
JOIN payments AS pay ON pay.order_id = o.order_id
WHERE o.order_id = 1
ORDER BY p.product_name;

-- Expected after COMMIT:
-- Laptop Pro: stock=3, quantity=2.
-- Wireless Mouse: stock=19, quantity=1.
-- Order status Confirmed; payment status Successful;
-- payment amount 1,725,000.00.

-- Additional independent business report cross-check.
WITH order_totals AS (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM order_items GROUP BY order_id
)
SELECT COUNT(*) AS confirmed_paid_orders,
       COALESCE(SUM(ot.order_total),0) AS confirmed_sales_value
FROM orders AS o
JOIN order_totals AS ot ON ot.order_id=o.order_id
JOIN payments AS pay ON pay.order_id=o.order_id
WHERE o.status='Confirmed' AND pay.payment_status='Successful';
-- Expected with this one completed order: count=1, amount=1,725,000.
