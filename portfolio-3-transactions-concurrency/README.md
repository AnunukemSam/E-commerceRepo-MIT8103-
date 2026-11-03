# Portfolio 3 — Transactions and Concurrency

**MIT 8103 Advanced Database Systems** · **Case study:** Simulated electronics retailer · **DBMS:** PostgreSQL 18.6

## Start here

[Technical report](docs/portfolio_3_technical_report.md) documents the transaction rollback, automatic failure checks, committed order, and Read Committed/row-locking experiment, together with their limits.

**Original screenshots:** [evidence index](evidence/README.md) (12 authentic PNGs plus explanations). 

## SQL

- [01_transaction_basics.sql](sql/01_transaction_basics.sql): temporary-table BEGIN/COMMIT/ROLLBACK exercises.
- [02_validated_order_processor.sql](sql/02_validated_order_processor.sql): archive of the PL/pgSQL order validation routine.
- [03_failure_rehearsal_steps.sql](sql/03_failure_rehearsal_steps.sql): insufficient-stock failure reproduction notes.
- [04_concurrency_session_a.sql](sql/04_concurrency_session_a.sql): session A, uncommitted inventory update.
- [05_concurrency_session_b.sql](sql/05_concurrency_session_b.sql): session B, Read Committed and lock-timeout demonstration.
- [06_order_state_verification.sql](sql/06_order_state_verification.sql): read-only confirmation of final order, payment, inventory and sales report.

## Critical run-safety note

**Order #1 has already been successfully processed and is now Confirmed.** Do not rerun the archived successful-processing or shortage-test scripts against the current database. The scripts reconstruct the class exercise; they are not intended as an automatic deployment script. Use fresh pending test data or a restored lab snapshot only if deliberately repeating the experiments.

