# MIT 8103 — Advanced Database Systems
## Portfolio 1: Database Design and Modelling

**Case study:** E-commerce and Inventory Management System  
**Organisation:** Simulated electronics retailer  
**Database:** `electronics_store_db` (PostgreSQL 18)  

### Business context

The simulated electronics retailer sells laptops, smartphones, accessories and related products. It needs reliable records of customers, product categories, products, stock, orders, line items and simulated payments. Its core workflows include product registration, customer registration, order recording, payment recording, stock checks and basic reporting. The database supports a small administrative workflow, not a customer-facing application.

**Intended users:** Store administrator (products/categories), sales personnel (orders), inventory personnel (stock), management (summaries), and database administrator (integrity and maintenance). These roles describe system users; application login and role permissions are not implemented in this MVP.

**Boundary:** No real payments, online shop interface, delivery, promotions, multi-warehouse inventory or production cloud deployment. These are not required for this portfolio's core objective.

### Functional requirements

1. Register customers with a unique email address.
2. Create product categories and register products using unique SKUs.
3. Maintain non-negative product stock quantities and positive prices.
4. Record customer orders and their individual product lines.
5. Preserve the purchase-time unit price on every order item.
6. Calculate order totals from order item quantities and prices.
7. Store one simulated payment record at most for each order.
8. Retrieve orders, payment statuses, products and basic inventory information.
9. Support later transaction-safe order confirmation and stock reduction.

### Main business rules

- Each order belongs to an existing customer; a customer may have many orders.
- Each product belongs to one existing category; a category may have many products.
- Each order must contain at least one order item; this rule is enforced during order-processing logic rather than by the foreign keys alone.
- Order item quantity and unit price are greater than zero.
- The same product may occur only once per order; greater quantities are represented with `quantity`.
- Product price and payment amount are positive; product stock cannot be negative.
- An order has zero or one payment record, and each payment belongs to exactly one order.
- Orders have status `Pending`, `Confirmed`, or `Cancelled`; payments have `Pending`, `Successful`, or `Failed` statuses.
- Simulated payment and stock updates must be coordinated in a single successful order-processing transaction (explored in Portfolio 3).
- Historical cancelled orders and items are retained; foreign keys use `ON DELETE RESTRICT` to protect referenced records.

### Entities and relationships

| Entity | Purpose | Primary key |
|---|---|---|
| `customers` | Customer personal/contact details | `customer_id` |
| `categories` | Product classification | `category_id` |
| `products` | Product details, pricing and available stock | `product_id` |
| `orders` | Customer order header and status | `order_id` |
| `order_items` | Products, quantities and purchase-time prices within an order | `order_item_id` |
| `payments` | Simulated payment details | `payment_id` |

**Cardinality:** Customers 1-to-many Orders; Categories 1-to-many Products; Orders 1-to-many Order_Items (conceptually at least one item per order); Products 1-to-many Order_Items; Orders 1-to-zero-or-one Payments. Thus the many-to-many relationship of orders and products is resolved through `order_items`.

**ER diagram:** See `../diagrams/electronics_store_erd.mmd`.

### Relational schema

- `CUSTOMERS(customer_id PK, first_name, last_name, email UNIQUE, phone)`
- `CATEGORIES(category_id PK, category_name UNIQUE, description)`
- `PRODUCTS(product_id PK, category_id FK -> CATEGORIES.category_id, product_name, sku UNIQUE, description, price, stock_quantity)`
- `ORDERS(order_id PK, customer_id FK -> CUSTOMERS.customer_id, order_date, status)`
- `ORDER_ITEMS(order_item_id PK, order_id FK -> ORDERS.order_id, product_id FK -> PRODUCTS.product_id, quantity, unit_price, UNIQUE(order_id, product_id))`
- `PAYMENTS(payment_id PK, order_id FK -> ORDERS.order_id UNIQUE, amount, payment_method, payment_status, payment_date)`

Identifiers use integer generated identity columns. Names, emails, SKU and statuses use bounded `VARCHAR` types; descriptions use `TEXT`; currency values use `NUMERIC(12,2)` for exact decimal storage; quantities are integers; order and payment times use `TIMESTAMP`.

Important constraints: `NOT NULL` on required columns; `UNIQUE` on customer email, category name, SKU, the order-item `(order_id, product_id)` pair, and `payments.order_id`; `CHECK` on positive prices/amounts/quantities, non-negative stock, and permitted status/method values; `FOREIGN KEY` relationships with `ON DELETE RESTRICT`.

The actual SQL definitions are in `../sql/01_schema_reference.sql`. The authoritative version of the database was obtained using `pg_dump` and stored as `../sql/schema_from_live_db.sql`.

### Normalisation

**First Normal Form (1NF):** Every field holds one value and there are no repeating product columns. An order with multiple products is represented by multiple `order_items` records, each with its own row identifier.

**Second Normal Form (2NF):** The tables satisfy 1NF and non-key data depends on complete candidate keys, rather than just one component of a composite candidate key. In `order_items`, the candidate key `(order_id, product_id)` identifies a product in an order: quantity and purchase-time unit price depend on that combination. Product names and descriptions depend on `product_id` alone and therefore remain in `products`.

**Third Normal Form (3NF):** Customer details remain in `customers`, category details remain in `categories`, and product attributes remain in `products` rather than being copied into order headers or order items. This avoids unwanted transitive dependencies and makes changes to customer or category information less error-prone.

**Intentional historical snapshot:** `order_items.unit_price` is retained even though `products.price` exists. It represents the price at purchase time and is required for accurate historical totals; it is not assumed to equal the product's current price.

**Calculated totals:** `orders` does not contain a redundant order-total column. Totals are calculated from `SUM(order_items.quantity * order_items.unit_price)`, preventing a separate order header amount from becoming out of sync with order lines.

### Implementation and validation

PostgreSQL 18 was installed and initialised on an Apple Silicon Mac, and pgAdmin 4 was used to create all six tables. Table introspection in `psql`, individual constraint tests, and relational sample-data queries were successful.

**Test scenario:** A customer, John Ade (`john.ade@example.com`), placed a **pending** sample order of two Laptop Pro units at ₦850,000 each and one Wireless Mouse at ₦25,000. The calculated total was ₦1,725,000. A simulated pending Bank Transfer payment was recorded. Stock quantities were not decremented, because the order was not yet confirmed.

**Validation checks and expected findings:**

| Check | Intended evidence |
|---|---|
| List of six tables | `\dt` output or pgAdmin browser tree |
| Structure and relationships | `\d products`, `\d orders`, `\d order_items`, `\d payments` and constraint listing |
| Customer, category and product rules | Error screenshots for duplicate email, missing category and negative stock |
| Order item/payment rules | Error screenshots for missing order, negative quantity and disallowed payment method |
| Valid order | `orders` and `order_items` rows, with a JOIN identifying John and both products |
| Correct simulated payment | Payment amount equals calculated item sum: ₦1,725,000 |
| Pending order behavior | Order and payment remain pending; no stock deducted |
| Schema reproducibility | SQL schema reference plus actual `pg_dump` schema export |

### Design limitations and preparation for later portfolios

Foreign keys alone cannot enforce the business rule that an order has at least one item. A payment's numeric value is not automatically checked against its order total by the current table constraints, and order/payment statuses are not cross-table constrained. These conditions will be managed in transaction logic during Portfolio 3.

Portfolio 2 will use representative data and SQL queries to explore query plans, indexing and performance. Portfolio 3 will implement and demonstrate commit/rollback and concurrent stock-safe order processing. The same case study will later support a MongoDB model and a distributed/cloud database exercise.

### References and AI-use declaration

**References**
- MIT 8103 assessment brief and class materials (add exact lecturer/institution details if required).
- PostgreSQL official documentation: https://www.postgresql.org/docs/
- pgAdmin official documentation: https://www.pgadmin.org/docs/

**AI-use declaration:** ChatGPT was used to explain database concepts, brainstorm the case study, review table relationships, draft SQL examples and help organise this written portfolio. The student executed and tested SQL independently in PostgreSQL, inspected constraints and results, and is responsible for checking the accuracy of screenshots, queries and explanations. This declaration should be adjusted if the actual use differs.
