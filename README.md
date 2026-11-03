# MIT 8103 — Advanced Database Systems

**Assessment:** Individual Practical Database Portfolio  
**Academic Session:** 2026/2027 — First Semester  
**Programme:** Master of Information Technology  
**Institution:** MIVA Open University

## Project Overview

This repository contains my practical coursework portfolio for MIT 8103 — Advanced Database Systems. The project explores database design, query optimisation, transaction management, NoSQL databases, and distributed database concepts through practical implementations and experiments.

The selected case study is a **simulated electronics retailer operating an E-commerce and Inventory Management System**.

The system manages customer information, product categories, inventory, customer orders, order items, and simulated payments. PostgreSQL 18 was used for the relational database implementation, while MongoDB 8 was used to explore document-oriented data modelling.

## Portfolio Activities

| Portfolio | Description | Documentation |
|---|---|---|
| **1. Database Design and Modelling** | Designed and implemented a six-table relational database, including an ER diagram, primary and foreign keys, constraints, and normalisation. | [Portfolio 1](portfolio-1-database-design/) |
| **2. Query Processing and Optimisation** | Developed business queries, analysed execution plans, evaluated indexing strategies, and measured query performance. | [Portfolio 2](portfolio-2-query-optimisation/) |
| **3. Transactions and Concurrency** | Demonstrated COMMIT, ROLLBACK, atomic order processing, transaction isolation, and row-level locking. | [Portfolio 3](portfolio-3-transactions-concurrency/) |
| **4. NoSQL and Advanced Data Models** | Implemented a MongoDB document model using embedded documents and arrays, and demonstrated CRUD operations and queries. | [Portfolio 4](portfolio-4-nosql/) |
| **5. Distributed and Cloud Database Exercise** | Configured PostgreSQL primary–standby streaming replication, verified data replication, tested read-only access, and examined consistency and availability. | [Portfolio 5](portfolio-5-distributed-cloud/) |

## Technologies and Tools

- **PostgreSQL 18:** Relational database design, SQL queries, indexing, transactions, and streaming replication.
- **MongoDB 8:** Document-oriented database modelling and CRUD operations.
- **pgAdmin 4:** Database administration and SQL execution.
- **MongoDB Shell (mongosh):** MongoDB administration and queries.
- **GitHub:** Version control, documentation, and evidence management.
- **macOS:** Local environment for implementing and testing database operations.

## Implementation and Evidence

Each portfolio folder contains relevant implementation scripts, technical documentation, experimental results, and supporting evidence.

The evidence includes original screenshots captured during database operations, query execution, transaction testing, and replication experiments.

The PostgreSQL replication exercise was implemented using two separate database instances on the same MacBook. It demonstrates physical streaming replication but does not represent a production high-availability or cloud deployment.

All customer records and payment information used in this project are fictional and intended solely for academic demonstration.

## Key Learning Outcomes

Through this project, I gained practical experience in:

- Designing and implementing relational database structures.
- Understanding how indexing and database statistics influence query performance.
- Managing data consistency through transactions and concurrency control.
- Modelling and querying embedded documents in MongoDB.
- Configuring and troubleshooting PostgreSQL streaming replication.
- Evaluating database design decisions based on application requirements.

## GitHub Repository

The repository is publicly accessible for assessment and contains the five portfolio activities, their implementation files, technical reports, and supporting evidence.

## References

Technical references and relevant documentation are included in the individual portfolio reports. These include official PostgreSQL and MongoDB documentation.

## AI Use Declaration

ChatGPT was used as a learning aid for explaining database concepts, developing practical exercises, troubleshooting errors, interpreting results, and supporting technical documentation. The database operations were performed and tested in my local environment, with supporting screenshots and outputs included in the repository. I remain responsible for reviewing, understanding, and explaining the submitted work.
