-- MIT 8103 Portfolio 5: executed ONCE on PRIMARY, port 5432.
-- ARCHIVED WRITE EXPERIMENT. Do not blindly rerun:
-- the table and first test row already exist in electronics_store_db.
-- No business order/inventory/payment table is changed.

CREATE TABLE IF NOT EXISTS public.portfolio5_replication_test (
    test_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO public.portfolio5_replication_test (event_description)
VALUES ('Electronics store replication test - Primary to Standby')
RETURNING test_id, event_description, created_at;

-- Observed result in the original experiment:
-- test_id = 1
-- created_at = 2026-11-02 19:35:59.169023+01
-- INSERT 0 1
