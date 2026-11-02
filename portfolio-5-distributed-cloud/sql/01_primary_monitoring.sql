-- MIT 8103 Portfolio 5: execute on PRIMARY, port 5432.
-- READ-ONLY monitoring. Database: electronics_store_db.

SELECT current_database() AS database_name,
       current_setting('port') AS port,
       current_setting('wal_level') AS wal_level,
       current_setting('max_wal_senders') AS max_wal_senders,
       pg_is_in_recovery() AS is_standby;

SELECT application_name, client_addr, state, sync_state,
       sent_lsn, write_lsn, flush_lsn, replay_lsn
FROM pg_stat_replication;

-- Snapshot only: async standby may lag at a different time.
SELECT application_name, state, sync_state,
       pg_size_pretty(
          pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)::bigint
       ) AS wal_not_yet_replayed,
       replay_lag
FROM pg_stat_replication;
