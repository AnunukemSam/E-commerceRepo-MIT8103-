# Portfolio 5 — Technical Report: PostgreSQL Streaming Replication

**Module:** MIT 8103 Advanced Database Systems  
**Portfolio value:** 6 marks  
**Case study:** Fictional electronics retailer: E-commerce and Inventory Management System  
**Date of test:** 2 November 2026  
**DBMS:** PostgreSQL 18.6, Homebrew installation on Apple Silicon M1 Mac  
**Topic:** Distributed/cloud databases — hands-on replication and consistency, with availability and sharding analysis.

## 1. Business scenario and aim

The retailer already has a six-table PostgreSQL database with customers, categories, products, orders, order items and simulated payments. Earlier portfolio work created a confirmed fictional order, performed transaction validation and demonstrated inventory updates.

The business may want to run reports on a separate read-only copy of the database, while retaining a primary database for checkout and inventory-changing operations. To study this scenario, the student configured **physical streaming replication** from an existing PostgreSQL instance to a second local PostgreSQL instance.

The main objectives were to: (1) prepare a standby from a consistent backup, (2) observe the WAL streaming connection, (3) write a test record to the primary and retrieve it from the standby, (4) test that writes are prohibited on the standby, and (5) interpret the replication and consistency implications.

## 2. Architecture and configuration

```text
            Fictional electronics retailer
                       |
             Primary PostgreSQL 18.6
            127.0.0.1:5432 (read/write)
            electronics_store_db
                       |
              Physical WAL streaming
              (async; one-way flow)
                       |
             Standby PostgreSQL 18.6
            127.0.0.1:5433 (read-only)
            electronics_store_db
```

Both servers run on **the same MacBook**. They are separate PostgreSQL server instances with independent data directories, **not** independent physical nodes or availability zones.

Observed configuration:

| Setting | Observed result |
| --- | --- |
| Primary port | 5432 |
| Primary data directory | `/opt/homebrew/var/postgresql@18` |
| `wal_level` | `replica` |
| `max_wal_senders` | `10` |
| `max_replication_slots` | `10` |
| `pg_is_in_recovery()` on primary | `false` |
| Standby port | 5433 |
| Standby directory | `/Users/apple/pg18-standby` |
| `pg_is_in_recovery()` on standby | `true` |
| Standby transaction read-only | `on` |
| Streaming account | `electronics_repl` (LOGIN and REPLICATION, non-superuser) |
| Primary bind addresses | localhost: `127.0.0.1` and `::1` |
| Local host authentication | `trust` (local lab only; insecure on shared/exposed hosts) |

The primary data directory was measured at approximately **77 MB**; the standby directory was approximately **59 MB** after base backup. A PostgreSQL physical backup copies the database **cluster**, not a single database. The initial `pg_basebackup` output was `44799/44799 kB (100%), 1/1 tablespace`; `standby.signal` was present after backup.

## 3. Implementation: initial standby and startup problem

The student created the least-privilege replication role, used `pg_basebackup` to copy the existing cluster to a new directory, and used `-R` to prepare the standby connection and `standby.signal`. Port 5433, localhost listening and `hot_standby=on` were configured in the standby's `postgresql.conf`.

The first attempt to start the standby failed. Its log reported:

```text
FATAL: postmaster became multithreaded during startup
HINT: Set the LC_ALL environment variable to a valid locale.
```

The student's `locale` output showed an empty `LANG`, `LC_CTYPE="UTF-8"`, and no `LC_ALL`. Rather than discard the backup or alter the working primary, the student restarted the standby using a valid, command-scoped locale:

```bash
LC_ALL=C "$(brew --prefix postgresql@18)/bin/pg_ctl" \
  -D "$HOME/pg18-standby" \
  -l "$HOME/pg18-standby.log" start
```

This succeeded: `server started`. This demonstrates a log-led, minimal-scope troubleshooting procedure. The exact root cause behind macOS locale thread initialisation was not independently isolated beyond the diagnostic and successful workaround.

## 4. Streaming verification

The student connected to the standby and checked its operating state. The result confirmed:

```text
database_name         port    is_standby    read_only
electronics_store_db  5433    t             on
```

On the primary, `pg_stat_replication` returned:

```text
application_name    client_addr    state        sync_state
walreceiver         127.0.0.1      streaming    async
```

On the standby, `pg_stat_wal_receiver` showed:

```text
status       sender_host    sender_port
streaming    127.0.0.1      5432
```

These observations confirm an active one-way WAL stream between two independent PostgreSQL instances. See the [original monitoring screenshot](../evidence/02-standby-startup-and-streaming-status.png).

## 5. Data replication test and expected standby rejection

To avoid changing the retailer's order and payment records, the student created a dedicated table `public.portfolio5_replication_test` on the primary (port 5432), then inserted one test event. The primary returned `INSERT 0 1` and:

| Field | Value |
| --- | --- |
| `test_id` | 1 |
| `event_description` | Electronics store replication test - Primary to Standby |
| `created_at` | 2026-11-02 19:35:59.169023+01 |

The student then connected to the standby on **port 5433** and selected from the test table. The same ID, event description and creation timestamp appeared, **without inserting the row separately on the standby**. This is direct evidence that the committed test change was transferred and replayed.

A direct INSERT attempted against port 5433 returned the expected error:

```text
ERROR: cannot execute INSERT in a read-only transaction
```

The student therefore demonstrated both replicated read access and the standby's write restrictions. See the [original primary/standby test screenshot](../evidence/01-primary-insert-standby-readonly-test.png).

## 6. Replication lag and consistency

A subsequent primary-side monitoring query compared the current primary WAL position with the standby's replay position using `pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)`. At the sampled time the output was:

```text
application_name    state       sync_state    wal_not_yet_replayed    replay_lag
walreceiver         streaming   async         0 bytes                [NULL/blank]
```

See [lag screenshot](../evidence/03-replication-lag-zero-bytes.png).

This does **not** prove continuous zero lag. It only shows the standby was caught up at that sampled moment. The `replay_lag` column can be NULL when no recent timing sample is available, rather than implying an error.

Because replication is **asynchronous**, a primary commit may be acknowledged before its changes are replayed on the standby. As a result:

- A standby reporting query may briefly return slightly older results.
- If the primary fails before a recently committed change reaches the standby, that acknowledged change may be unavailable after promotion/failover.
- Orders, payments and inventory changes should be routed to the primary. Read-only reports that tolerate short delays are reasonable candidates for the standby.

The exercise did not measure the worst-case lag, test a network partition or demonstrate synchronous commit.

## 7. Replication, sharding, availability and durability

| Concept | Explanation and applicability |
| --- | --- |
| Replication | Maintaining a copy of the database. **Implemented and tested** through physical WAL streaming. |
| Sharding | Distributing different subsets of data across database nodes. **Discussed, not implemented**; adds routing and cross-shard query complexity, and is not required for this small lab. |
| Availability | A standby can be an ingredient in a more available system, but requires failure detection, promotion, application reconnection and monitoring. **No automatic failover was configured**. |
| Consistency | The replica may temporarily lag under asynchronous replication; the lag query is a snapshot, not a continuous guarantee. |
| Durability | Committed data is WAL-logged on the primary and replicated asynchronously. Replication does not replace backups; possible loss of unreplicated acknowledged commits must be considered. |

**Critical limitation:** Because primary and standby run on the **same MacBook**, they share the same machine, power, storage and failure domain. This is a learning demonstration of replication, **not** production disaster recovery, a geographically distributed cluster or cloud deployment.

## 8. Security and operational trade-offs

The primary's `pg_hba.conf` used `trust` for connections from `127.0.0.1` and `::1`. This is acceptable only for a controlled, single-user localhost lab. A deployed environment should use appropriate authentication, roles, network segmentation, transport protection and operational monitoring.

No permanent replication slot was created. This avoids an abandoned slot accumulating WAL indefinitely if the standby is not running. However, with no slot or WAL archive retention policy, a long outage may allow the primary to recycle WAL that the standby still needs, potentially requiring a fresh base backup. This trade-off is documented rather than claimed as a production-ready setting.

There were no cloud charges and no public network exposure as part of the experiment.

## 9. Conclusion and personal evaluation

The student successfully implemented a second local PostgreSQL instance, configured physical asynchronous streaming replication, verified matching primary/standby results, and showed that a standby rejects writes. The exercise connects replication technology to a realistic retail requirement: separating operational writes from read-only reporting.

**Personal reflection — to be completed by the student in their own words:** Discuss what you understood about WAL after observing the two PostgreSQL instances; how you investigated the locale error; what the zero-byte lag observation does and does not mean; why a same-device standby cannot offer independent disaster recovery; and why you would or would not choose asynchronous replication for order reporting.

## 10. References and AI-use disclosure

- PostgreSQL Documentation, Warm Standby and Streaming Replication: https://www.postgresql.org/docs/18/warm-standby.html
- PostgreSQL Documentation, `pg_basebackup`: https://www.postgresql.org/docs/18/app-pgbasebackup.html
- PostgreSQL Documentation, Streaming Replication Statistics: https://www.postgresql.org/docs/18/monitoring-stats.html
- PostgreSQL Documentation, Client Authentication: https://www.postgresql.org/docs/18/auth-pg-hba-conf.html

**AI use:** ChatGPT helped plan the lab, explain PostgreSQL concepts, diagnose startup logs, interpret user-provided command outputs, and draft the repository documentation. The PostgreSQL commands were run on the student's own Mac and the screenshots were supplied by the student. The student should personally review the report and provide their own reflection before submission.
