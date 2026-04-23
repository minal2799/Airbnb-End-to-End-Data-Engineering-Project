# 🏠 Airbnb End-to-End Data Engineering Project

## 📋 Overview

This project implements a complete end-to-end data engineering pipeline for Airbnb data using modern cloud technologies. The solution demonstrates best practices in data warehousing, transformation, and analytics using **Snowflake**, **dbt (Data Build Tool)**, and **AWS**.

The pipeline processes Airbnb listings, bookings, and hosts data through a medallion architecture (Bronze → Silver → Gold), implementing incremental loading, slowly changing dimensions (SCD Type 2), and creating analytics-ready datasets.

## 🏗️ Architecture

### DataFlow
```
Source Data (CSV) → AWS S3 → Snowflake (Staging) → Bronze Layer → Silver Layer → Gold Layer
                                                           ↓              ↓           ↓
                                                      Raw Tables    Cleaned Data   Analytics
```

### Technology Stack

- **Cloud Data Warehouse**: Snowflake
- **Transformation Layer**: dbt (Data Build Tool)
- **Cloud Storage**: AWS S3 (implied)
- **Version Control**: Git
- **Python**: 3.12+
- **Key dbt Features**:
  - Incremental models
  - Snapshots (SCD Type 2)
  - Custom macros
  - Jinja templating
  - Testing and documentation

## 📊 Data Model

### Medallion Architecture

#### 🥉 Bronze Layer (Raw Data)
Raw data ingested from staging with minimal transformations:
- `bronze_bookings` - Raw booking transactions
- `bronze_hosts` - Raw host information
- `bronze_listings` - Raw property listings

#### 🥈 Silver Layer (Cleaned Data)
Cleaned and standardized data:
- `silver_bookings` - Validated booking records
- `silver_hosts` - Enhanced host profiles with quality metrics
- `silver_listings` - Standardized listing information with price categorization

#### 🥇 Gold Layer (Analytics-Ready)
Business-ready datasets optimized for analytics:
- `obt` (One Big Table) - Denormalized fact table joining bookings, listings, and hosts
- `fact` - Fact table for dimensional modeling
- Ephemeral models for intermediate transformations

### Snapshots (SCD Type 2)
Slowly Changing Dimensions to track historical changes:
- `dim_bookings` - Historical booking changes
- `dim_hosts` - Historical host profile changes
- `dim_listings` - Historical listing changes

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
└── aws_dbt_snowflake_project/         # Main dbt project
    ├── dbt_project.yml                 # dbt project configuration
    ├── ExampleProfiles.yml             # Snowflake connection profile
    │
    ├── models/                         # dbt models
    │   ├── sources/
    │   │   └── sources.yml             # Source definitions
    │   ├── bronze/                     # Raw data layer
    │   │   ├── bronze_bookings.sql
    │   │   ├── bronze_hosts.sql
    │   │   └── bronze_listings.sql
    │   ├── silver/                     # Cleaned data layer
    │   │   ├── silver_bookings.sql
    │   │   ├── silver_hosts.sql
    │   │   └── silver_listings.sql
    │   └── gold/                       # Analytics layer
    │       ├── fact.sql
    │       ├── obt.sql
    │       └── ephemeral/              # Temporary models
    │           ├── bookings.sql
    │           ├── hosts.sql
    │           └── listings.sql
    │
    ├── macros/                         # Reusable SQL functions
    │   ├── generate_schema_name.sql    # Custom schema naming
    │   ├── multiply.sql                # Math operations
    │   ├── tag.sql                     # Categorization logic
    │   └── trimmer.sql                 # String utilities
    │
    ├── analyses/                       # Ad-hoc analysis queries
    │   ├── explore.sql
    │   ├── if_else.sql
    │   └── loop.sql
    │
    ├── snapshots/                      # SCD Type 2 configurations
    │   ├── dim_bookings.yml
    │   ├── dim_hosts.yml
    │   └── dim_listings.yml
    │
    ├── tests/                          # Data quality tests
    │   └── source_tests.sql
    │
    └── seeds/                          # Static reference data
```

## 🎯 Key Features

### 1. Incremental Loading
Bronze and silver models use incremental materialization to process only new/changed data:
```sql
{{ config(materialized='incremental') }}
{% if is_incremental() %}
    WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}
```

### 2. Custom Macros
Reusable business logic:
- **`tag()` macro**: Categorizes prices into 'low', 'medium', 'high'
  ```sql
  {{ tag('CAST(PRICE_PER_NIGHT AS INT)') }} AS PRICE_PER_NIGHT_TAG
  ```

### 3. Dynamic SQL Generation
The OBT (One Big Table) model uses Jinja loops for maintainable joins:
```sql
{% set configs = [...] %}
SELECT {% for config in configs %}...{% endfor %}
```

### 4. Slowly Changing Dimensions
Track historical changes with timestamp-based snapshots:
- Valid from/to dates automatically maintained
- Historical data preserved for point-in-time analysis

### 5. Schema Organization
Automatic schema separation by layer:
- Bronze models → `AIRBNB.BRONZE.*`
- Silver models → `AIRBNB.SILVER.*`
- Gold models → `AIRBNB.GOLD.*`

## 📈 Data Quality

### Testing Strategy
- Source data validation tests
- Unique key constraints
- Not null checks
- Referential integrity tests
- Custom business rule tests

### Data Lineage
dbt automatically tracks data lineage, showing:
- Upstream dependencies
- Downstream impacts
- Model relationships
- Source to consumption flow


