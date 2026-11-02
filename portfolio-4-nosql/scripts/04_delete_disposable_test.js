// Portfolio 4 — Delete operation using a DISPOSABLE lab document
// This test has already been completed. It will recreate and then
// delete _id=99 if absent. Never delete genuine orders using this script.
use("electronics_store_nosql");

db.orders.insertOne({
  _id: 99,
  customer_name: "Test Customer",
  status: "Pending",
  test_record: true
});
db.orders.findOne({ _id: 99 });
db.orders.countDocuments({}); // Expected: 3 during initial experiment.

db.orders.deleteOne({ _id: 99, test_record: true });
db.orders.findOne({ _id: 99 }); // Expected: null.
db.orders.countDocuments({}); // Expected: 2.

db.orders.find(
  {},
  { _id: 1, customer_name: 1, status: 1, "payment.status": 1 }
);
