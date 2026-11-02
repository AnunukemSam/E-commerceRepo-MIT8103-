-- READ-ONLY queries: can run against the current electronics_store_db.
-- Review the actual output and save genuine screenshots/results as evidence.

-- 1. Confirm target database.
SELECT current_database() AS connected_database;

-- 2. List the six application tables.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 3. Inspect declared table constraints.
SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name IN ('customers','categories','products','orders','order_items','payments')
ORDER BY table_name, constraint_type, constraint_name;

-- 4. Validate product-category relationships.
SELECT p.product_id, p.sku, p.product_name, c.category_name,
       p.price, p.stock_quantity
FROM products AS p
JOIN categories AS c ON c.category_id = p.category_id
ORDER BY p.product_id;

-- 5. Show sample customer's orders and all line items.
SELECT o.order_id, c.first_name, c.last_name, o.status,
       p.sku, p.product_name, oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_subtotal
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
WHERE c.email = 'john.ade@example.com'
ORDER BY o.order_id, p.sku;

-- 6. Compare each order's calculated total with its payment record.
-- LEFT JOIN keeps orders with no payment visible.
SELECT o.order_id,
       o.status AS order_status,
       pay.payment_status,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS calculated_total,
       pay.amount AS payment_amount,
       CASE
           WHEN pay.payment_id IS NULL THEN 'NO PAYMENT RECORD'
           WHEN COALESCE(SUM(oi.quantity * oi.unit_price), 0) = pay.amount
               THEN 'MATCH'
           ELSE 'MISMATCH'
       END AS validation_result
FROM orders AS o
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
LEFT JOIN payments AS pay ON pay.order_id = o.order_id
GROUP BY o.order_id, o.status, pay.payment_id, pay.payment_status, pay.amount
ORDER BY o.order_id;

-- 7. Check current inventory quantities.
SELECT sku, product_name, stock_quantity
FROM products
WHERE sku IN ('LAP-001', 'MOU-001')
ORDER BY sku;

-- 8. Find orders without any order items (should be zero in completed records).
SELECT o.order_id, o.status
FROM orders AS o
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE oi.order_item_id IS NULL;

-- 9. Confirm sample payment date remains unset while pending.
SELECT o.order_id, o.status, pay.payment_status, pay.payment_date
FROM orders AS o
JOIN payments AS pay ON pay.order_id = o.order_id
JOIN customers AS c ON c.customer_id = o.customer_id
WHERE c.email = 'john.ade@example.com'
ORDER BY o.order_id;
