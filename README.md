# 🏠 Airbnb End-to-End Data Engineering Pipeline

## 📋 Overview
An end-to-end ELT pipeline built on a cloud-native stack processing Airbnb listings, bookings, and hosts data through a Medallion Architecture (Bronze → Silver → Gold) using dbt, Snowflake, AWS S3, and Apache Airflow.

The project demonstrates core data engineering concepts including incremental loading, SCD Type 2 slowly changing dimensions, data quality testing, modular SQL transformation design, and production-grade pipeline orchestration.

- **Dataset:** Synthetic Airbnb dataset (5,700+ records across bookings, hosts, and listings)
- **GitHub:** [airbnb-pipeline](https://github.com/minal2799/Airbnb-End-to-End-Data-Engineering-Project)

---

## 🏗️ Architecture

```
CSV Source Data
      │
      ▼
  AWS S3 Bucket
  (External Stage)
      │
      ▼
Snowflake Staging
      │
      ├──► Bronze Layer  →  Raw ingestion, minimal transformation
      │
      ├──► Silver Layer  →  Cleaned, validated, standardized
      │
      └──► Gold Layer    →  Analytics-ready (Fact table, OBT, Snapshots)
```
Orchestrated by Apache Airflow (DAG: airbnb_dbt_pipeline)
  Scheduled: Daily | Executor: CeleryExecutor | Broker: Redis
  
### Why These Design Decisions?
- **Medallion Architecture:** Each layer has a clear contract — Bronze preserves raw source fidelity, Silver enforces data quality rules, Gold serves downstream analytics.
- **SCD Type 2:** Hosts and listings change over time. SCD Type 2 preserves full history with valid_from/valid_to timestamps enabling accurate point-in-time reporting.
- **Incremental loading:** Only new or changed records are processed on each run, keeping compute costs low as data grows.
- **Airflow orchestration:** Adds production-grade scheduling, task dependency management, and observability to the pipeline.

---

## 🔧 Technology Stack

| Tool | Purpose |
|------|---------|
| Snowflake | Cloud data warehouse |
| dbt | Transformation layer (models, tests, snapshots, macros) |
| AWS S3 | Raw file storage and external staging |
| Apache Airflow 3.2.2 | Pipeline orchestration and scheduling |
| Docker Compose | Containerized Airflow deployment |
| Python 3.12+ | Pipeline ingestion scripts |
| Git | Version control |

**Key dbt Features Used:**
- Incremental models
- Snapshots (SCD Type 2)
- Custom Jinja macros
- Data quality testing
- Dynamic SQL with Jinja loops

---

## ⚙️ Pipeline Orchestration (Apache Airflow)

The dbt pipeline is orchestrated using Apache Airflow 3.2.2 running via Docker Compose.

### DAG: `airbnb_dbt_pipeline`

dbt_run → dbt_test
---

- **dbt_run:** Executes all 8 dbt models across Bronze → Silver → Gold layers
- **dbt_test:** Runs automated data quality tests after transformation completes
- **Schedule:** Daily (`@daily`)
- **Executor:** CeleryExecutor with Redis broker and PostgreSQL metadata store

### Why Airflow?
Previously the pipeline required manual execution. Airflow adds:
- Automatic daily scheduling
- Task dependency enforcement — dbt_test only runs if dbt_run succeeds
- Full run history, logging, and observability via UI
- Production-grade reliability

---

## 📊 Data Model

### 🥉 Bronze Layer — Raw Ingestion
| Table | Records | Description |
|-------|---------|-------------|
| bronze_bookings | 5,000 | Raw booking transactions from S3 |
| bronze_hosts | 200 | Raw host records |
| bronze_listings | 500 | Raw property listings |

### 🥈 Silver Layer — Cleaned & Validated
| Table | Description |
|-------|-------------|
| silver_bookings | Validated bookings with null handling |
| silver_hosts | Host profiles with quality metrics |
| silver_listings | Standardized listings with price categorization |

### 🥇 Gold Layer — Analytics Ready
| Table | Description |
|-------|-------------|
| fact | Fact table for dimensional modeling |
| obt | One Big Table — denormalized join across all dimensions |
| dim_bookings | SCD Type 2 snapshot tracking booking history |
| dim_hosts | SCD Type 2 snapshot tracking host profile changes |
| dim_listings | SCD Type 2 snapshot tracking listing changes |

---

## 📁 Project Structure

```
Airbnb-End-to-End-Data-Engineering-Project/
├── README.md
├── airbnb_dbt_dag.py          # Airflow DAG for pipeline orchestration
├── pyproject.toml
├── main.py
│
└── dbt_snowflake_project/     # Main dbt project
├── dbt_project.yml
├── models/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── macros/
│   ├── multiply.sql
│   ├── tag.sql
│   └── trimmer.sql
├── snapshots/
└── tests/

---
---

## 🚀 Getting Started

### Prerequisites
- Python 3.12+
- Snowflake account (free trial works)
- AWS S3 bucket with source CSVs uploaded
- Docker Desktop (for Airflow)
- dbt CLI: `pip install dbt-snowflake`

### Installation

**1. Clone the repo**
```bash
git clone https://github.com/minal2799/Airbnb-End-to-End-Data-Engineering-Project.git
cd Airbnb-End-to-End-Data-Engineering-Project
```

**2. Configure Snowflake connection**

Create `~/.dbt/profiles.yml`:
```yaml
dbt_snowflake_project:
  outputs:
    dev:
      account: <your-account-identifier>
      database: AIRBNB
      password: <your-password>
      role: ACCOUNTADMIN
      schema: dbt_schema
      threads: 4
      type: snowflake
      user: <your-username>
      warehouse: COMPUTE_WH
  target: dev
```

**3. Set up Snowflake resources**
```sql
-- Create database and schemas
CREATE DATABASE AIRBNB;
CREATE SCHEMA AIRBNB.STAGING;
CREATE SCHEMA AIRBNB.BRONZE;
CREATE SCHEMA AIRBNB.SILVER;
CREATE SCHEMA AIRBNB.GOLD;
```

**4. Load source data**
```sql
-- Create S3 stage and load CSVs
COPY INTO AIRBNB.STAGING.BOOKINGS FROM @snowstage/bookings.csv FILE_FORMAT = csv_format;
COPY INTO AIRBNB.STAGING.HOSTS FROM @snowstage/hosts.csv FILE_FORMAT = csv_format;
COPY INTO AIRBNB.STAGING.LISTINGS FROM @snowstage/listings.csv FILE_FORMAT = csv_format;
```

---

## ▶️ Usage

### Run dbt manually
```bash
cd dbt_snowflake_project

dbt debug                          # Test connection
dbt run                            # Run all models
dbt run --full-refresh             # Full rebuild
dbt test                           # Run all tests
dbt snapshot                       # Run SCD Type 2 snapshots
dbt docs generate && dbt docs serve # View lineage docs
```

### Run via Airflow
```bash
# Start Airflow
cd "Airflow Tutorial"
docker compose up -d

# Access UI
http://localhost:8080

# Trigger DAG manually or wait for daily schedule
# DAG: airbnb_dbt_pipeline
```

---

## 🎯 Key Features

### 1. Incremental Loading
```sql
{{ config(materialized='incremental') }}
{% if is_incremental() %}
WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}
```

### 2. Custom Jinja Macros
```sql
{{ tag('CAST(PRICE_PER_NIGHT AS INT)') }} AS PRICE_PER_NIGHT_TAG
```

### 3. SCD Type 2 Snapshots
Tracks historical changes with valid_from/valid_to timestamps across all three dimensions.

### 4. Airflow DAG
```python
dbt_run = BashOperator(
    task_id="dbt_run",
    bash_command="dbt run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt",
)
dbt_test = BashOperator(
    task_id="dbt_test", 
    bash_command="dbt test --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt",
)
dbt_run >> dbt_test
```

---

## 📈 Data Quality

Testing strategy across all layers:
- `not_null` — critical ID and key fields
- `unique` — primary key constraints
- `accepted_values` — categorical field validation
- `relationships` — referential integrity Bronze → Silver

---

## 💡 What I Learned
- How to design a layered pipeline where each layer has a clear, testable contract
- When SCD Type 2 is the right choice vs simpler overwrite strategies
- How dbt macros reduce SQL duplication without sacrificing readability
- Trade-offs between incremental and full-refresh materialization
- How to orchestrate dbt pipelines with Airflow using Docker and CeleryExecutor
- Why task dependency management matters in production pipelines

---

## 👤 Author
**Minal Randive**
MS Information Systems — Northeastern University
[LinkedIn](https://linkedin.com/in/minalrandive) | [GitHub](https://github.com/minal2799)
