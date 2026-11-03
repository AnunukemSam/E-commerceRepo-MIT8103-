# Portfolio 2 — Experiment 03: Price Index Benchmark

**Course:** MIT 8103 — Advanced Database Systems  
**Case study:** E-commerce and Inventory Management System (simulated electronics retailer)  
**Test database:** `electronics_perf_lab` (PostgreSQL 18.6)  

## 1. Objective and hypothesis

Measure the impact of a B-tree index on the `products.price` column for a range-filtered, descending-price product query. The hypothesis is that the index can reduce elapsed execution time when a relatively small subset of products qualifies.

This test is performed in the separate `electronics_perf_lab` database to preserve the original `electronics_store_db` and Portfolio 1 data.

## 2. Dataset and query

The laboratory contains 20,000 synthetic products. The product-generation script was designed so that 1,000 products (5%) have `price >= 100000`, while 19,000 products (95%) do not. The student reported that the dataset counts were verified.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    product_id,
    product_name,
    price,
    stock_quantity
FROM products
WHERE price >= 100000
ORDER BY price DESC;
```

**Index created for the experiment:**

```sql
CREATE INDEX idx_products_price_desc
ON products (price DESC);
```

**Access-method comparison:** With the index available, run the query normally. To obtain a sequential-access comparison without dropping the index, run the query in the same PostgreSQL session inside:

```sql
BEGIN;
SET LOCAL enable_indexscan = off;
SET LOCAL enable_bitmapscan = off;
SET LOCAL enable_indexonlyscan = off;
-- Execute the EXPLAIN (ANALYZE, BUFFERS) query five times here.
ROLLBACK;
```

Disabling index access methods is an experimental planner intervention. This is *not* identical to physically dropping the index. Verify the intended plan in the resulting EXPLAIN output. No forced-plan screenshots have been independently reviewed for the five repeated measurements.

## 3. Single-run execution plan observations

A pre-index screenshot showed a **Sequential Scan → Sort** plan, with an estimated 980 qualifying rows, 1,000 actual rows, 19,000 rows removed by filter, 343 shared buffer hits, 79 kB quicksort memory, and 7.259 ms execution time.

An after-index screenshot showed **Bitmap Index Scan → Bitmap Heap Scan → Sort**, with the same estimated 980 and actual 1,000 qualifying rows, 343 exact heap blocks, 343 shared buffer hits and 4 shared reads reported at the upper plan node, 79 kB quicksort memory, and 1.502 ms execution time.

The Bitmap Index Scan used `idx_products_price_desc` for `price >= 100000`. The Bitmap Heap Scan accessed heap pages for the selected columns; bitmap heap retrieval did not preserve price order, so a separate Sort was still required.

These single executions illustrate the changed access method but are **not** treated as the primary performance statistic.

## 4. Five-run benchmark measurements

All times below are **PostgreSQL Execution Time** values in milliseconds, as reported by the student.

| Run | Indexed access (ms) | Sequential access (ms) |
|---|---:|---:|
| 1 | 2.186 | 3.911 |
| 2 | 2.493 | 5.126 |
| 3 | 1.564 | 7.017 |
| 4 | 2.633 | 5.783 |
| 5 | 1.388 | 3.874 |
| **Mean** | **2.053** | **5.142** |
| **Median** | **2.186** | **5.126** |
| Minimum | 1.388 | 3.874 |
| Maximum | 2.633 | 7.017 |
| Range | 1.245 | 3.143 |

**Median-based time reduction:**

```text
(5.126 - 2.186) / 5.126 × 100 = 57.35%
```

**Median-based speedup:**

```text
5.126 / 2.186 = 2.34×
```

**Mean-based time reduction:**

```text
(5.1422 - 2.0528) / 5.1422 × 100 = 60.08%
```

**Mean-based speedup:**

```text
5.1422 / 2.0528 = 2.50×
```

All five indexed measurements were lower than all five sequential measurements. The indexed sample was also less variable in absolute execution time (range 1.245 ms versus 3.143 ms).

## 5. Interpretation

Under the tested conditions, the indexed-access query had a median execution time of 2.186 ms compared with 5.126 ms for the sequential-access query: a **57.4% lower median execution time**, corresponding to a **2.34× median-based speedup**.

The screenshots show that PostgreSQL used the new B-tree price index through a bitmap access path after it became available. Rather than filtering all 20,000 table rows with a sequential scan, PostgreSQL used the index to identify the 1,000 qualifying row locations, then fetched the relevant table pages. Because those matching products were distributed across 343 heap blocks, the index did not eliminate heap access. A separate quicksort remained necessary.

These findings support the usefulness of the price index for **this specific selective range query**. They do not imply that the index speeds up all queries. Indexes use storage and impose maintenance overhead on inserts, deletes and updates to indexed columns. A less selective query may still be better served by a sequential scan.

## 6. Limitations and evidence still needed

- Only five repetitions were recorded for each method; the results are descriptive, not a formal statistical inference.
- The runs were not documented as randomised or alternating; order effects, caches and concurrent Mac activity may influence execution times.
- The indexed and sequential-access runs may have had different cache conditions. To strengthen reproducibility, repeat measurements in alternating order and preserve both EXPLAIN plans.
- A planner configuration forcing sequential access is not equivalent to dropping the index.
- The five-run measurements were supplied by the student; individual run screenshots or a text/CSV results file have not yet been attached to this document.
- The original, unmodified six-table database is separate from this synthetic performance test.

## 7. Conclusion

The experiment demonstrates that, for a 20,000-product synthetic electronics-retailer dataset and a predicate matching 5% of records, a B-tree price index was selected by PostgreSQL and was associated with lower measured query execution times. The median comparison showed a 57.4% reduction (2.34× speedup). The conclusion is limited to this query, dataset and measurement procedure.

