# Portfolio 2 — Query Processing and Optimisation

**Case study:** Simulated electronics retailer (same six-table schema as Portfolio 1).  
**DBMS:** PostgreSQL 18.6  
**Status:** Technical exercises documented. Final student reflection and optional additional plan screenshots remain for submission review.

## Start here

[Portfolio 2 consolidated technical summary](docs/portfolio_2_consolidated_summary.md) includes scope, query results, indexing results, planner statistics, conclusions, limitations and evidence status.

## Files

- [Four business reports](sql/business_queries.sql) — read-only JOIN and aggregation queries on `electronics_store_db`.
- [Synthetic product data generator](sql/synthetic_product_dataset.sql) — reproducible 20,000-product dataset in `electronics_perf_lab`.
- [Price-index experiment SQL](sql/price_index_experiment.sql) — commands for baseline plans, index verification and controlled comparisons.
- [Experiment 03 benchmark analysis](docs/experiment_03_index_benchmark.md) — performance measurements from price index experiments.
- [Experiment 04 JOIN/aggregation analysis](docs/experiment_04_join_aggregation.md) — pre/post statistics-refresh plan comparison.
- [Evidence screenshots and raw outputs](evidence/) — nine pgAdmin PNGs, post-ANALYZE plan text, five-run timing CSV and evidence index.

## Databases

`electronics_store_db` is the primary electronics store case study. Portfolio 3 has since confirmed the original order; do not rerun processing scripts on the completed order.

`electronics_perf_lab` is an isolated test database holding 20,000 synthetic products for the selective price query. This avoids modifying the original case-study data.

## Findings

- The 20,000-product price query returned 1,000 matching products (5% selectivity).
- After adding a B-tree price index, the observed plan changed from Sequential Scan to Bitmap Index Scan → Bitmap Heap Scan → Sort.
- Across five measurements each, median execution times were **2.186 ms with indexed access** versus **5.126 ms in the forced sequential-access comparison**: a **57.4% lower median** for this query and test environment.
- Refreshing statistics in the original database corrected grossly overestimated cardinalities for two reporting queries (1,360→2 and 280→2 estimated rows; both returned 2 actual rows) and changed the join and aggregation strategies.
- Five-run measurements and isolated single-run timings do not establish universal gains. Index maintenance cost and query selectivity remain important trade-offs.

## Evidence and submission readiness

- [x] Business query SQL and genuine screenshots.
- [x] Synthetic data and benchmark SQL documented.
- [x] Price index execution-plan screenshots.
- [x] Five-run measurements saved as CSV and analysed.
- [x] Pre/post statistics-refresh plan interpretation and post-refresh text evidence.
- [ ] Optional or lecturer-required screenshots of Query 1 and Query 3 plans (currently text evidence).
- [ ] Additional individual run screenshots or raw log export if requested.
- [ ] Student's own reflection, verify accuracy and review LMS formatting.

**AI-use statement:** ChatGPT assisted with explanation, experiment design, analysis and documentation; the student supplied query outputs and measurements. Verify against the local PostgreSQL environment before final assessment.

**Repository is public:** Do not include passwords, account credentials or real customer data.
