# Portfolio 5 — Distributed and Cloud Database Exercise

**MIT 8103 Advanced Database Systems** · **6 marks**  
**Case study:** Simulated electronics retailer / E-commerce and Inventory Management System  
**Database engine:** PostgreSQL 18.6 (Homebrew, Apple Silicon Mac)  
**Practical approach:** Local primary–standby **physical streaming replication**.

This exercise demonstrates that data committed on a PostgreSQL primary can be replayed by a read-only standby. It also examines asynchronous replication, consistency, availability and the difference between replication and sharding. No cloud service was deployed, and both instances run on one MacBook.

## Start here

- [Technical report](docs/technical_report.md) — observed results, design decisions, limitations, availability/consistency analysis.
- [Reproduction and troubleshooting guide](docs/reproduction_guide.md) — the actual configuration and commands, including the macOS locale fix.
- [Original screenshot evidence](evidence/README.md) — **three unmodified Terminal PNGs** received from the student.
- [Primary health and lag SQL](sql/01_primary_monitoring.sql).
- [Primary-only replication test SQL](sql/02_primary_test.sql).
- [Standby-only verification SQL](sql/03_standby_verification.sql).

## Implemented topology

| Property | Primary | Standby |
| --- | --- | --- |
| Host | 127.0.0.1 | 127.0.0.1 |
| Port | 5432 | 5433 |
| Data directory | /opt/homebrew/var/postgresql@18 | /Users/apple/pg18-standby |
| Access | Read/write | Read-only while in recovery |
| Replication direction | Sends WAL | Receives and replays WAL |
| Mode | Asynchronous | Physical streaming replica |

### Verified outcomes

1. `pg_basebackup` copied the primary cluster and created `standby.signal`.
2. Standby startup required `LC_ALL=C` after a **postmaster became multithreaded** fatal error on macOS.
3. The primary reported `state=streaming`, `sync_state=async` in `pg_stat_replication`.
4. The standby reported `pg_is_in_recovery()=true` and `transaction_read_only=on`.
5. A new table and its test record, inserted on primary port 5432, appeared on standby port 5433 with matching ID and timestamp.
6. A direct standby INSERT was rejected with `ERROR: cannot execute INSERT in a read-only transaction`.
7. A later snapshot of the primary monitoring view reported **0 bytes** of WAL not yet replayed; `replay_lag` was blank/NULL.

## Safety and reproducibility

- **Do not rerun** the full setup against a running standby or overwrite either PostgreSQL data directory.
- Keep this lab bound to localhost. The student's PostgreSQL installation uses `trust` authentication for local host connections. This is **not a production security configuration**.
- The test uses fictional information and avoids altering the retailer's confirmed orders, products, inventory or payments.
- The initial `pg_basebackup` copied **all databases in the PostgreSQL cluster**, not only `electronics_store_db`.
- No separate physical server, cloud deployment, automatic failover, sharding or disaster recovery test is claimed.
- No persistent replication slot was configured in this exercise; a long standby outage can require additional recovery/reinitialisation if needed WAL is recycled.

## Completion

- [x] Physical replication architecture explained.
- [x] Two PostgreSQL instances configured.
- [x] Live asynchronous WAL streaming confirmed.
- [x] Actual primary write observed on standby.
- [x] Standby read-only restrictions tested.
- [x] Replica monitoring and lag example recorded.
- [x] Original screenshots and scripts committed to GitHub.
- [ ] Student's own technical reflection, final rubric review and LMS summary still required.

**Academic integrity:** ChatGPT helped explain, troubleshoot and organise the portfolio. Local commands and original screenshots were supplied by the student; the student should verify and be prepared to explain this work.
