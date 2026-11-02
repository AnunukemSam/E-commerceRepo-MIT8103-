// MIT 8103 Portfolio 4 — MongoDB order documents
// Run in mongosh on the LOCAL MongoDB lab server.
// CAUTION: This setup is a one-time example for an empty database.
// Order #1 and #2 already exist in the student's electronics_store_nosql database.
// Do not rerun insertOne() in the existing database: duplicate _id errors are expected.
// The design is an independent educational copy, NOT synchronised with PostgreSQL.

use("electronics_store_nosql");

// When setting up a FRESH database, run:
// db.createCollection("orders");

db.orders.insertOne({
  _id: 1,
  customer_name: "John Ade",
  status: "Confirmed",
  items: [
    {
      sku: "LAP-001",
      product_name: "Laptop Pro",
      quantity: 2,
      unit_price: NumberDecimal("850000.00")
    },
    {
      sku: "MOU-001",
      product_name: "Wireless Mouse",
      quantity: 1,
      unit_price: NumberDecimal("25000.00")
    }
  ],
  total_amount: NumberDecimal("1725000.00"),
  payment: {
    method: "Bank Transfer",
    status: "Successful",
    amount: NumberDecimal("1725000.00")
  }
});

db.orders.insertOne({
  _id: 2,
  customer_name: "Mary Okafor",
  status: "Pending",
  items: [
    {
      sku: "MOU-001",
      product_name: "Wireless Mouse",
      quantity: 1,
      unit_price: NumberDecimal("25000.00")
    }
  ],
  total_amount: NumberDecimal("25000.00"),
  payment: {
    method: "Card",
    status: "Pending",
    amount: NumberDecimal("25000.00")
  }
});

db.orders.find().sort({ _id: 1 });
