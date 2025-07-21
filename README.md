# SQL Server Data Warehouse Project — Medallion Architecture

Welcome to my data warehouse project. This repository showcases my understanding of modern data architecture using **SQL Server** and the **Medallion architecture** (bronze, silver, and gold layers). The project is based on **mock data** designed to simulate real-world business scenarios and demonstrates best practices in data modeling, ETL processes, and warehouse documentation.

---

## Project Overview

This data warehouse project applies the **Medallion architecture**, a layered approach to organizing data pipelines for scalability, quality, and clarity. It consists of:

- **Bronze Layer:** Raw data ingestion, minimal transformation
- **Silver Layer:** Cleaned, deduplicated, and structured data
- **Gold Layer:** Aggregated and business-ready datasets for analytics

This structure helps ensure transparency, modularity, and reusability across the pipeline.

---

## Tech Stack

- **SQL Server** – Primary database and ETL engine
- **T-SQL** – Data transformation and querying
- **SSMS** – Development environment
- **Excel / CSV** – Input mock datasets
- **Markdown** – Documentation

---

## Repository Structure

```
/
├── datasets/   # Raw and cleaned mock data files  
├── scripts/    # SQL scripts for ETL and transformations  
├── docs/       # Architecture diagrams, project notes  
├── tests/      # SQL test cases to validate transformations  
└── README.md   # Project documentation
```
---

## Deliverables

- 🔹 SQL scripts for creating and populating each warehouse layer  
- 🔹 Architecture overview and pipeline documentation (in `/docs`)  
- 🔹 Test cases validating data integrity and logic  
- 🔹 Mock datasets and data dictionaries (in `/datasets`)

---

## Notes

> This is a **mock project** created solely for educational and portfolio purposes. While the data and scenarios are fictional, the technical structure reflects real-world data warehouse principles.
