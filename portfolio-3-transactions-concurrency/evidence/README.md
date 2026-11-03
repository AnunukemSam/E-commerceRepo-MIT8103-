# Portfolio 3 — Original Screenshot Evidence

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


