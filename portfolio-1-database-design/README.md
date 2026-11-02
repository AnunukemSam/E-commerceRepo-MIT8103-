# Portfolio 1 — Database Design and Modelling

## Objective

Design, implement and validate the PostgreSQL relational schema for a simulated electronics retailer. The database is `electronics_store_db` and contains six tables: `customers`, `categories`, `products`, `orders`, `order_items`, and `payments`.

## Files

- `docs/portfolio_1_design_report.md` — written submission draft, to be adapted with your actual screenshots and reflections.
- `docs/decision_log.md` — design decisions and trade-offs.
- `diagrams/electronics_store_erd.mmd` — Mermaid ERD source. GitHub can also render Mermaid blocks in Markdown.
- `sql/01_schema_reference.sql` — proposed CREATE TABLE definitions, **fresh database only**.
- `sql/02_reference_data.sql` — synthetic customer, category and product data for a new database.
- `sql/03_sample_order_fresh_database.sql` — optional extra pending order on **new/fresh** demo database, not on current populated DB.
- `sql/04_validation_queries.sql` — read-only queries appropriate for your **current** database.
- `sql/05_constraint_tests_manual.sql` — commented-out intentional error tests; enable and run individually.
- `sql/schema_from_live_db.sql` — the live schema export already committed, documenting the implemented objects.
- `evidence/Screenshots/` — six original student-supplied screenshots, indexed in `evidence/README.md`.

## 1. Live schema export (already completed)

The live schema has been exported and committed. The original command for reproducing the export is:

```bash
pg_dump --schema-only --no-owner --no-privileges \
  --dbname=electronics_store_db --schema=public \
  --file=sql/schema_from_live_db.sql
```

This records what **your running PostgreSQL instance actually contains**, not just what the design document proposes. It exports table definitions, keys and other schema objects, but **does not export customer/order data**. Inspect the SQL file before committing it to ensure it contains no unrelated objects or sensitive comments.

You can compare its contents with `01_schema_reference.sql`. Differences in ordering and generated object syntax are normal; the six tables, data types, keys and business constraints are what matter.

## 2. Check the implemented schema

Run the read-only validation script from Terminal:

```bash
psql -d electronics_store_db -f sql/04_validation_queries.sql
```

Or open the same file using pgAdmin Query Tool. Confirm the results, then add your screenshots to `evidence/`.

**Do not re-run schema creation or the fresh-demo order script against your existing populated database.** You have already inserted the sample order during the assignment work.

## 3. ER diagram source

Open `diagrams/electronics_store_erd.mmd` in a Mermaid-compatible preview/editor, or copy the contents into a fenced `mermaid` block in a Markdown viewer that supports it. The diagram source is already present in the repository; the existing screenshots and evidence index should be reviewed before submission.

## 4. Verify portfolio completion

- [x] Requirements, case study and business rules drafted.
- [x] Six-table ER diagram and relational schemas designed.
- [x] Normalisation to 3NF explained.
- [x] PostgreSQL and pgAdmin installed; all six tables created and tested (per student's reported work).
- [x] Fictional sample order, payment and JOIN validation completed (per student's reported work).
- [x] Live schema exported and committed; final student review advised.
- [x] Six genuine evidence screenshots included and indexed.
- [ ] Personal reflection to be completed in student's own words.
- [x] Files committed to the existing public GitHub repository.

## 5. GitHub

Use the existing **public** repository `AnunukemSam/E-commerceRepo-MIT8103-`, as instructed by your lecturer. Put this portfolio folder at the repository root. You can add `portfolio-2-query-optimisation/`, `portfolio-3-transactions-concurrency/`, `portfolio-4-nosql/`, `portfolio-5-distributed-cloud/` and final documentation as those pieces are completed. Commit as you make progress rather than submitting a single untraceable final upload.

Do not publish passwords, actual personal information, internal institutional credentials or private tokens. Confirm any assessor access requirements in the module's assignment instructions.
