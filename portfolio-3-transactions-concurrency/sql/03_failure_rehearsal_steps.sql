-- MIT 8103 Portfolio 3: INSUFFICIENT STOCK + ATOMIC FAILURE
-- HISTORICAL LAB REPRODUCTION INSTRUCTIONS.
--
-- Requires the PRIOR pending order #1 and stock LAP-001=5, MOU-001=20.
-- The live original order is now Confirmed; DO NOT execute this
-- against the current electronics_store_db.
--
-- Execute each section in sequence, using the SAME database session.
-- If the temporary UPDATE affects no row, ROLLBACK immediately.
--
-- 1) BEGIN;
-- 2) UPDATE products
--    SET stock_quantity = 1
--    WHERE sku = 'LAP-001' AND stock_quantity = 5
--    RETURNING product_name, stock_quantity;
-- 3) Run full DO block from 02_validated_order_processor.sql.
--    EXPECTED ERROR:
--      SQLSTATE P0001: Insufficient stock or missing product
-- 4) ROLLBACK;   -- the explicit transaction is aborted by the error
-- 5) Verify stocks return to 5 and 20; order/payment remain Pending.
--
-- A failed DO statement aborts the enclosing transaction until
-- ROLLBACK; it must not lead to a COMMIT of partial work.

-- Read-only post-test verification example:
SELECT o.order_id, o.status AS order_status,
       pay.payment_status, p.product_name, p.stock_quantity
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
LEFT JOIN payments AS pay ON pay.order_id = o.order_id
WHERE o.order_id = 1
ORDER BY p.product_name;
