-- MIT 8103 Portfolio 3: CONCURRENT SESSIONS — SESSION B
-- Run in SECOND Terminal window: psql -d electronics_store_db
-- Session A must already hold an open transaction after updating LAP-001.
-- Execute in sequence and roll back after the expected timeout.

SELECT pg_backend_pid() AS session_b_pid;
BEGIN;
SHOW transaction_isolation;
-- Expected default: read committed.

SELECT product_name, stock_quantity
FROM products WHERE sku='LAP-001';
-- Expected: Laptop Pro = 3, not uncommitted 2 from A.
-- This ordinary SELECT illustrates avoidance of dirty reads.

SET LOCAL lock_timeout = '3s';

UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE sku='LAP-001' AND stock_quantity >= 1
RETURNING product_name, stock_quantity;
-- Expected error after ~3 seconds:
-- ERROR: canceling statement due to lock timeout
-- The explicit transaction is now aborted; run:
-- ROLLBACK;
--
-- Then return to Session A to ROLLBACK there as well.
-- Verify original committed stock remains 3.
