-- MIT 8103 Portfolio 5: run on STANDBY, port 5433.
-- READ-ONLY verification statements are safe to rerun.

SELECT current_database() AS database_name,
       current_setting('port') AS port,
       pg_is_in_recovery() AS is_standby,
       current_setting('transaction_read_only') AS read_only;

SELECT status, sender_host, sender_port
FROM pg_stat_wal_receiver;

SELECT test_id, event_description, created_at
FROM public.portfolio5_replication_test
ORDER BY test_id;

-- Observed: test_id=1, same timestamp and description as primary.
--
-- The following was deliberately attempted ONCE to show read-only behaviour:
-- INSERT INTO public.portfolio5_replication_test (event_description)
-- VALUES ('Attempted write directly to standby');
--
-- Expected and observed:
-- ERROR: cannot execute INSERT in a read-only transaction
--
-- The INSERT stays commented out to make routine review safe.
