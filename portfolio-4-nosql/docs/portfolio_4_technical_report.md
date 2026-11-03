# Portfolio 4 — NoSQL and Advanced Data Models

**Course:** MIT 8103 Advanced Database Systems  
**Case study:** Simulated electronics retailer / E-commerce and Inventory Management System  
**NoSQL DBMS:** MongoDB Community Edition 8.0.34 with mongosh 2.14.1 (Apple Silicon M1 Mac, local service)

## 1. Objective

Implement a small document-oriented model for the existing electronics retailer, demonstrate CRUD operations and queries involving nested objects and embedded arrays, and compare the design against the PostgreSQL six-table relational model developed in Portfolio 1.

This is a **separate teaching database**, not a production migration or live synchronisation of the PostgreSQL database.

## 2. Environment and connection

The student reported that Homebrew services showed **mongodb-community@8.0 started** and **postgresql@18 started**. The student connected to **127.0.0.1:27017** using mongosh and successfully ran:

\`\`\`javascript
db.adminCommand({ ping: 1 })
// { ok: 1 }
\`\`\`

The MongoDB shell warned **access control was not enabled**. This is acceptable only for an isolated localhost coursework environment; it should not be exposed to other computers or to the internet without authentication and suitable network restrictions. The student stated that the local-listener check was satisfactory, but no capture of that command was provided.

## 3. Document design

The case study's existing PostgreSQL relational design consists of \`customers\`, \`categories\`, \`products\`, \`orders\`, \`order_items\`, and \`payments\`. MongoDB was intentionally scoped to **one \`orders\` collection** to demonstrate embedding rather than recreating every relational table.

A representative document contains:
- \`_id\` (order identifier);
- \`customer_name\` and \`status\`;
- \`items\`: an array with product SKU, product name, quantity and unit price;
- \`total_amount\`;
- \`payment\`: embedded method, status and amount.

Amounts use \`NumberDecimal("...")\`, represented by MongoDB as **BSON Decimal128**, avoiding binary floating-point representation for this demonstration.

### Why embed items and payment?

The common read operation is **fetch the entire order** with purchased products and payment details. Embedding stores the associated information together and can avoid assembling it from multiple collections for this access pattern. A separate product catalogue would still be appropriate for changing product details and inventory. Embedding a product's historical purchase price in an order is desirable: a later catalogue price change should not alter the amount originally charged.

### Trade-offs and validation considerations

- A snapshot of customer or product data duplicates information, so rules for correcting or updating customer data must be deliberate.
- Stored \`total_amount\` and \`payment.amount\` should be validated against line items when creating orders.
- Flexible schema is not the same as “no validation”: JSON Schema validation and application rules can help enforce document structure.
- For a real inventory workflow, stock changes and order/payment state may span documents, making multi-document transactions and concurrency checks relevant. MongoDB supports such transactions; the coursework exercises here focused on single-document CRUD, not on testing multi-document transactions.

## 4. Inserting fictional documents (CREATE)

The student inserted Order #1 for **John Ade**, with two laptops at ₦850,000 and one mouse at ₦25,000 (₦1,725,000 total), marked Confirmed with simulated Successful payment. This mirrors the earlier completed PostgreSQL order.

The student inserted Order #2 for **Mary Okafor**, one Wireless Mouse at ₦25,000, initially Pending with Card payment method, and received:

\`\`\`text
{ acknowledged: true, insertedId: 2 }
\`\`\`

Evidence: [original insertion screenshot](../evidence/04-insert-pending-order.png). [Insertion script](../scripts/01_setup_and_insert.js) documents the one-time initial state; do not rerun its duplicate \`insertOne\` commands against the current database.

## 5. Reading documents (READ)

The following queries were performed and confirmed in the student's pasted shell output:

1. \`db.orders.find({ status: "Confirmed" })\` returned the John Ade order, including embedded item and payment information.
2. \`db.orders.find({ "payment.status": "Successful" }, projection)\` retrieved the confirmed order and selectively displayed the nested payment status.
3. \`db.orders.find({ "items.sku": "LAP-001" }, { items: { $elemMatch: { sku: "LAP-001" } }, ... })\` returned only the matching laptop element from the embedded items array.
4. \`db.orders.find({ total_amount: { $gte: NumberDecimal("1000000.00") } }, projection)\` was introduced as a high-value-order filter. The student said the queries worked, but did not paste Query D's output.

See the [read queries](../scripts/02_queries.js).

## 6. Updating the nested payment method (UPDATE)

The student updated only the nested \`payment.method\` for pending Order #2 from **Card** to **Bank Transfer**, using:

\`\`\`javascript
db.orders.updateOne(
  { _id: 2, status: "Pending" },
  { $set: { "payment.method": "Bank Transfer" } }
)
\`\`\`

MongoDB returned **matchedCount: 1** and **modifiedCount: 1**. A subsequent \`findOne\` showed Order #2 and the simulated payment still Pending, with payment amount unchanged at ₦25,000.

Evidence: [update screenshot](../evidence/03-update-payment-method.png).

**Interpretation:** Dot notation targets a nested field without replacing the entire embedded payment object. Updates to a single MongoDB document are atomic.

## 7. Removing a disposable record (DELETE)

A minimal temporary record \`{ _id: 99, customer_name: "Test Customer", status: "Pending", test_record: true }\` was inserted for deletion testing.

The student confirmed:
- Document count **3** before deletion.
- \`db.orders.deleteOne({ _id: 99, test_record: true })\` returned **deletedCount: 1**.
- \`db.orders.findOne({ _id: 99 })\` returned **null**.
- Document count **2** afterward.
- John Ade and Mary Okafor remained.

Evidence: [delete screenshot](../evidence/02-delete-test-document.png). This deliberately incomplete test record is a disposable CRUD example and is **not** meant to represent a valid retail order.

## 8. Final state

The final projected \`find().sort({ _id: 1 })\` query showed:

| _id | Customer | Order status | Total (NGN) | Payment method | Payment status |
| --- | --- | --- | ---: | --- | --- |
| 1 | John Ade | Confirmed | 1,725,000.00 | Bank Transfer | Successful |
| 2 | Mary Okafor | Pending | 25,000.00 | Bank Transfer | Pending |

Evidence: [final-state screenshot](../evidence/01-final-order-state.png).

These are fictional educational records; no actual payment was made.

## 9. Comparison with the relational PostgreSQL solution

| Criterion | PostgreSQL design | MongoDB demonstration |
| --- | --- | --- |
| Structure | Six related tables, PKs/FKs and CHECK constraints | Order documents with embedded items and payment |
| Retrieving an entire order | Joins across \`orders\`, \`order_items\`, \`products\`, \`payments\` as needed | One document fetch includes embedded details |
| Updating one payment field | \`UPDATE payments SET ... WHERE...\` | \`updateOne\` with \`$set\` and dot notation |
| Relationship integrity | Database-enforced foreign keys | Embedding avoids some references; remaining references need deliberate enforcement |
| Transactional inventory and payments | Demonstrated multi-table atomic transaction in Portfolio 3 | Multi-document transactions supported but **not tested** in Portfolio 4 |
| Document flexibility | Fixed table schema, though JSON data types are available | Flexible document structure with optional schema validation |
| Best fit for this case study | Strong baseline for current inventory and payment consistency | Useful illustration for order-history documents assembled around access patterns |

**Design decision:** Keep the PostgreSQL relational model as the primary choice for the core stock/order/payment workflow in this coursework. The MongoDB model illustrates a useful read-oriented approach for complete order documents, but one document fetch is not inherently proof of superior performance. No head-to-head benchmark was run.

## 10. References and AI-use declaration

- MongoDB documentation: https://www.mongodb.com/docs/manual/core/data-model-design/
- MongoDB CRUD operations: https://www.mongodb.com/docs/manual/crud/
- MongoDB embedded documents: https://www.mongodb.com/docs/manual/core/data-model-design/#embedding
- MongoDB atomicity and transactions: https://www.mongodb.com/docs/manual/core/write-operations-atomicity/

**AI-use disclosure:** ChatGPT supported conceptual explanation, command drafting, result interpretation and portfolio documentation. The student executed MongoDB commands locally and supplied the original Terminal evidence screenshots. The student should review this draft for accuracy and write the personal reflection independently.
