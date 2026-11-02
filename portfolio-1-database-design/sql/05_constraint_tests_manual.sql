-- Constraint demonstrations performed by the student.
-- IMPORTANT: Statements below intentionally ERROR. They are COMMENTED OUT.
-- To test, copy ONE statement at a time into pgAdmin Query Tool in auto-commit mode.
-- Capture the error message as genuine evidence. Do not run all at once.
-- If testing inside an explicit BEGIN transaction, ROLLBACK after any error.

-- A. Duplicate customer email (requires John to exist):
-- INSERT INTO customers (first_name, last_name, email)
-- VALUES ('Mary', 'Okafor', 'john.ade@example.com');

-- B. Product with invalid category ID:
-- INSERT INTO products (category_id, product_name, sku, price, stock_quantity)
-- VALUES (-999, 'Test Product', 'INVALID-CAT', 100.00, 1);

-- C. Negative stock: requires valid category ID; replace 1 if needed.
-- INSERT INTO products (category_id, product_name, sku, price, stock_quantity)
-- VALUES (1, 'Test Product', 'INVALID-STOCK', 100.00, -5);

-- D. Order referencing nonexistent customer:
-- INSERT INTO orders (customer_id, status)
-- VALUES (-999, 'Pending');

-- E. Order item referencing nonexistent order:
-- INSERT INTO order_items (order_id, product_id, quantity, unit_price)
-- VALUES (-999, -999, 1, 100.00);

-- F. Negative order-item quantity (the CHECK may fail before FKs are evaluated):
-- INSERT INTO order_items (order_id, product_id, quantity, unit_price)
-- VALUES (-999, -999, -2, 100.00);

-- G. Payment for nonexistent order:
-- INSERT INTO payments (order_id, amount, payment_method, payment_status)
-- VALUES (-999, 100.00, 'Bank Transfer', 'Pending');

-- H. Unsupported payment method (CHECK may fail before FK):
-- INSERT INTO payments (order_id, amount, payment_method, payment_status)
-- VALUES (-999, 100.00, 'Bitcoin', 'Pending');

-- To test uq_order_product and UNIQUE(payments.order_id), use an EXISTING
-- order and a matching product ID / existing payment order ID, then attempt
-- an intentional duplicate. Do not guess identifiers; use SELECT first.
