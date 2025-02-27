# dbt Instacart Demo Project

A practical dbt project demonstrating how to transform raw Instacart e-commerce data into analytics-ready models on Snowflake. This project leverages the modern ELT approach—loading raw data into a cloud data warehouse and transforming it using dbt. Dependencies are managed with Poetry, and the project integrates CI/CD via GitHub Actions to automatically test and build dbt models.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Clone the Repository](#clone-the-repository)
  - [Set Up Your Environment with Poetry](#set-up-your-environment-with-poetry)
  - [Configure dbt Profile](#configure-dbt-profile)
  - [Load Raw Data into Snowflake](#load-raw-data-into-snowflake)
- [Running the Project](#running-the-project)
  - [Build the Models](#build-the-models)
  - [View Transformed Data](#view-transformed-data)
- [CI/CD Integration](#cicd-integration)
- [Files and Contents](#files-and-contents)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

This project uses **dbt** to transform raw Instacart data loaded into a Snowflake data warehouse. The transformation process is broken into several layers:

- **Sources:** Declaration of raw tables loaded into Snowflake.
- **Staging Models:** Light cleaning and standardization of raw data.
- **Intermediate Models:** Business logic combining staging models.
- **Mart Models:** Final, analytics-ready tables (e.g., customer order summary and department sales summary).

## Project Structure

```
dbt_instacart_demo/
├── .github/
│   └── workflows/
│       └── ci.yml                # GitHub Actions CI/CD configuration
├── dbt_project.yml               # dbt project configuration
├── pyproject.toml                # Python dependencies managed by Poetry
├── profiles.yml.template         # Template for dynamic generation of profiles.yml
├── models/
│   ├── sources.yml               # Raw data source definitions
│   ├── staging/                  # Staging models
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   └── stg_products.sql
│   ├── intermediate/             # Intermediate models
│   │   └── int_order_details.sql
│   └── marts/                    # Final mart models
│       ├── fct_customer_orders.sql
│       └── fct_department_sales.sql
└── README.md                     # This file
```

> **Important:** The dbt connection configuration (profiles.yml) is generated dynamically from `profiles.yml.template` in the CI/CD pipeline. Locally, you should create a `~/.dbt/profiles.yml` file.

## Setup Instructions

### Clone the Repository

Open your terminal and run:

```bash
git clone https://github.com/yourusername/dbt_instacart_demo.git
cd dbt_instacart_demo
```

### Set Up Your Environment with Poetry

1. **Install Poetry**
   Follow the instructions on [Poetry's website](https://python-poetry.org/docs/#installation).
   (Alternatively, this project's CI/CD uses a GitHub Action to install Poetry.)

2. **Install Dependencies:**
   From your project root, run:

   ```bash
   poetry install
   ```

### Configure dbt Profile

Create or update your global dbt profile at `~/.dbt/profiles.yml` with your Snowflake connection details. For example:

```yaml
dbt_instacart_demo:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: ACCOUNT                   # Your Snowflake account identifier
      user: YOUR_USERNAME                # Your Snowflake username
      password: YOUR_PASSWORD            # Your Snowflake password
      role: YOUR_ROLE                    # e.g., SYSADMIN
      database: YOUR_DATABASE            # Your target database name
      warehouse: YOUR_WAREHOUSE          # Your Snowflake warehouse
      schema: DBT_INSTACART_DEMO         # Schema where dbt models are built
```

On Linux/macOS, create/edit this file by running:

```bash
mkdir -p ~/.dbt
nano ~/.dbt/profiles.yml
```

### Load Raw Data into Snowflake

#### Download the Dataset

1. Download the Instacart Online Grocery Shopping dataset from [Kaggle](https://www.kaggle.com/datasets/yasserh/instacart-online-grocery-basket-analysis-dataset)
   - You'll need a Kaggle account to download the dataset
   - The dataset is approximately 200MB compressed and contains multiple CSV files

2. Extract the downloaded ZIP file to a local directory. You should have the following CSV files:
   - `orders.csv`
   - `order_products__prior.csv`
   - `order_products__train.csv`
   - `products.csv`
   - `aisles.csv`
   - `departments.csv`

#### Load Data into Snowflake

You can load the CSV files into Snowflake using one of these methods:

**Option 1: Using Snowflake's Web UI**

1. Log in to your Snowflake account
2. Create a new database or use an existing one
3. Create a schema for the raw data:
   ```sql
   CREATE SCHEMA RAW_INSTACART;
   ```
4. Navigate to the schema in the Snowflake UI
5. Click on "Load Data" and follow the wizard:
   - Select "Load local files"
   - Upload each CSV file
   - For each file, create a corresponding table (e.g., ORDERS, ORDER_PRODUCTS, etc.)
   - Map the columns appropriately
   - Complete the loading process


Ensure the following tables exist in your RAW_INSTACART schema before proceeding:
- orders
- order_products (combined from order_products__prior and order_products__train or just one of them)
- products
- aisles
- departments

## Running the Project

### Build the Models

With your Poetry environment active and data loaded, run the following dbt commands:

1. **Test the Connection:**

   ```bash
   dbt debug
   ```

2. **Build All Models:**

   ```bash
   dbt run
   ```

   This command compiles your SQL models, executes them in Snowflake, and creates/updates the transformed datasets.

3. **Run Data Tests:**

   ```bash
   dbt test
   ```

   This command verifies that your data meets the defined expectations.

### View Transformed Data

Log into the Snowflake Web UI, select your target database and schema (DBT_INSTACART_DEMO), and browse the created tables/views (e.g., stg_orders, int_order_details, fct_customer_orders). You can also query the tables directly, for example:

```sql
SELECT * FROM fct_customer_orders LIMIT 10;
```

## CI/CD Integration

This project uses GitHub Actions for CI/CD to automatically run your dbt project on every push or pull request to the main branch. The CI/CD pipeline performs the following tasks:

- Checks out your repository.
- Sets up Python (version 3.12) and installs Poetry.
- Installs project dependencies.
- Creates and configures the profiles.yml file with absolute paths for reliability.
- Runs dbt debug, dbt deps, dbt run, and dbt test.

> **Note**: Make sure you configure the following GitHub Secrets in your repository or environment:
> - `SNOWFLAKE_ACCOUNT`
> - `SNOWFLAKE_USER`
> - `SNOWFLAKE_PASSWORD`
> - `SNOWFLAKE_ROLE`
> - `SNOWFLAKE_DATABASE`
> - `SNOWFLAKE_WAREHOUSE`

## Files and Contents

**Global Files:**
- `~/.dbt/profiles.yml` (Not committed; generated dynamically via CI/CD)
- `dbt_project.yml` – Project configuration.
- `pyproject.toml` – Python dependencies (managed by Poetry).

**Model Files:**
- `models/sources.yml` – Raw data source definitions.

**Staging Models:**
- `models/staging/stg_orders.sql`
- `models/staging/stg_order_items.sql`
- `models/staging/stg_products.sql`

**Intermediate Model:**
- `models/intermediate/int_order_details.sql`

**Mart Models:**
- `models/marts/fct_customer_orders.sql`
- `models/marts/fct_department_sales.sql`

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements or bug fixes.

## License

This project is licensed under the MIT License.