# DATA WAREHOUSE BUILDING PROJECT

## TABLE OF CONTENTS
&nbsp;&nbsp;&nbsp;[1. Introduction](#1-introduction)

&nbsp;&nbsp;&nbsp;[2. Data Architecture](#2-data-architecture)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[2.1 Medallion Architecture](#21-medallion-architecture)

&nbsp;&nbsp;&nbsp;[3. Data Modelling](#3-modelling)

&nbsp;&nbsp;&nbsp;[4. Project Implementation](#4-project-implementation)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.1 Data Preparation](#41-data-preparation)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2 Table Schema Design](#42-table-schema-design)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2.1 Bronze Layer](#421-bronze-layer)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2.2 Silver Layer](#422-silver-layer)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2.3 Gold Layer](#423-gold-layer)

&nbsp;&nbsp;&nbsp;[5. Data Dictionary](#5-data-dictionary)

## 1. Introduction
&nbsp;&nbsp;&nbsp;In the digital era, the ability to transform raw data into actionable insights serves as the core competitive advantage for any enterprise. However, data fragmentation across distinct business departments often forces data consolidation to be manual, time-consuming, and highly prone to delaying strategic decision-making.

![data-flow (old systems)](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(old%20systems).png)

&nbsp;&nbsp;&nbsp;This project is built to definitively resolve these challenges by designing and deploying a centralized Data Warehouse. This system acts as a unified repository, consolidating operational data from diverse sources—such as Sales, Accounting, and HR—at any given time to optimize query performance for analytical activities and enterprise reporting.

![data-warehouse](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(new-system).png)

&nbsp;&nbsp;&nbsp;By automating the collection, cleansing, and standardization of disparate data streams, the system establishes a "Single Source of Truth". This eliminates reliance on repetitive manual workflows, providing a solid foundation for advanced BI reporting, trend forecasting, and time-and-cost-optimized strategic decision-making.

## 2. Data Architecture
&nbsp;&nbsp;&nbsp;Before breaking ground on building a "warehouse", a solid blueprint tailored to specific business requirements is essential. In data analytics, this blueprint is referred to as **Data Architecture**. Data architecture serves as the backbone, governing the processes of data collection, storage, processing, and distribution, which empowers businesses to locate the exact information needed to make rapid, well-informed decisions across scenarios.

&nbsp;&nbsp;&nbsp;Several prominent data architectures exist today, including Lambda, Kappa, and Data Mesh, each possessing distinct advantages and trade-offs. For this project, I chose the **Medallion Architecture** due to its consistency and layer-based data quality control, which aligns perfectly with the characteristics of the selected datasets.
### 2.1 Medallion Architecture
&nbsp;&nbsp;&nbsp;**Medallion Architecture** is a data design pattern that processes data through three distinct logical layers: **Bronze**, **Silver**, and **Gold**. Each layer has a specific data processing mandate before the information is made available for consumption.
- **Bronze Layer:** Stores raw, unaltered data ingested directly from source systems to guarantee data safety and historical traceability.
- **Silver Layer:** Cleanses, enriches, and standardizes the data, ensuring absolute consistency across disparate source systems.
- **Gold Layer:** Restructures the processed data into specialized analytical data schemas tailored to business concepts, delivering clean, business-ready data.

![Architecture](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Medallion-Architecture.png)

## 3. Data Modelling
&nbsp;&nbsp;&nbsp;The data modeling process is executed within the Gold layer, once the core business entities are identified (restructuring the processed data from the Silver layer into tables containing entity attributes), such as: customers, products, and sales. These analytical tables are classified into two main types: **Fact Tables** (containing metrics and quantitative data for calculation) and **Dimension Tables** (containing descriptive context attributes). These entities are interconnected based on their business relationships to form the final data model. The schema representing these entity relationships is termed a database schema.

&nbsp;&nbsp;&nbsp;Two of the most prevalent data warehousing schemas are the Star Schema and the Snowflake Schema.
- **Star Schema:** A widely adopted dimensional modeling design in data warehousing, consisting of a central Fact table surrounded by peripheral Dimension tables containing detailed descriptive attributes.
- **Snowflake Schema:** An extension of the Star Schema where dimension tables are further normalized into multiple levels to minimize data redundancy. This model is ideal for maintaining high data integrity and complex logical structures.

![Schema](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Schemas.png)

## 4. Project Implementation
&nbsp;&nbsp;&nbsp;The vital first step of the project involves [Database Initialization](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/init_database.sql).
### 4.1 Data Preparation
&nbsp;&nbsp;&nbsp;The initial raw datasets originate from two hypothetical systems—CRM and ERP—and are stored within the [datasets](https://github.com/trungbui011/data-warehouse-project/tree/main/datasets) directory as CSV files.
### 4.2 Table Schema Design
&nbsp;&nbsp;&nbsp;Prior to establishing the schemas for each specific Medallion layer, the core database must be provisioned on the RDBMS (SQL Server or Oracle). This standardizes the underlying infrastructure, ensuring consistency and optimal performance for all subsequent data pipeline stages.
  #### 4.2.1 Bronze Layer
&nbsp;&nbsp;&nbsp;**Step 1: DDL (Data Definition Language) Initialization:** Constructing the table structures and defining data types that strictly match the raw source file structures. [ddl_bronze.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/1.%20bronze_layer/ddl_bronze.sql)

&nbsp;&nbsp;&nbsp;**Step 2: Automation with Stored Procedures:** Developing database stored procedures to optimize data ingestion efficiency and standardize the operational ingestion pipeline. [proc_load_bronze.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/1.%20bronze_layer/proc_load_bronze.sql)

&nbsp;&nbsp;&nbsp;Raw data brought into the Bronze layer retains its original structure and formatting entirely. The primary purpose is to maintain absolute lineage auditability and easily isolate bugs if issues arise downstream in the Silver or Gold layers. Data ingestion is scheduled automatically, integrating system checks to handle data duplication, optimizing storage utilization and data processing workflows.

![](https://github.com/trungbui011/data-warehouse-project/blob/main/images/bronze_tables.png)

  #### 4.2.2 Silver Layer
&nbsp;&nbsp;&nbsp;**Step 1: Schema Design (DDL):** Re-defining target tables with optimized, clean data types. While similar to the Bronze layer, this step enforces much stricter structural constraints. [ddl_silver.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/2.%20silver_layer/ddl_silver.sql)

&nbsp;&nbsp;&nbsp;**Step 2: Data Transformation & Cleansing (ETL):** The Silver layer actively resolves the following data quality issues:
- **Data Cleansing:** Removing duplicate records and handling 'NULL' values using business-compliant defaults.
- **Format Standardization:** Enforcing unified formats for date types and resolving string variations (e.g., consolidating 'US', 'USA', and 'United States' into a single 'United States' standard).
- **Key Synchronization:** Rectifying fragmentation issues where identical business keys are formatted differently across source systems. For instance, the same customer ID **'11000'** appears as:
  - **'NASAW00011000'** in the 'cid' column of **BRONZE.erp_cust_az12**,
  - **'AW00011000'** in the 'cst_key' column of **BRONZE.crm_cust_info**,
  - **'AW-00011000'** in the 'cid' column of **BRONZE.erp_loc_a101**.

&nbsp;&nbsp;&nbsp;Consequently, a unified key format is enforced to guarantee referential integrity and precision prior to performing table `JOIN` operations in the Gold layer. To facilitate comprehensive audit tracking, each table is enriched with a `dwh_create_date` metadata column to track the exact data ingestion timestamp (down to the millisecond).

&nbsp;&nbsp;&nbsp;Review the Silver layer Stored Procedure script here: [proc_load_silver.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/2.%20silver_layer/proc_load_silver.sql). 
  #### 4.2.3 Gold Layer
&nbsp;&nbsp;&nbsp;This represents the final layer where data is structured into a Star Schema model proportional to the dataset's scale. This optimizes analytical query performance and streamlines Business Intelligence (BI) visualization.

&nbsp;&nbsp;&nbsp;Relationships across tables are mapped explicitly using Primary Keys (PK):

![objects relationship](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Objects%20relationship.png)

&nbsp;&nbsp;&nbsp;The end-to-end data flow of this project is detailed in the diagram below:

![](https://github.com/trungbui011/data-warehouse-project/blob/main/images/project-data-flow.png)

&nbsp;&nbsp;&nbsp;Below is the SQL DDL script for provisioning the three core Gold layer objects based on the data flow: [ddl_gold.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/3.%20gold_layer/ddl_gold.sql)

&nbsp;&nbsp;&nbsp;Representing the dimensional model layout for these three core objects:

![scm](https://github.com/trungbui011/data-warehouse-project/blob/main/images/star%20schema.png)

## 5. Data Dictionary
&nbsp;&nbsp;&nbsp;The detailed data catalog describes the explicit column names, data types, and business definitions for each analytical object. Please refer to the full data dictionary versions in [English](https://github.com/trungbui011/data-warehouse-project/blob/main/docs/data_catalog%20(English%20Version).md) or [Vietnamese](https://github.com/trungbui011/data-warehouse-project/blob/main/docs/data_catalog%20(Vietnamese%20Version).md).
