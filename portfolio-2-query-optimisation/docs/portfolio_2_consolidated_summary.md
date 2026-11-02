# Portfolio 2 — Query Processing and Optimisation: Consolidated Technical Summary

**MIT 8103 — Advanced Database Systems**  
**Case study:** Simulated electronics retailer, carried forward from Portfolio 1  
**DBMS:** PostgreSQL 18.6  
**Environment:** Local Apple Silicon Mac with pgAdmin 4  
**Status:** Technical experiments documented; final student reflection and some supporting plan screenshots may still be needed.

## 1. Objective

Execute meaningful SQL queries against the electronics retailer's six-table relational design; investigate PostgreSQL execution plans using `EXPLAIN (ANALYZE, BUFFERS)`; evaluate B-tree indexing for a selective product-price query; and document performance results and trade-offs.

## 2. Databases and controlled scope

- **`electronics_store_db`:** Original case study, with fictional customer John Ade, two products, one pending order containing two order items and one pending simulated payment. Used to validate reports and JOIN/aggregation plans.
- **`electronics_perf_lab`:** Separate database with the same six-table design, populated with **20,000 fictional products**. Used for price-range indexing experiments so the original database is undisturbed.

The data-generation SQL is saved as [synthetic_product_dataset.sql](../sql/synthetic_product_dataset.sql), which mirrors the statements previously executed during this course exercise. It is not proof of a fresh rerun.

## 3. Business reports (original database)

The SQL is in [business_queries.sql](../sql/business_queries.sql).

| Business question | PostgreSQL features | Observed result |
|---|---|---|
| Customer order history | Multi-table INNER JOIN, calculated subtotal, sorting | John Ade: two laptop units, one mouse; one pending order |
| Order total and payment | LEFT JOIN, SUM, GROUP BY, COALESCE | ₦1,725,000; order Pending, bank-transfer payment Pending |
| Inventory value by category | LEFT JOIN, COUNT, SUM, GROUP BY | Laptops: 5 units / ₦4,250,000; Accessories: 20 units / ₦500,000 |
| Confirmed, paid orders | CTE, JOIN, WHERE, SUM | Zero qualifying orders and zero confirmed sales value |

The inventory-value calculation uses product **selling price**, not acquisition cost; it should not be presented as profit. A pending order is not included in the project's confirmed-sales report.

Screenshots: [evidence directory](../evidence/).

## 4. Planning statistics

The initial price-filter query in `electronics_store_db` had only two products; its estimated matching rows fell from **50 to 2** after `ANALYZE products;`, compared with one matching record. Both plans used Sequential Scan and Sort.

For the business reports, running `ANALYZE;` on the full original database had a more dramatic impact:

| Query | Estimated rows before | Estimated rows after | Actual rows |
|---|---:|---:|---:|
| Customer order history | 1,360 | 2 | 2 |
| Inventory by category | 280 | 2 | 2 |

- The customer-order query changed from three Hash Joins to three Nested Loops and a Materialize node.
- The category query changed from Hash Left Join / HashAggregate to an equivalent Hash Right Join / Sort / GroupAggregate strategy.
- Both remained very fast; single-run timing differences are too small to establish a statistically meaningful performance change.

See [Experiment 04 analysis](experiment_04_join_aggregation.md) and [post-ANALYZE plan text](../evidence/experiment_04_plans_after_analyze.txt).

## 5. Price-index optimisation experiment

The synthetic data generator assigned 1,000 of 20,000 products (5%) a price of at least ₦100,000. The benchmark query was:

```sql
SELECT product_id, product_name, price, stock_quantity
FROM products
WHERE price >= 100000
ORDER BY price DESC;
```

After baseline measurement, the index `idx_products_price_desc` was created on `products(price DESC)`.

**Observed plan before index:** Sequential Scan then Sort, returning 1,000 matching rows and filtering out 19,000. One run: 7.259 ms.

**Observed plan with index:** Bitmap Index Scan on price index, Bitmap Heap Scan and Sort, returning 1,000 rows. One run: 1.502 ms. Bitmap output did not preserve index order; therefore, a Sort remained required.

### Repeated timings (milliseconds)

| Run | Indexed | Sequential access |
|---|---:|---:|
| 1 | 2.186 | 3.911 |
| 2 | 2.493 | 5.126 |
| 3 | 1.564 | 7.017 |
| 4 | 2.633 | 5.783 |
| 5 | 1.388 | 3.874 |
| **Mean** | **2.053** | **5.142** |
| **Median** | **2.186** | **5.126** |

The indexed query's median execution time was **57.4% lower**, or **2.34× faster by the ratio of medians**. The average reduction was approximately **60.1%**.

The sequential comparison intentionally disabled index-access plans using session-local planner settings; this is **not** the same as dropping the index. Results are descriptive for five executions per strategy and may be influenced by caching, execution order and other system activity.

See [Experiment 03 analysis](experiment_03_index_benchmark.md), [benchmark SQL](../sql/price_index_experiment.sql), and [measurement CSV](../evidence/benchmark_repeat_measurements.csv).

## 6. Interpretation, trade-offs and limitations

1. PostgreSQL may favour sequential scans for small tables; the presence of an index alone does not guarantee its use.
2. Statistics influence row estimates and may change join and aggregation strategies without changes to the SQL.
3. A B-tree price index helped this particular range predicate matching 5% of a synthetic product table.
4. A Bitmap Heap Scan can still require reading many heap blocks; in this experiment, matching products were spread across 343 exact heap blocks.
5. Indexes consume additional disk space and add maintenance costs when indexed data changes.
6. The five-run comparison and two single-run plans do not establish universal performance guarantees or statistically significant differences.
7. JOIN and aggregate plans in the original two-product database primarily demonstrate execution-plan concepts, not a performance bottleneck.

## 7. Evidence and submission checklist

- [x] Four reporting query scripts and result screenshots.
- [x] Small-database initial statistics and price-index plan screenshots.
- [x] Index-benchmark descriptive measurements and CSV.
- [x] Pre-ANALYZE JOIN/aggregation measurements (reported as text in Experiment 04).
- [x] Post-ANALYZE JOIN/aggregation plans (saved as text).
- [x] Synthetic dataset and indexing SQL scripts.
- [ ] Add screenshots of the business JOIN/aggregation EXPLAIN plans if required; currently text evidence is provided.
- [ ] Add screenshots of the five-run benchmark timings or terminal exports if required; currently student-reported CSV and analysis are provided.
- [ ] Confirm all scripts and descriptions match the local implementation and complete a personal reflection in the student's own words.
- [ ] Check this portfolio against any LMS-specific submission format before final submission.

## 8. References and AI declaration

- MIT 8103 course assessment brief.
- PostgreSQL official documentation: https://www.postgresql.org/docs/current/using-explain.html
- PostgreSQL ANALYZE documentation: https://www.postgresql.org/docs/current/sql-analyze.html

**AI use:** ChatGPT assisted with planning the experiments, explaining SQL and execution plans, calculating benchmark summaries, and drafting repository documentation. The SQL executions and timing observations were reported by the student. The student remains responsible for testing the scripts, verifying the evidence and independently explaining the technical decisions.

**Student reflection:** [Write your own reflection on what you learned about EXPLAIN, statistics, B-tree indexing and join/aggregation plan choices, including an actual difficulty encountered and how you checked it.]
