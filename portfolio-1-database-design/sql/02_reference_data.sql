-- Reference data for a FRESH test database.
-- These master-data inserts are safe to repeat where the named UNIQUE keys exist.
-- They do not overwrite records you may have edited.

INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('John', 'Ade', 'john.ade@example.com', '08012345678')
ON CONFLICT (email) DO NOTHING;

INSERT INTO categories (category_name, description)
VALUES
    ('Laptops', 'Portable computing devices'),
    ('Accessories', 'Computer accessories and peripheral devices')
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO products (category_id, product_name, sku, description, price, stock_quantity)
SELECT c.category_id, v.product_name, v.sku, v.description, v.price, v.stock_quantity
FROM (VALUES
    ('Laptops', 'Laptop Pro', 'LAP-001', 'High-performance laptop', 850000.00::numeric, 5),
    ('Accessories', 'Wireless Mouse', 'MOU-001', 'Ergonomic wireless computer mouse', 25000.00::numeric, 20)
) AS v(category_name, product_name, sku, description, price, stock_quantity)
JOIN categories AS c ON c.category_name = v.category_name
ON CONFLICT (sku) DO NOTHING;
