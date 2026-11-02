# Portfolio 3 — Original Screenshot Evidence

These **12 PNG files** are original images supplied by the student on 2026-11-02. They were uploaded without visual modification and renamed to describe the visible evidence. They are not generated graphics. The screenshots do not, in every case, show all stages of a transaction; the text below distinguishes visible evidence from student-reported workflow steps.

| File | Description |
|---|---|
| [01-original-inventory-before-rehearsal.png](01-original-inventory-before-rehearsal.png) | Order 1 initial inventory: Laptop Pro=5, Wireless Mouse=20 |
| [02-rehearsal-stock-updated.png](02-rehearsal-stock-updated.png) | Transactional UPDATE returns Laptop Pro=3 and Wireless Mouse=19 |
| [03-rehearsal-payment-successful-uncommitted.png](03-rehearsal-payment-successful-uncommitted.png) | Successful simulated payment UPDATE returns ₦1,725,000 |
| [04-rehearsal-rollback-executed.png](04-rehearsal-rollback-executed.png) | pgAdmin message confirms ROLLBACK command executed |
| [05-rehearsal-original-state-restored.png](05-rehearsal-original-state-restored.png) | Restored Pending order/payment and original stock 5 and 20 |
| [06-insufficient-stock-exception.png](06-insufficient-stock-exception.png) | Custom PL/pgSQL error: “Insufficient stock or missing product”, SQLSTATE P0001 |
| [07-insufficient-stock-rollback-restored.png](07-insufficient-stock-rollback-restored.png) | Stock values 5 and 20 following student-reported ROLLBACK |
| [08-before-successful-transaction-statuses.png](08-before-successful-transaction-statuses.png) | Order and payment still Pending before successful run |
| [09-validation-success-notice.png](09-validation-success-notice.png) | PostgreSQL NOTICE: Order 1 validated successfully, total 1,725,000 |
| [10-successful-order-state.png](10-successful-order-state.png) | Confirmed order, Successful payment, stock 3 and 19 |
| [11-committed-state-separate-query.png](11-committed-state-separate-query.png) | Subsequent query showing Confirmed/Successful with inventory 3 and 19; student reports a separate connection was used |
| [12-concurrency-read-and-lock-timeout.png](12-concurrency-read-and-lock-timeout.png) | Two psql windows: Session A uncommitted stock=2; Session B Read Committed sees 3 and receives a 3-second lock timeout on UPDATE |

## Evidence limitations

- A separate screenshot of the successful `COMMIT;` message was not supplied; successful persistence was subsequently checked, and the student reported using a new connection.
- The uploaded concurrency screenshot shows the Read Committed comparison and lock-timeout error. The subsequent two ROLLBACK operations and final stock=3 were reported by the student but are **not visible in this particular screenshot**. The user confirmed having performed them.
- Successful simulated payment does **not** establish real-money settlement.
- Each screenshot shows fictional customer/store records; check for any unintended private information before public submission.
- The generated infographic from an earlier chat is **excluded**, since it is not original pgAdmin evidence.
