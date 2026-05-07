# 🏠 Airbnb End-to-End Data Engineering Pipeline

## 📋 Overview

An end-to-end ELT pipeline built on a cloud-native stack processing Airbnb listings, bookings, and hosts data through a **Medallion Architecture** (Bronze → Silver → Gold) using **dbt**, **Snowflake**, and **AWS S3**.

The project demonstrates core data engineering concepts including incremental loading, SCD Type 2 slowly changing dimensions, data quality testing, and modular SQL transformation design.

**Dataset:** Synthetic Airbnb dataset (5,700+ records across bookings, hosts, and listings)  
**GitHub:** [airbnb-pipeline](https://github.com/minalrandive/airbnb-pipeline)

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

### Why These Design Decisions?

**Medallion Architecture:** Each layer has a clear contract — Bronze preserves raw source fidelity, Silver enforces data quality rules, Gold serves downstream analytics. This separation makes debugging, reprocessing, and schema changes isolated and low-risk.

**SCD Type 2 for dimensions:** Hosts update pricing and availability frequently. Listings change attributes over time. SCD Type 2 preserves the full history with `valid_from`/`valid_to` timestamps, enabling accurate point-in-time reporting — critical for any platform where historical state matters.

**Incremental loading:** Avoids full table scans on each pipeline run. Only new or changed records are processed, which keeps compute costs low and runtime fast as data grows.

**Ephemeral models in Gold:** Intermediate joins that don't need to be materialized as tables are kept ephemeral — reducing storage overhead while keeping SQL modular and readable.

---

## 🔧 Technology Stack

| Tool | Purpose |
|------|---------|
| Snowflake | Cloud data warehouse |
| dbt | Transformation layer (models, tests, snapshots, macros) |
| AWS S3 | Raw file storage and external staging |
| Python 3.12+ | Pipeline orchestration scripts |
| Git | Version control |

**Key dbt Features Used:**
- Incremental models
- Snapshots (SCD Type 2)
- Custom macros
- Jinja templating
- Testing and documentation

---

## 📊 Data Model

### 🥉 Bronze Layer — Raw Ingestion
| Table | Description |
|-------|-------------|
| `bronze_bookings` | Raw booking transactions from S3 |
| `bronze_hosts` | Raw host records |
| `bronze_listings` | Raw property listings |

### 🥈 Silver Layer — Cleaned & Validated
| Table | Description |
|-------|-------------|
| `silver_bookings` | Validated bookings with null handling |
| `silver_hosts` | Host profiles with quality metrics |
| `silver_listings` | Standardized listings with price categorization |

### 🥇 Gold Layer — Analytics Ready
| Table | Description |
|-------|-------------|
| `fact` | Fact table for dimensional modeling |
| `obt` | One Big Table — denormalized join across all dimensions |
| `dim_bookings` | SCD Type 2 snapshot tracking booking history |
| `dim_hosts` | SCD Type 2 snapshot tracking host profile changes |
| `dim_listings` | SCD Type 2 snapshot tracking listing changes |

---

## 📁 Project Structure

```
AWS_DBT_Snowflake/
├── README.md                           # This file
├── pyproject.toml                      # Python dependencies
├── main.py                             # Main execution script
│
├── SourceData/                         # Raw CSV data files
│   ├── bookings.csv
│   ├── hosts.csv
│   └── listings.csv
│
├── DDL/                                # Database schema definitions
│   ├── ddl.sql                         # Table creation scripts
│   └── resources.sql
│
└── aws_dbt_snowflake_project/          # Main dbt project
    ├── dbt_project.yml
    ├── ExampleProfiles.yml
    │
    ├── models/
    │   ├── sources/sources.yml
    │   ├── bronze/
    │   ├── silver/
    │   └── gold/
    │       └── ephemeral/
    │
    ├── macros/
    │   ├── generate_schema_name.sql
    │   ├── multiply.sql
    │   ├── tag.sql
    │   └── trimmer.sql
    │
    ├── analyses/
    ├── snapshots/
    ├── tests/
    └── seeds/
```

---

## 🚀 Getting Started

### Prerequisites
- Python 3.12+
- Snowflake account (free trial works)
- AWS S3 bucket with source CSVs uploaded
- dbt CLI: `pip install dbt-snowflake`

### Installation

**1. Clone the repo**
```bash
git clone https://github.com/minalrandive/airbnb-pipeline.git
cd airbnb-pipeline
```

**2. Create virtual environment**
```bash
python -m venv .venv
source .venv/bin/activate        # Linux/Mac
.venv\Scripts\Activate.ps1       # Windows PowerShell
```

**3. Install dependencies**
```bash
pip install -r requirements.txt
# or
pip install -e .
```

Core dependencies:
- `dbt-core>=1.11.2`
- `dbt-snowflake>=1.11.0`
- `sqlfmt>=0.0.3`

**4. Configure Snowflake connection**

Create `~/.dbt/profiles.yml`:
```yaml
aws_dbt_snowflake_project:
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

**5. Set up Snowflake resources**
```bash
# Execute DDL/ddl.sql and DDL/resources.sql in Snowflake to create schemas and staging tables
```

**6. Load source data**

Upload CSVs from `SourceData/` to Snowflake staging:
```
bookings.csv  → AIRBNB.STAGING.BOOKINGS
hosts.csv     → AIRBNB.STAGING.HOSTS
listings.csv  → AIRBNB.STAGING.LISTINGS
```

---

## ▶️ Usage

```bash
cd aws_dbt_snowflake_project

dbt debug                              # Test connection
dbt deps                               # Install dependencies
dbt run                                # Run all models
dbt run --select bronze.*              # Run bronze layer only
dbt run --select silver.*              # Run silver layer only
dbt run --select gold.*                # Run gold layer only
dbt test                               # Run all tests
dbt snapshot                           # Run SCD Type 2 snapshots
dbt docs generate && dbt docs serve    # Generate and view lineage docs
dbt build                              # Run models + tests + snapshots together
```

---

## 🎯 Key Features

### 1. Incremental Loading
Bronze and Silver models process only new/changed records on each run:

```sql
{{ config(materialized='incremental') }}

{% if is_incremental() %}
WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}
```

### 2. Custom Macros
Business logic abstracted into reusable macros:

```sql
-- tag() macro: categorizes price into low / medium / high
{{ tag('CAST(PRICE_PER_NIGHT AS INT)') }} AS PRICE_PER_NIGHT_TAG
```

### 3. Dynamic SQL with Jinja
The OBT Gold model uses Jinja loops for maintainable multi-table joins, reducing hardcoded SQL and making schema changes easier to propagate.

### 4. Slowly Changing Dimensions
SCD Type 2 snapshots track historical changes with `valid_from`/`valid_to` timestamps, enabling point-in-time analysis across all three dimensions.

### 5. Schema Isolation by Layer
```
Bronze models → AIRBNB.BRONZE.*
Silver models → AIRBNB.SILVER.*
Gold models   → AIRBNB.GOLD.*
```

---

## 📈 Data Quality

**Testing strategy across all layers:**
- `not_null` — critical ID and key fields
- `unique` — primary key constraints
- `accepted_values` — categorical field validation
- `relationships` — referential integrity Bronze → Silver
- Custom business rule tests in `tests/source_tests.sql`

**Data lineage:** dbt tracks upstream dependencies and downstream impacts across all models automatically — viewable via `dbt docs serve`.

---

## 🔐 Security & Best Practices

- Never commit `profiles.yml` with credentials — use environment variables for sensitive data
- Role-based access control (RBAC) enforced across Snowflake schemas aligned with least-privilege principles
- SQL formatting with `sqlfmt`
- Incremental models reduce compute costs and avoid unnecessary full scans
- Ephemeral models used for intermediate transformations to minimize storage

---

## 🐛 Troubleshooting

**Connection error**
- Verify Snowflake credentials in `profiles.yml`
- Confirm warehouse is running in Snowflake UI
- Run `dbt debug` to isolate the issue

**Compilation error**
- Run `dbt debug` to check project configuration
- Verify model dependencies and `ref()` calls
- Check Jinja syntax in macros

**Incremental load issues**
- Run `dbt run --full-refresh` to rebuild from scratch
- Verify source data has valid `CREATED_AT` timestamps

---

## 💡 What I Learned

- How to design a layered pipeline where each layer has a clear, testable contract
- When SCD Type 2 is the right choice vs simpler overwrite or SCD Type 1 strategies
- How dbt macros reduce SQL duplication without sacrificing readability
- Trade-offs between incremental and full-refresh materialization — incremental is faster day-to-day but requires careful watermark logic
- Why enforcing data quality at the transformation layer is more reliable than trusting source data to be clean
- How role-based access control in Snowflake maps to real-world data governance requirements

---

## 👤 Author

**Minal Randive**  
MS Information Systems — Northeastern University  
[LinkedIn](https://linkedin.com/in/minalrandive) | [GitHub](https://github.com/minalrandive)
