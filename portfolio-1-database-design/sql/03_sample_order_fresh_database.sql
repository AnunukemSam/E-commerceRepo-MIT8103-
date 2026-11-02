-- Example order for a NEW/EMPTY demonstration database ONLY.
-- Prerequisites: apply 01_schema_reference.sql and 02_reference_data.sql first.
-- Do NOT run this against your existing electronics_store_db: an order was
-- already created there, and this script generates another order on each run.
-- A DO block captures the generated order ID so no IDs are hard-coded.
-- This deliberately creates a PENDING order and PENDING simulated payment;
-- no stock is reduced until successful processing is explored in Portfolio 3.

DO $demo$
DECLARE
    v_customer_id integer;
    v_laptop_id integer;
    v_mouse_id integer;
    v_laptop_price numeric(12,2);
    v_mouse_price numeric(12,2);
    v_order_id integer;
BEGIN
    SELECT customer_id INTO STRICT v_customer_id
    FROM customers WHERE email = 'john.ade@example.com';

    SELECT product_id, price INTO STRICT v_laptop_id, v_laptop_price
    FROM products WHERE sku = 'LAP-001';

    SELECT product_id, price INTO STRICT v_mouse_id, v_mouse_price
    FROM products WHERE sku = 'MOU-001';

    INSERT INTO orders (customer_id, status)
    VALUES (v_customer_id, 'Pending')
    RETURNING order_id INTO v_order_id;

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES
        (v_order_id, v_laptop_id, 2, v_laptop_price),
        (v_order_id, v_mouse_id, 1, v_mouse_price);

    INSERT INTO payments (order_id, amount, payment_method, payment_status, payment_date)
    SELECT v_order_id, SUM(quantity * unit_price), 'Bank Transfer', 'Pending', NULL
    FROM order_items
    WHERE order_id = v_order_id;

    RAISE NOTICE 'Created pending order ID %', v_order_id;
END;
$demo$;
