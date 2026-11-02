# Portfolio 5 — Reproduction and Troubleshooting Guide

This guide records **what the student actually used** to implement the local replication lab on 2 November 2026. It is an archive for explanation and demonstration, **not** a one-click deployment procedure. Do not blindly rerun the setup against an existing primary/standby.

## 1. Inspect primary (read-only checks)

```bash
psql -d electronics_store_db -c "
SELECT current_setting('port') AS port,
       current_setting('wal_level') AS wal_level,
       current_setting('max_wal_senders') AS max_wal_senders,
       pg_is_in_recovery() AS is_standby;"

psql -d electronics_store_db -c "SHOW data_directory;"
psql -d postgres -c "SHOW listen_addresses;"
psql -d postgres -c "SHOW max_replication_slots;"
lsof -nP -iTCP:5433 -sTCP:LISTEN
du -sh /opt/homebrew/var/postgresql@18
```

Student-observed values: primary port 5432, `wal_level=replica`, `max_wal_senders=10`, `max_replication_slots=10`, primary `pg_is_in_recovery()=false`, data directory `/opt/homebrew/var/postgresql@18`, and loopback-only listening. Port 5433 was initially free.

Check `pg_hba_file_rules` to confirm local replication connections are permitted:

```sql
SELECT line_number, type, database, user_name, address, auth_method
FROM pg_hba_file_rules
ORDER BY line_number;
```

The student had `trust` rules for `host replication` on 127.0.0.1 and ::1. **Do not expose this unauthenticated lab publicly.**

## 2. Create dedicated replication role (one-time)

Performed by a PostgreSQL administrator:

```sql
CREATE ROLE electronics_repl WITH LOGIN REPLICATION;

SELECT rolname, rolcanlogin, rolreplication, rolsuper
FROM pg_roles
WHERE rolname = 'electronics_repl';
```

Observed result: login `true`, replication `true`, superuser `false`. **Role already exists in the student's instance.**

## 3. Take a physical base backup (one-time)

Check that the destination directory does not already exist before running. The student's separate data directory is `$HOME/pg18-standby`.

```bash
"$(brew --prefix postgresql@18)/bin/pg_basebackup" \
  -h 127.0.0.1 \
  -p 5432 \
  -U electronics_repl \
  -D "$HOME/pg18-standby" \
  -Fp \
  -X stream \
  -P \
  -R
```

Observed: `44799/44799 kB (100%), 1/1 tablespace`. The backup contained `standby.signal` and was initially approximately 59 MB.

**Important:** A physical base backup copies the full PostgreSQL database *cluster*, not just the electronics database. `-R` configures the standby to follow the primary. The standby data directory already exists; **never overwrite or reuse the primary directory**.

## 4. Standby-only configuration

The student added these settings to the standby's `postgresql.conf`, not to the primary:

```conf
port = 5433
listen_addresses = 'localhost'
hot_standby = on
```

The effective port was checked before startup with:

```bash
"$(brew --prefix postgresql@18)/bin/postgres" -D "$HOME/pg18-standby" -C port
# 5433
```

## 5. Troubleshooting the macOS startup error

First attempt:

```bash
"$(brew --prefix postgresql@18)/bin/pg_ctl" \
  -D "$HOME/pg18-standby" \
  -l "$HOME/pg18-standby.log" start
```

This failed. The log, retrieved with `tail -n 60 "$HOME/pg18-standby.log"`, showed:

```text
FATAL: postmaster became multithreaded during startup
HINT: Set the LC_ALL environment variable to a valid locale.
```

The student's environment reported `LANG=""`, `LC_CTYPE="UTF-8"` and `LC_ALL=`. The successful corrective command was:

```bash
LC_ALL=C "$(brew --prefix postgresql@18)/bin/pg_ctl" \
  -D "$HOME/pg18-standby" \
  -l "$HOME/pg18-standby.log" start
# waiting for server to start.... done
# server started
```

This set the locale for that command only and did not require recreating the backup or restarting the primary.

## 6. Check replication from both sides (read-only)

On **primary** (5432):

```bash
psql -h 127.0.0.1 -p 5432 -d electronics_store_db -c "
SELECT application_name, client_addr, state, sync_state
FROM pg_stat_replication;"
```

On **standby** (5433):

```bash
psql -h 127.0.0.1 -p 5433 -d electronics_store_db -c "
SELECT current_setting('port') AS port,
       pg_is_in_recovery() AS is_standby,
       current_setting('transaction_read_only') AS read_only;"

psql -h 127.0.0.1 -p 5433 -d electronics_store_db -c "
SELECT status, sender_host, sender_port FROM pg_stat_wal_receiver;"
```

Observed: primary `streaming/async`; standby `is_standby=t`, `read_only=on`, WAL receiver `streaming` from `127.0.0.1:5432`.

## 7. Verify data propagation without touching business tables

The test table was created on the primary only. The INSERT was run on the primary once. The standby SELECT returned the same record and timestamp. A direct standby INSERT failed with a read-only transaction error.

The exact statements are in [primary test](../sql/02_primary_test.sql) and [standby verification](../sql/03_standby_verification.sql). These are **historical test commands**; rerunning the primary INSERT would add a second test row.

## 8. Snapshot of replication lag

```sql
SELECT application_name, state, sync_state,
       pg_size_pretty(
          pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)::bigint
       ) AS wal_not_yet_replayed,
       replay_lag
FROM pg_stat_replication;
```

The student observed `0 bytes` of lag measured in WAL bytes at the snapshot, and a blank/NULL `replay_lag`. This is not a guarantee of synchronous replication.

## 9. Ending the optional lab

The primary is the student's existing Homebrew service and should **not** be stopped as part of this demonstration. If the manually started standby is no longer required, it can be stopped safely with:

```bash
LC_ALL=C "$(brew --prefix postgresql@18)/bin/pg_ctl" \
  -D "$HOME/pg18-standby" stop -m fast
```

Do **not** remove any data directories without an explicit plan and backup check.

## 10. Risks and scope

This is a localhost lab with two instances on one physical MacBook. It is not production HA or disaster recovery. The `trust` rules should not be used on an exposed database. No replication slot was configured or maintained.
