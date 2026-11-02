# Original MongoDB Screenshot Evidence

All four images were provided by the student on 2 November 2026. They are original, unmodified Terminal screenshots.

| File | Observable evidence |
| --- | --- |
| [01-final-order-state.png](01-final-order-state.png) | The final sorted projection shows two records: John Ade (#1, Confirmed/Successful, ₦1,725,000) and Mary Okafor (#2, Pending/Pending, ₦25,000); payment method is Bank Transfer in both documents. |
| [02-delete-test-document.png](02-delete-test-document.png) | Disposable test record #99 was inserted, found, and deleted. MongoDB returned deletedCount: 1, subsequent findOne returned null, and countDocuments fell from 3 to 2. |
| [03-update-payment-method.png](03-update-payment-method.png) | updateOne on order #2 returned matchedCount: 1 and modifiedCount: 1. The projected document confirms the nested payment.method changed to Bank Transfer while order and payment status remained Pending. |
| [04-insert-pending-order.png](04-insert-pending-order.png) | Order #2 inserted with acknowledged: true and insertedId: 2. A subsequent findOne displays the initial Card payment method, pending statuses, one Wireless Mouse, and Decimal128('25000.00'). |

**Evidence provenance and limits:** Earlier steps—installation/ping, initial insertion of order #1, and read queries A–D—were verified in chat from the student's copied Terminal output, but original screenshot files for these steps were not supplied. This folder does **not** claim to contain images of those earlier steps. Please capture additional original evidence if your lecturer requires screenshots of each operation.

The PNGs were not generated or reconstructed from text.
