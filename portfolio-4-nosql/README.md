# Portfolio 4 — NoSQL and Advanced Data Models

**MIT 8103 Advanced Database Systems** · Electronics retailer case study · MongoDB 8.0 Community Edition

This portfolio demonstrates MongoDB document modelling, embedded arrays and objects, CRUD operations, nested-field queries and a reasoned comparison to the PostgreSQL relational implementation in Portfolios 1–3.

## Contents

- [Technical report](docs/portfolio_4_technical_report.md) — design decisions, actual results, comparisons and limitations.
- [Original screenshot evidence](evidence/README.md) — **four unmodified screenshots**, clearly indexed.
- [01_setup_and_insert.js](scripts/01_setup_and_insert.js) — archived one-time creation of two fictional orders.
- [02_queries.js](scripts/02_queries.js) — filters, dot notation, array querying, Decimal128 comparison and final state.
- [03_update.js](scripts/03_update.js) — modifying a nested payment field.
- [04_delete_disposable_test.js](scripts/04_delete_disposable_test.js) — insert/delete a temporary _id=99 test document.

## Safety and reproducibility

- **Do not blindly rerun** the setup script against the completed student database: orders #1 and #2 already exist, and duplicate IDs would cause insertion errors.
- All customers, orders and payments are fictional. MongoDB here is a separate NoSQL learning model—not synchronised with the original PostgreSQL database.
- MongoDB was running locally without access control for the lab. Keep it bound to loopback and do not expose unauthenticated port 27017.
