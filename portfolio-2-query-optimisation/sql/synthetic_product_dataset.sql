-- MIT 8103 | Portfolio 2 | Synthetic product dataset
-- Run only against the separate electronics_perf_lab database.
-- Prerequisite: create the same six-table structure as Portfolio 1.
-- This script reproduces the 20,000-product test dataset; do not
-- run against the original electronics_store_db case-study database.
-- No real customers or transactions are inserted.

BEGIN;
DO $guard$
BEGIN
    IF current_database() <> 'electronics_perf_lab' THEN
        RAISE EXCEPTION 'Wrong database: expected electronics_perf_lab, got %', current_database();
    END IF;
END
$guard$;

INSERT INTO categories (category_name, description)
VALUES
    ('Laptops', 'Portable computing devices'),
    ('Accessories', 'Computer accessories and peripherals')
ON CONFLICT (category_name) DO NOTHING;

-- Every 20th product is high-priced, giving 1,000 out of 20,000.
-- Unique synthetic SKUs permit safe repeat execution without duplicates.
INSERT INTO products (
    category_id, product_name, sku, description, price, stock_quantity
)
SELECT
    c.category_id,
    CASE WHEN g.n % 20 = 0
         THEN 'Performance Laptop ' || g.n
         ELSE 'Performance Accessory ' || g.n END,
    'PERF-' || LPAD(g.n::text, 5, '0'),
    'Synthetic product for query optimisation testing',
    CASE WHEN g.n % 20 = 0
         THEN 150000 + (g.n % 500) * 1000
         ELSE 5000 + (g.n % 80) * 500 END,
    10 + (g.n % 91)
FROM generate_series(1, 20000) AS g(n)
JOIN categories AS c
  ON c.category_name =
    CASE WHEN g.n % 20 = 0 THEN 'Laptops' ELSE 'Accessories' END
ON CONFLICT (sku) DO NOTHING;

COMMIT;

-- Analyse the table before inspecting estimated plan costs/cardinality.
ANALYZE products;

-- Expect exactly 20,000 products, 1,000 expensive, 19,000 others
-- if starting with an empty performance-products table.
SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE price >= 100000) AS expensive_products,
    COUNT(*) FILTER (WHERE price < 100000) AS other_products
FROM products;

-- Additional category distribution check.
SELECT
    c.category_name, COUNT(p.product_id) AS product_count
FROM categories AS c
LEFT JOIN products AS p ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;

-- NOTE: The SQL reproduces the generator used in the tutoring workflow.
-- This commit does not represent a new execution on the student's Mac.
