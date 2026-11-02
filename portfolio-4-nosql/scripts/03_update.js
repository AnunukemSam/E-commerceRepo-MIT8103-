// Portfolio 4 — Update an embedded field in an EXISTING order
// The student already executed this against order #2.
// Repeating is safe with the same desired value but should
// generally yield modifiedCount: 0, not 1.
use("electronics_store_nosql");

// Historical initial state for order #2: payment.method = "Card".
db.orders.findOne({ _id: 2 });

// Apply a targeted change without replacing the payment object.
db.orders.updateOne(
  { _id: 2, status: "Pending" },
  { $set: { "payment.method": "Bank Transfer" } }
);

// Verify status and amount remain unchanged.
db.orders.findOne(
  { _id: 2 },
  { customer_name: 1, status: 1, payment: 1 }
);
