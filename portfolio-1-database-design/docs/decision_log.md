# Portfolio 1 — Design decision log

| Decision | Rationale | Limitation / trade-off |
|---|---|---|
| One consistent simulated electronics retailer case study | Supports all five portfolios without switching datasets | No real customers or payment integrations |
| PostgreSQL 18 as primary relational DBMS | Strong support for keys, constraints, JOINs and transactions | Local setup only at this stage |
| Six tables: customers, categories, products, orders, order_items, payments | Covers the required business functions with manageable scope | No separate warehouse, delivery or cart tables |
| `order_items` junction table | Resolves orders ↔ products many-to-many relationship | Requires JOINs for order detail |
| `UNIQUE(order_id, product_id)` | Same product appears once per order, with quantity accounting for units | Cannot represent multiple price breaks on separate lines for one SKU in an order |
| `order_items.unit_price` snapshot | Preserves historical selling price | Historical and current product prices can differ intentionally |
| No `orders.order_total` | Compute from order line totals to avoid duplicated derived values | Aggregate query needed to retrieve total |
| One payment record per order | Appropriate for simple simulated payment MVP | No retries, split payments or refunds |
| Stock quantity stored in products | Simple basic inventory model | No stock-movement ledger or warehouse support |
| `ON DELETE RESTRICT` on foreign keys | Prevent accidental loss of linked business records | Deleting referenced records requires deliberate business policy |
| Pending sample order leaves stock unchanged | Stock decreases only on successful order processing | Atomic confirmation implemented in Portfolio 3 |
| ERD 1-to-many item relationship | Represents rule that orders must have items | Ordinary FKs alone do not guarantee that an order has at least one item |
