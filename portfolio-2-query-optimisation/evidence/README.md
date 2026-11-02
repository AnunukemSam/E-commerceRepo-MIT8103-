# Portfolio 2 — Evidence Screenshots

The nine PNG images here are exact copies of screenshots supplied by the student from pgAdmin 4 (original bytes preserved). Each filename identifies the relevant experiment.

| Screenshot | Evidence |
|---|---|
| [01-small-db-table-row-counts.png](01-small-db-table-row-counts.png) | Row counts in electronics_store_db |
| [02-small-db-query-plan-before-analyze.png](02-small-db-query-plan-before-analyze.png) | Small database query plan before ANALYZE |
| [03-small-db-query-plan-after-analyze.png](03-small-db-query-plan-after-analyze.png) | Small database plan after ANALYZE |
| [04-perf-lab-baseline-without-price-index.png](04-perf-lab-baseline-without-price-index.png) | 20,000-product baseline sequential scan |
| [05-perf-lab-after-price-index.png](05-perf-lab-after-price-index.png) | Price-index bitmap plan |
| [06-q1-customer-order-history.png](06-q1-customer-order-history.png) | Customer order history |
| [07-q2-order-total-and-payment.png](07-q2-order-total-and-payment.png) | Pending order total and payment |
| [08-q3-category-inventory.png](08-q3-category-inventory.png) | Inventory totals by category |
| [09-q4-confirmed-sales.png](09-q4-confirmed-sales.png) | Confirmed sales total |

## Additional evidence still required

- The customer-order-history and inventory JOIN/aggregation execution plans were supplied as text; equivalent screenshots are **not** among these nine PNGs.
- The five-run price-index and sequential timing measurements were supplied as text and documented in `../docs/experiment_03_index_benchmark.md`, not as screenshots.
- The exact synthetic data generation SQL should be added to `../sql/` and the final academic reflection verified.

**Privacy:** The screenshots use a fictional customer (John Ade). Because the repository is public, review uploaded images for personal or sensitive data before final submission.
