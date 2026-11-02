// Portfolio 4 — Read operations and nested/array queries
// Read-only commands. Requires the two example documents.
use("electronics_store_nosql");

// A: Find all confirmed orders.
db.orders.find({ status: "Confirmed" });

// B: Dot notation accesses the nested payment status.
// Projection displays only selected fields.
db.orders.find(
  { "payment.status": "Successful" },
  { _id: 1, customer_name: 1, status: 1, "payment.status": 1 }
);

// C: Match an SKU inside the items array.
// $elemMatch projection returns only matching array element(s)
// (one matching element for each matching document).
db.orders.find(
  { "items.sku": "LAP-001" },
  {
    _id: 1,
    customer_name: 1,
    items: { $elemMatch: { sku: "LAP-001" } }
  }
);

// D: Numeric comparison for high-value orders.
db.orders.find(
  { total_amount: { $gte: NumberDecimal("1000000.00") } },
  { _id: 1, customer_name: 1, total_amount: 1 }
);

// Read-only final two-order summary.
db.orders.find(
  {},
  {
    _id: 1,
    customer_name: 1,
    status: 1,
    total_amount: 1,
    "payment.method": 1,
    "payment.status": 1
  }
).sort({ _id: 1 });
