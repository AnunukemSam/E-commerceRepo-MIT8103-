-- MIT 8103 Portfolio 3: BASIC TRANSACTION CONTROL
-- Run against electronics_store_db using pgAdmin.
-- Execute the marked sections separately, using the same connection.
-- These examples use temporary tables and do not modify store orders.

-- Part A: ROLLBACK reverses CREATE TABLE and INSERT.
BEGIN;
CREATE TEMP TABLE transaction_demo (
    id INTEGER PRIMARY KEY,
    description TEXT
);
INSERT INTO transaction_demo (id, description)
VALUES (1, 'Testing transaction rollback');
SELECT * FROM transaction_demo;
ROLLBACK;
SELECT to_regclass('pg_temp.transaction_demo') AS table_after_rollback;
-- Expected: NULL.

-- Part B: COMMIT retains the temporary table within this session.
BEGIN;
CREATE TEMP TABLE transaction_commit_demo (
    id INTEGER PRIMARY KEY,
    description TEXT
);
INSERT INTO transaction_commit_demo (id, description)
VALUES (1, 'Transaction successfully committed');
COMMIT;
SELECT * FROM transaction_commit_demo;

-- Part C: A later ROLLBACK cannot undo a previously committed row.
BEGIN;
INSERT INTO transaction_commit_demo (id, description)
VALUES (2, 'This record will be rolled back');
SELECT * FROM transaction_commit_demo ORDER BY id;
ROLLBACK;
SELECT * FROM transaction_commit_demo ORDER BY id;
-- Expected: only id=1 remains.

DROP TABLE IF EXISTS pg_temp.transaction_commit_demo;

-- NOTE: A temporary table persists only for its database session
-- (unless a different ON COMMIT rule was specified), not across sessions.
