# Portfolio 2 — Query Processing and Optimisation

**Database case study:** Simulated electronics retailer (same six-table schema as Portfolio 1).

This portfolio covers SQL business reporting, query plan interpretation, PostgreSQL planner statistics, B-tree indexing and measured performance.

## Files

- [SQL business queries](sql/business_queries.sql) — four read-only reports to run against `electronics_store_db`.
- [Experiment 03 — price-index benchmark](docs/experiment_03_index_benchmark.md) — 20,000-product synthetic `electronics_perf_lab`, before/after plans and five-run comparisons.
- [Experiment 04 — JOINs and aggregation](docs/experiment_04_join_aggregation.md) — documented execution plans from the original small `electronics_store_db`.

## Two database environments

- `electronics_store_db`: original case-study database with one pending order. Use for business reporting. Do not change the pending order just to make revenue positive.
- `electronics_perf_lab`: synthetic performance-testing database, separated to protect original project evidence.

## Evidence status

The SQL scripts and analyses are in GitHub; actual pgAdmin screenshots and any separately saved raw benchmark outputs still need to be reviewed and uploaded under `evidence/`.

### Checklist

- [x] Baseline `EXPLAIN (ANALYZE, BUFFERS)` for small dataset.
- [x] Planner statistics investigation with `ANALYZE products;`.
- [x] 20,000-product dataset, baseline, price-index plan and repeated timing comparison (measurements supplied by student).
- [x] Four SQL business reports returned expected results.
- [x] Two JOIN/aggregation execution plans interpreted and documented.
- [ ] Upload genuine baseline and indexed benchmark screenshots.
- [ ] Upload genuine four-query result screenshots.
- [ ] Upload genuine Q1 and Q3 execution-plan screenshots.
- [ ] Add the exact SQL used for synthetic data generation and all repeat-test evidence.
- [ ] Review statements against screenshots, complete own reflection and prepare final Portfolio 2 summary.

**Public-repository caution:** No passwords, credentials or real customer information.
