-- MIT 8103 Portfolio 3: CONCURRENT SESSIONS — SESSION A
-- Run in Terminal window A using: psql -d electronics_store_db
-- Coordinate with Session B. Do NOT run the entire file blindly.

SELECT pg_backend_pid() AS session_a_pid;
SELECT product_name, stock_quantity FROM products WHERE sku='LAP-001';
-- Expected starting committed laptop stock after order processing: 3.

BEGIN;
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE sku = 'LAP-001' AND stock_quantity >= 1
RETURNING product_name, stock_quantity;
-- Expected inside A: Laptop Pro = 2.
-- STOP HERE. Keep A's transaction open and continue in Session B.
-- PostgreSQL holds a conflicting row lock on this product.
--
-- Once Session B records its lock-timeout error and ROLLBACKs,
-- run the following in Session A separately:
-- ROLLBACK;
-- SELECT product_name,stock_quantity FROM products WHERE sku='LAP-001';
-- Expected restored stock: 3.
