# Portfolio 2 — Experiment 04: JOIN and Aggregate Execution Plans

**Course:** MIT 8103 — Advanced Database Systems  
**Scenario:** Simulated electronics retailer  
**Database:** `electronics_store_db` on PostgreSQL 18.6  
**Source:** Actual `EXPLAIN (ANALYZE, BUFFERS)` text supplied by student for Query 1 and Query 3  
**Date:** 2026-11-02

## Goal

Understand how PostgreSQL executes business reporting queries involving multiple tables, hashing, aggregation and sorting. This exercise studies actual query plans in the original small case-study database. Performance indexing experiments with 20,000 products are documented separately in Experiment 03.

The full SQL used for the four business questions is provided in `../sql/business_queries.sql`.

## 1. Query 1 — Customer order history

**Business question:** What products did a customer order, in what quantities, and what were the line subtotals?

**Validated result:** One pending order for fictional customer John Ade, containing two Laptop Pro units (₦1,700,000 subtotal) and one Wireless Mouse (₦25,000 subtotal). Two output rows represent **two order items**, not two distinct orders.

### Observed execution plan structure

```text
Sort
  Sort Key: o.order_date DESC, o.order_id, p.product_name
  Sort Method: quicksort  Memory: 25kB
  -> Hash Join                    [oi.product_id = p.product_id]
       -> Hash Join               [o.customer_id = c.customer_id]
            -> Hash Join          [oi.order_id = o.order_id]
                 -> Seq Scan on order_items oi
                 -> Hash -> Seq Scan on orders o
            -> Hash -> Seq Scan on customers c
       -> Hash -> Seq Scan on products p
```

Three hash joins combine the four tables. A hash join constructs a hash table for one input to match relevant rows from the other. The final sort orders the matched records by date, order ID and product name. Scans over these very small tables are inexpensive.

### Actual measurements

| Measurement | Value |
|---|---:|
| Planner's estimated result rows | 1,360 |
| Actual result rows | 2 |
| Sort method / memory | Quicksort / 25 kB |
| Buffers, execution | shared hit=4 |
| Planning time | 0.379 ms |
| Execution time | 0.160 ms |

**Interpretation:** The query produced the correct two lines and executed quickly. The estimated row count (1,360) greatly exceeded the actual count (2), which merits checking planner statistics, but it is *not* evidence that the query is slow.

## 2. Query 3 — Inventory grouped by category

**Business question:** How many products and stock units does each category have, and what is the corresponding inventory value at current selling prices?

**Validated result:** Laptops: 1 product, 5 units, ₦4,250,000; Accessories: 1 product, 20 units, ₦500,000.

### Observed execution plan structure

```text
Sort
  Sort Key: COALESCE(sum(p.price * p.stock_quantity), 0) DESC
  Sort Method: quicksort  Memory: 25kB
  -> HashAggregate
       Group Key: c.category_name
       Batches: 1  Memory Usage: 48kB
       -> Hash Left Join           [c.category_id = p.category_id]
            -> Seq Scan on categories c
            -> Hash -> Seq Scan on products p
```

The Hash Left Join retains all categories including those without matching products. HashAggregate computes grouped product counts, stock units and inventory values. The Sort then ranks categories by inventory value.

### Actual measurements

| Measurement | Value |
|---|---:|
| Planner's estimated result rows | 280 |
| Actual result rows | 2 |
| HashAggregate memory / batches | 48 kB / 1 |
| Sort method / memory | Quicksort / 25 kB |
| Buffers, execution | shared hit=2 |
| Planning time | 0.223 ms |
| Execution time | 0.129 ms |

**Interpretation:** Both categories were correctly returned. Hash-based grouping and sorting completed within a fraction of a millisecond. The planner estimated far more output groups than actually existed, likely because statistics for one or more small tables have not been refreshed. Confirm this hypothesis rather than assuming it.

## 3. Estimated rows and statistics

The reported plans contain substantial overestimates: **1,360 versus 2** output rows for the order-history query, and **280 versus 2** for the category query.

The earlier `ANALYZE products;` command refreshed statistics for products only. Other small tables may still carry initial default planner estimates. To test the statistics hypothesis without modifying business data, connect to the original database and run:

```sql
SELECT current_database(); -- Expect electronics_store_db
ANALYZE;
```

Then rerun the same `EXPLAIN (ANALYZE, BUFFERS)` statements and compare estimated rows. Preserve the original plans as **before statistics refresh** evidence. Any post-ANALYZE results need to be captured separately; none are claimed here.

PostgreSQL estimates need not be exact, and neither plan demonstrates a significant performance issue: query execution times were only 0.160 ms and 0.129 ms.

## 4. Four business query result summary

| Query | Observed result |
|---|---|
| Q1: Customer order history | John Ade, pending order #1, 2 line items totaling ₦1,725,000 |
| Q2: Order total and payment | ₦1,725,000; order Pending; simulated Bank Transfer payment Pending |
| Q3: Category inventory | Laptops ₦4,250,000 (5 units); Accessories ₦500,000 (20 units) |
| Q4: Confirmed sales value | 0 confirmed paid orders; ₦0 confirmed sales total |

These observations were taken from the four pgAdmin screenshots shared by the student. The confirmed sales query intentionally excludes the pending sample order.

## 5. Conclusions and limitations

- `Hash Join` matched records from the four business tables.
- `Hash Left Join` preserved categories without matching products; `HashAggregate` computed group-level totals.
- `Sort` arranged output rows; the data volumes were small and no sort-to-disk operation was reported.
- Row estimates may be inaccurate even when execution is fast, particularly with incomplete statistics.
- This small-database exercise demonstrates SQL processing and plan interpretation, **not** that indexing these small tables will necessarily help.
- Actual screenshots of the Q1/Q3 plans should be committed in `evidence/` with descriptive names. This report records the supplied output text; it does not claim screenshots are already in GitHub.

**AI-use note:** ChatGPT assisted with interpretation and report structure. PostgreSQL plans and result values were supplied by the student; the student should confirm the explanations and screenshots before submission.
