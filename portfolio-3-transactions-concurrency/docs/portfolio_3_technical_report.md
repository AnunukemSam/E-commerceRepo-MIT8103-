# Portfolio 3 — Transactions and Concurrency: Technical Report

**Course:** MIT 8103 Advanced Database Systems  
**Case study:** Simulated electronics retailer, unchanged from Portfolios 1–2  
**DBMS:** PostgreSQL 18.6, pgAdmin 4 and Terminal/psql  
**Database:** `electronics_store_db`  

## Objective

Demonstrate PostgreSQL transaction boundaries, `COMMIT` and `ROLLBACK`, atomic multi-table order processing, automatic consistency validation, and a two-session Read Committed isolation/row-locking experiment.

## 1. Transaction fundamentals

A temporary-table rehearsal demonstrated:
- `BEGIN` starts a transaction.
- `ROLLBACK` reversed both `CREATE TEMP TABLE` and `INSERT`, verified by `to_regclass('pg_temp.transaction_demo') IS NULL`.
- `COMMIT` preserved a row after the transaction ended within the active session.
- A subsequent rollback removed an additional uncommitted row but retained the previously committed row.

**Scope note:** Temporary tables are session-scoped, so they are not a test of persistence across a server restart. See [01_transaction_basics.sql](../sql/01_transaction_basics.sql).

## 2. Atomicity: multiple-table order-processing rehearsal

Original fictional Order #1 contained two Laptop Pro units at ₦850,000 each and one Wireless Mouse at ₦25,000, total ₦1,725,000. Initial inventory was 5 laptops and 20 mice; order/payment were both Pending.

In a single explicit transaction, the student:
1. Reduced stock via conditional product UPDATE: Laptop Pro 5→3 and Wireless Mouse 20→19.
2. Updated the simulated payment to Successful, validating its value against the order-item total.
3. Updated the order state to Confirmed.
4. Executed `ROLLBACK;` to discard the rehearsal changes.

Evidence images [01](../evidence/01-original-inventory-before-rehearsal.png), [02](../evidence/02-rehearsal-stock-updated.png), [03](../evidence/03-rehearsal-payment-successful-uncommitted.png), [04](../evidence/04-rehearsal-rollback-executed.png), and [05](../evidence/05-rehearsal-original-state-restored.png) show the relevant outputs. The final verification returned 5 laptops, 20 mice, and Pending statuses.

**Interpretation:** The same transaction contained multiple related updates; rolling it back removed all its uncommitted effects. This is a practical demonstration of atomicity.

## 3. Automatic validation using PL/pgSQL

The [validated order processing block](../sql/02_validated_order_processor.sql) uses:
- `SELECT ... FOR UPDATE` to lock and validate a Pending order;
- `COUNT(*)` and `SUM(quantity * unit_price)` to determine line items and total;
- conditional inventory updates, preventing negative stock;
- `GET DIAGNOSTICS ... ROW_COUNT` to verify all expected products were updated;
- an exact one-row payment update and amount match;
- an exact one-row order confirmation;
- `RAISE EXCEPTION` when a condition fails.

These validations are classroom-scale protections rather than a fully designed production payment/fulfilment service. The one-payment-per-order rule and unique product-per-order line are enforced by the schema.

## 4. Failure test: insufficient inventory

The student temporarily changed Laptop Pro stock from five units to one in an uncommitted transaction, then attempted to process the order requiring two laptops.

The conditional product update could not update the laptop, so the number of successfully updated product rows was below the expected line-item count. PL/pgSQL raised:

```text
ERROR: Insufficient stock or missing product
SQL state: P0001
```

The student rolled back the failed transaction and verified stock returned to Laptop Pro=5, Wireless Mouse=20; prior Pending order/payment statuses were preserved.

Evidence: [exception](../evidence/06-insufficient-stock-exception.png) and [inventory restored](../evidence/07-insufficient-stock-rollback-restored.png).

**Interpretation:** A query affecting fewer rows than required is not automatically an SQL error. Explicit validation converted a business-rule failure into an exception, causing the enclosing transaction to enter an aborted state until rollback.

## 5. Successful order processing and COMMIT

The student confirmed the starting Pending state, ran the PL/pgSQL validation block with sufficient inventory, observed:

```text
NOTICE: Order 1 validated successfully. Total: 1725000.00
```

and reported committing the transaction. Subsequent verification displayed:

| Field | Before | After successful processing |
|---|---|---|
| Order #1 status | Pending | Confirmed |
| Simulated payment status | Pending | Successful |
| Payment amount | ₦1,725,000 | ₦1,725,000 |
| Laptop Pro stock | 5 | 3 |
| Wireless Mouse stock | 20 | 19 |

Evidence: [initial status](../evidence/08-before-successful-transaction-statuses.png), [success notice](../evidence/09-validation-success-notice.png), [updated state](../evidence/10-successful-order-state.png), and [subsequent verification](../evidence/11-committed-state-separate-query.png).

The user reported that the final verification was performed in a new database connection, providing evidence that the transaction's results were visible outside the original session. The commit message itself was not photographed. **Order #1 must not be processed again**, since it is now Confirmed.

## 6. Isolation and concurrency using two PostgreSQL sessions

The student opened two separate psql Terminal connections to `electronics_store_db`.

- **Session A** (shown backend PID 9698) executed `BEGIN` and reduced Laptop Pro stock 3→2 without committing. This transaction held a conflicting row-level lock.
- **Session B** ran inside a transaction with `transaction_isolation = read committed`. Its ordinary SELECT displayed stock **3**, not the uncommitted 2 from A.
- Session B set `SET LOCAL lock_timeout = '3s'` and attempted to update the same product. PostgreSQL waited for the conflicting row lock, then raised an error cancelling the UPDATE due to lock timeout.
- It was confirmed that both sessions were rolled back and the final stock remained at the committed 3.

Evidence: [concurrency screenshot](../evidence/12-concurrency-read-and-lock-timeout.png). The screenshot captures Session A's uncommitted 2, Session B's committed read of 3 and the lock-timeout error; the separately executed rollbacks and final stock were user-reported.

**Interpretation:** Read Committed prevents dirty reads for ordinary SELECTs. PostgreSQL row-level locking serialises conflicting updates to the same record; with the configured timeout, Session B abandoned the waiting UPDATE instead of modifying the row concurrently. ROLLBACK restored the experimental changes.

### Additional technical notes

- A PostgreSQL lock timeout inside an explicit transaction leaves Session B's transaction aborted until `ROLLBACK`.
- `SELECT ... FOR UPDATE` serialises attempts to process the same order row; product UPDATEs also acquire row locks.
- This demonstrates **one isolation level** and a concurrency-control mechanism. It does not prove the behaviour of Repeatable Read or Serializable, which were not tested.
- The PL/pgSQL routine is an archive of the academic test, not a command to rerun against the now-confirmed order.

## 7. ACID interpretation

| Property | Evidence and limitation |
|---|---|
| Atomicity | Rollback reversed inventory/payment/order updates together |
| Consistency | Conditional stock checks, status transitions and payment total checks reject invalid processing |
| Isolation | A second Read Committed connection could not see an uncommitted stock update; its conflicting UPDATE waited and timed out |
| Durability | The committed state remained visible from a subsequent query/connection; no server-crash or restart durability test was performed |

## 8. Constraints and reflection

This MVP uses one simulated payment per order; it does not charge a real payment gateway, implement multi-warehouse inventory, or handle multiple payment attempts. The order-processing block handles one existing order, not the full creation of a fresh order. For coursework it demonstrates the required transaction operations while preserving the agreed six-table scope.

## 9. References and AI use

- MIT 8103 course assessment brief.
- PostgreSQL transaction documentation: https://www.postgresql.org/docs/current/tutorial-transactions.html
- PostgreSQL isolation documentation: https://www.postgresql.org/docs/current/transaction-iso.html
- PostgreSQL explicit locking documentation: https://www.postgresql.org/docs/current/explicit-locking.html
- PostgreSQL PL/pgSQL diagnostics: https://www.postgresql.org/docs/current/plpgsql-statements.html

**AI-use declaration:** ChatGPT assisted with lab design, PL/pgSQL explanation/debugging, experiment analysis, SQL script consolidation and draft documentation.
