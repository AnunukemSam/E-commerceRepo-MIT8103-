-- MIT 8103 Portfolio 3: VALIDATED ORDER PROCESSING (ARCHIVED LAB SCRIPT)
-- The exact six-table academic case-study design used by the student.
-- This DO block was run inside an explicit transaction, then either
-- ROLLBACK (rehearsal) or COMMIT (successful processing).
--
-- IMPORTANT: Order 1 is ALREADY CONFIRMED in electronics_store_db.
-- DO NOT rerun it on the current completed order. To demonstrate anew,
-- use a restored snapshot/new pending order with matching line items,
-- stock and exactly one pending simulated payment.
--
-- Start explicit BEGIN in the same connection before this block.
-- Inspect results; COMMIT only if validated, otherwise ROLLBACK.

DO $$
DECLARE
    v_order_id INTEGER := 1;
    v_order_status VARCHAR(20);
    v_expected_items INTEGER;
    v_updated_items INTEGER;
    v_payment_count INTEGER;
    v_order_count INTEGER;
    v_order_total NUMERIC(12,2);
BEGIN
    -- Lock the order row and verify its state.
    SELECT status
    INTO v_order_status
    FROM orders
    WHERE order_id = v_order_id
    FOR UPDATE;

    IF v_order_status IS DISTINCT FROM 'Pending' THEN
        RAISE EXCEPTION
            'Order % does not exist or is not Pending',
            v_order_id;
    END IF;

    -- Determine expected line items and purchase amount.
    SELECT
        COUNT(*),
        COALESCE(SUM(quantity * unit_price), 0)
    INTO
        v_expected_items,
        v_order_total
    FROM order_items
    WHERE order_id = v_order_id;

    IF v_expected_items = 0 THEN
        RAISE EXCEPTION 'Order has no items';
    END IF;

    -- Conditional stock reduction: never decrease below zero.
    UPDATE products AS p
    SET stock_quantity = p.stock_quantity - oi.quantity
    FROM order_items AS oi
    WHERE oi.product_id = p.product_id
      AND oi.order_id = v_order_id
      AND p.stock_quantity >= oi.quantity;

    GET DIAGNOSTICS v_updated_items = ROW_COUNT;

    IF v_updated_items <> v_expected_items THEN
        RAISE EXCEPTION
            'Insufficient stock or missing product';
    END IF;

    -- Update the ONE simulated payment to Successful if valid.
    UPDATE payments
    SET
        payment_status = 'Successful',
        payment_date = CURRENT_TIMESTAMP
    WHERE order_id = v_order_id
      AND payment_status = 'Pending'
      AND amount = v_order_total;

    GET DIAGNOSTICS v_payment_count = ROW_COUNT;

    IF v_payment_count <> 1 THEN
        RAISE EXCEPTION 'Payment validation failed';
    END IF;

    -- Confirm the order only after preceding checks succeed.
    UPDATE orders
    SET status = 'Confirmed'
    WHERE order_id = v_order_id
      AND status = 'Pending';

    GET DIAGNOSTICS v_order_count = ROW_COUNT;

    IF v_order_count <> 1 THEN
        RAISE EXCEPTION 'Order confirmation failed';
    END IF;

    RAISE NOTICE
        'Order % validated successfully. Total: %',
        v_order_id,
        v_order_total;
END $$;

-- The DO block alone does NOT commit the enclosing transaction.
-- Use explicit COMMIT only after verifying a successful run;
-- use ROLLBACK for the rehearsal or on any error.
-- This is a simulated payment, never a real payment gateway.
