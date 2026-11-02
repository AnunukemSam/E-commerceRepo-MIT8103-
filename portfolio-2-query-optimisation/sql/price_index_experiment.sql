-- MIT 8103 | Portfolio 2 | Price index experiment
-- Prerequisite: electronics_perf_lab with 20,000 synthetic products.
-- This file documents the SQL used for the benchmark. Run each
-- indicated section separately in the correct order in pgAdmin.
-- Do NOT run on electronics_store_db.

-- 1. Baseline, BEFORE creating a price index:
EXPLAIN (ANALYZE, BUFFERS)
SELECT product_id, product_name, price, stock_quantity
FROM products
WHERE price >= 100000
ORDER BY price DESC;

-- 2. Create the experiment index AFTER saving the baseline.
-- Skip this if idx_products_price_desc already exists:
-- CREATE INDEX idx_products_price_desc ON products (price DESC);

-- 3. Verify existing indexes:
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'products'
ORDER BY indexname;

-- 4. Indexed access: rerun the identical query five times.
-- Record the 'Execution Time' from EACH EXPLAIN output.
EXPLAIN (ANALYZE, BUFFERS)
SELECT product_id, product_name, price, stock_quantity
FROM products
WHERE price >= 100000
ORDER BY price DESC;

-- 5. Sequential-access comparison: use one pgAdmin query session,
-- run BEGIN + SET LOCAL together, then run the same query five times
-- BEFORE executing ROLLBACK. Do NOT execute this entire file at once.
-- BEGIN;
-- SET LOCAL enable_indexscan = off;
-- SET LOCAL enable_bitmapscan = off;
-- SET LOCAL enable_indexonlyscan = off;
--
-- EXPLAIN (ANALYZE, BUFFERS)
-- SELECT product_id, product_name, price, stock_quantity
-- FROM products
-- WHERE price >= 100000
-- ORDER BY price DESC;
--
-- ROLLBACK;

-- Verify the chosen scan type during the forced-comparison runs.
-- Planner controls are not equivalent to physically dropping an index.
-- Captured before and after plans, recorded timings and limitations
-- are documented under docs/ and evidence/.
