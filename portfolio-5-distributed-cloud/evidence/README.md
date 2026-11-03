# Portfolio 5 — Original screenshot evidence


| Screenshot | What is visible |
| --- | --- |
| [01-primary-insert-standby-readonly-test.png](01-primary-insert-standby-readonly-test.png) | \`CREATE TABLE\` on port 5432, successful primary INSERT into \`portfolio5_replication_test\`, matching row retrieved from standby port 5433, and the expected read-only INSERT error on port 5433. |
| [02-standby-startup-and-streaming-status.png](02-standby-startup-and-streaming-status.png) | Successful standby startup using \`LC_ALL=C\`; standby identity on port 5433 (\`is_standby=t\`, read-only); \`pg_stat_replication\` reporting streaming/async; standby WAL receiver streaming from 127.0.0.1:5432. |
| [03-replication-lag-zero-bytes.png](03-replication-lag-zero-bytes.png) | Primary-side lag monitoring: WAL not yet replayed = \`0 bytes\` at the observed instant, \`sync_state=async\`, and \`replay_lag\` blank/NULL. |


## Interpretation limits

- Zero WAL difference is **one measurement**, not a continuous lag SLA or proof of synchronous replication.
- Two instances on one laptop are not a resilient distributed system across different failure domains.
- The first startup attempt's failure is documented from copied PostgreSQL log output; the successful subsequent start is shown in the second screenshot.

