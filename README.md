# dbt Instacart Demo Project

A practical dbt project that demonstrates transforming raw Instacart e-commerce data into analytics-ready models on Snowflake. This project illustrates the modern ELT approach—loading raw data into a cloud data warehouse and transforming it using dbt. The repository also includes guidance on using Poetry for dependency management and integrating the project with scheduling/orchestration tools like Airflow or dbt Cloud.

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
- [CI/CD Configuration](#cicd-configuration)
- [Automation & Scheduling](#automation--scheduling)
  - [Airflow Integration](#airflow-integration)
  - [dbt Cloud Integration](#dbt-cloud-integration)
- [Files and Contents](#files-and-contents)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

This project uses dbt to transform raw Instacart data loaded into a Snowflake data warehouse. The transformation layers include:

- **Sources**: Declaration of raw tables loaded into Snowflake.
- **Staging Models**: Light cleaning and standardization of raw data.
- **Intermediate Models**: Business logic combining staging models.
- **Mart Models**: Final, analytics-ready tables (e.g., customer order summary and department sales summary).

Dependencies are managed using Poetry, and the project can be scheduled using tools like Airflow or dbt Cloud.

## Project Structure

```bash
dbt_instacart_demo/
├── dbt_project.yml                # Project configuration
├── pyproject.toml                 # Python dependencies managed by Poetry
├── models/
│   ├── sources.yml                # Raw data source definitions
│   ├── staging/                   # Staging models
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   └── stg_products.sql
│   ├── intermediate/              # Intermediate models
│   │   └── int_order_details.sql
│   └── marts/                     # Final mart models
│       ├── fct_customer_orders.sql
│       └── fct_department_sales.sql
└── README.md                      # This file
```

Note: Your dbt connection configuration is stored in a global file at `~/.dbt/profiles.yml` (see below).

## Setup Instructions

### Clone the Repository

Open your terminal and run:

```bash
git clone https://github.com/yourusername/dbt_instacart_demo.git
cd dbt_instacart_demo
```

### Set Up Your Environment with Poetry

1. Install Poetry (if not already installed). Follow the instructions [here](https://python-poetry.org/docs/#installation).

2. Install Dependencies:

```bash
poetry install
```

3. Activate the Poetry Shell:

```bash
poetry shell
```

### Configure dbt Profile

Create or edit the file `~/.dbt/profiles.yml` (this is not inside the project directory) with your Snowflake connection details:

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
      schema: DBT_INSTACART_DEMO         # The schema where dbt models will be built
      authenticator: externalbrowser     # Adjust as needed
```

To create/edit this file on Linux/macOS:

```bash
mkdir -p ~/.dbt
nano ~/.dbt/profiles.yml
```

### Load Raw Data into Snowflake

Download the Instacart Online Grocery Shopping dataset and load the CSV files into your Snowflake database under a schema (e.g., RAW_INSTACART). You can load the data using:

- Snowflake's Web UI (data upload wizard)
- Snowflake's command-line tools with PUT and COPY INTO commands

Ensure that the raw tables (orders, order_items, products, aisles, departments) exist in the RAW_INSTACART schema.

## Running the Project

### Build the Models

With your environment active (Poetry shell) and data loaded, run the following commands:

1. Test the Connection:

```bash
dbt debug
```

2. Build All Models:

```bash
dbt run
```

This command compiles your SQL models, executes them in your data warehouse, and creates/updates the transformed datasets.

3. Run Data Tests:

```bash
dbt test
```

This verifies that your data meets the defined expectations (e.g., non-null, uniqueness).

### View Transformed Data

After building the models:

1. Log into the Snowflake Web UI.

2. Select your target database and schema (DBT_INSTACART_DEMO).

3. Browse the tables/views created (e.g., stg_orders, int_order_details, fct_customer_orders).

4. Run queries such as:

```sql
SELECT * FROM fct_customer_orders LIMIT 10;
```

## CI/CD Configuration

This project uses GitHub Actions to run CI/CD pipelines automatically on pushes or pull requests to the main branch. Below is an example configuration file located at `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  dbt-ci:
    runs-on: ubuntu-latest
    env:
      DBT_PROFILES_DIR: ~/.dbt
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.8'

      - name: Install Poetry
        run: |
          curl -sSL https://install.python-poetry.org | python -
          echo "${HOME}/.local/bin" >> $GITHUB_PATH

      - name: Install dependencies via Poetry
        run: poetry install --no-interaction --no-root

      - name: Configure dbt profiles.yml
        run: |
          mkdir -p ~/.dbt
          cat <<EOF > ~/.dbt/profiles.yml
          dbt_instacart_demo:
            target: dev
            outputs:
              dev:
                type: snowflake
                account: "${{ secrets.SNOWFLAKE_ACCOUNT }}"
                user: "${{ secrets.SNOWFLAKE_USER }}"
                password: "${{ secrets.SNOWFLAKE_PASSWORD }}"
                role: "${{ secrets.SNOWFLAKE_ROLE }}"
                database: "${{ secrets.SNOWFLAKE_DATABASE }}"
                warehouse: "${{ secrets.SNOWFLAKE_WAREHOUSE }}"
                schema: DBT_INSTACART_DEMO
                authenticator: externalbrowser
          EOF

      - name: Run dbt debug
        run: poetry run dbt debug

      - name: Install dbt dependencies
        run: poetry run dbt deps

      - name: Build dbt models
        run: poetry run dbt run

      - name: Run dbt tests
        run: poetry run dbt test
```

**Important:** Make sure to set the following GitHub repository secrets:
* `SNOWFLAKE_ACCOUNT`
* `SNOWFLAKE_USER`
* `SNOWFLAKE_PASSWORD`
* `SNOWFLAKE_ROLE`
* `SNOWFLAKE_DATABASE`
* `SNOWFLAKE_WAREHOUSE`

## Automation & Scheduling

### Airflow Integration

To automate dbt runs with Airflow, create a DAG file (e.g., `dbt_run_dag.py`) in your Airflow DAGs folder:

```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'dbt_run',
    default_args=default_args,
    description='Run dbt models on a schedule',
    schedule_interval='@daily',  # Change as needed
)

dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command='cd /path/to/dbt_instacart_demo && poetry run dbt run',
    dag=dag,
)

dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command='cd /path/to/dbt_instacart_demo && poetry run dbt test',
    dag=dag,
)

dbt_run >> dbt_test
```

Replace `/path/to/dbt_instacart_demo` with the absolute path to your project.

### dbt Cloud Integration

1. Sign up/log in at dbt Cloud.
2. Connect your GitHub repository by creating a new project in dbt Cloud.
3. Configure your Snowflake connection within the dbt Cloud environment.
4. Set up a scheduled job to run commands like `dbt run` and `dbt test` automatically.

## Files and Contents

### Global Files
- `~/.dbt/profiles.yml`
  - Contains your Snowflake connection settings.
  
- `dbt_project.yml`
  - Defines the project configuration and model settings.
  
- `pyproject.toml`
  - Managed by Poetry; lists your Python dependencies.

### Model Files
- `models/sources.yml`
  - Declares raw data sources (e.g., orders, order_items, products).

- Staging Models:
  - `models/staging/stg_orders.sql`
  - `models/staging/stg_order_items.sql`
  - `models/staging/stg_products.sql`

- Intermediate Model:
  - `models/intermediate/int_order_details.sql`

- Mart Models:
  - `models/marts/fct_customer_orders.sql`
  - `models/marts/fct_department_sales.sql`

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests for enhancements or bug fixes.

## License

This project is licensed under the MIT License.