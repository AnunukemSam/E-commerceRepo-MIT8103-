# MIT 8103 — Advanced Database Systems

**Assessment:** Individual Practical Database Portfolio · **2026/2027 First Semester**  
**Case study:** Simulated electronics retailer — E-commerce and Inventory Management System  
**Submission:** GitHub evidence repository + final 2–3 page LMS summary

## Case study and scope

This fictional retailer manages customers, product categories, products and stock, orders, line items and simulated payments. The original relational implementation uses **PostgreSQL 18** and six linked tables. A separate **MongoDB 8** model illustrates order documents. The replication experiment uses a PostgreSQL primary and read-only standby on the same Mac.

There is no real customer-facing application or live payment processing.

## Portfolio activities and evidence

| Portfolio | Practical work | Repository |
| --- | --- | --- |
| 1. Database Design and Modelling (7 marks) | Six-table schema, ER model, constraints, normalisation, tests | [Portfolio 1](portfolio-1-database-design/) |
| 2. Query Processing and Optimisation (7 marks) | Business SQL, EXPLAIN plans, ANALYZE/index analysis and benchmarking | [Portfolio 2](portfolio-2-query-optimisation/) |
| 3. Transactions and Concurrency (7 marks) | COMMIT/ROLLBACK, validation, exception handling and concurrent row locking | [Portfolio 3](portfolio-3-transactions-concurrency/) |
| 4. NoSQL and Advanced Data Models (7 marks) | MongoDB embedded order model, nested queries and CRUD | [Portfolio 4](portfolio-4-nosql/) |
| 5. Distributed and Cloud Database Exercise (6 marks) | Local PostgreSQL physical streaming replication, consistency, read-only standby and monitoring | [Portfolio 5](portfolio-5-distributed-cloud/) |

The individual folders contain code, evidence and documentation. The lab screenshots are original student-provided terminal or pgAdmin images, not generated recreations. Read each folder's evidence index for limits of what was captured.

## Submission status

**Five technical portfolio activities have been documented.** Before the LMS submission, the student must:
- Review technical descriptions/scripts against personal understanding and the lecturer's rubric.
- Write a **personal technical reflection** in their own words.
- Prepare the required **2–3 page LMS summary** covering all five activities with a GitHub link and references.
- Review AI-use disclosures, screenshots and repository access permissions.

### Repository access

**Public repository confirmed.** The lecturer has since updated the initial course brief: the GitHub portfolio should be **public**, so the assessor can open it directly. The repository is currently public. The older PDF's private-repository wording is superseded by this later instruction, as reported by the student.

## Integrity and safety

Fictional data only. Never commit credentials or unredacted personal account information. MongoDB's local unauthenticated development service and PostgreSQL local `trust` rules are for isolated laboratory use only. The two PostgreSQL instances run on the same physical MacBook and **do not provide production fault tolerance**.

## AI-use declaration

ChatGPT assisted with concept explanations, lab design, debugging, results interpretation, and drafting documentation. Commands were executed by the student on their own machine; original screenshots were provided by the student. The student is responsible for validating the submission and explaining all work.
