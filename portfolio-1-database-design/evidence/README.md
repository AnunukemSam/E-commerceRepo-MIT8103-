# Portfolio 1 — Evidence folder

Add **your own** genuine screenshot images and, optionally, redacted query-output files here. The zip does not include screenshots because ChatGPT cannot access the pgAdmin session on your Mac.

## Screenshot checklist and suggested filenames

- `01-pgadmin-six-tables.png` — pgAdmin browser showing all six tables under `electronics_store_db` > Schemas > public > Tables.
- `02-psql-six-tables.png` — `\dt` result showing all six tables.
- `03-customers-categories-structure.png` — PK and UNIQUE constraints visible.
- `04-products-orders-foreign-keys.png` — FK constraints in pgAdmin or `\d` output.
- `05-order-items-payments-structure.png` — two foreign keys on `order_items`; UNIQUE `payments.order_id`.
- `06-validation-constraint-errors.png` — clear, readable evidence of rejected invalid inserts (can use multiple screenshots).
- `07-sample-order-join.png` — JOIN result showing John Ade and two product lines.
- `08-order-total-payment-check.png` — calculated total equals pending payment amount.
- `09-pending-stock-check.png` — stock unchanged with pending order.
- `10-er-diagram.png` — rendered diagram from the `.mmd` source (optional but useful).

Filenames are examples; use the filenames that match the screenshots you actually captured, and update the report accordingly. Do not fabricate outputs or claim a test passed without running it.

## Capture guidance

1. Show the SQL statement and relevant result/error where practical.
2. Crop screenshots so that query results are legible; avoid unrelated windows.
3. Remove or redact credentials, access tokens, unrelated account details and personal file paths.
4. Do not include private payment details or real personal customer records. The sample data in the portfolio are fictional.
5. Prefer screenshots at readable resolution over many tiny unreadable captures.
6. For failed insert demonstrations, remember that a constraint error is the **expected** successful test result.
7. Add brief captions in the final report explaining **what each screenshot proves**.

## Before final submission

- [ ] Screenshots correspond to the actual database in your PostgreSQL installation.
- [ ] `sql/schema_from_live_db.sql` is an export from your real database.
- [ ] ER diagram and schema match what was implemented.
- [ ] Constraint descriptions match observed results.
- [ ] AI-use declaration and reflection reflect your own work.
- [ ] The GitHub repository remains public as required, and all uploaded evidence has been checked for sensitive information.
