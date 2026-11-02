-- MIT 8103 / Portfolio 2
-- Business reporting queries for electronics_store_db.
-- Execute against electronics_store_db, NOT electronics_perf_lab.
-- Read-only; does not confirm orders, change payments or adjust stock.

-- Q1. Customer order history (multi-table INNER JOIN).
SELECT
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.status AS order_status,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS subtotal
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_date DESC, o.order_id, p.product_name;

-- Q2. Order totals and payment status (LEFT JOIN and GROUP BY).
-- Includes orders without an associated payment.
SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    o.status AS order_status,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS order_total,
    pay.payment_status,
    pay.payment_method
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN payments pay ON o.order_id = pay.order_id
GROUP BY o.order_id, c.customer_id, pay.payment_id
ORDER BY o.order_id;

-- Q3. Inventory by product category (LEFT JOIN and aggregation).
-- Inventory value uses current SELLING prices; it is not cost/profit.
SELECT
    c.category_name,
    COUNT(p.product_id) AS total_products,
    COALESCE(SUM(p.stock_quantity), 0) AS total_stock_units,
    COALESCE(SUM(p.price * p.stock_quantity), 0) AS inventory_value
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY inventory_value DESC;

-- Q4. Simulated confirmed sales value: no pending orders counted.
-- This is a classroom business reporting rule, not formal accounting recognition.
WITH order_totals AS (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
)
SELECT
    COUNT(*) AS confirmed_paid_orders,
    COALESCE(SUM(ot.order_total), 0) AS confirmed_revenue
FROM orders o
JOIN order_totals ot ON o.order_id = ot.order_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE o.status = 'Confirmed'
  AND pay.payment_status = 'Successful';

-- For EXPLAIN evidence, prepend the line
-- EXPLAIN (ANALYZE, BUFFERS)
-- to Q1 and Q3 separately. Their plan nodes are documented in
-- docs/experiment_04_join_aggregation.md.
