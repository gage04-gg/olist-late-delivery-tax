# The Late-Delivery Tax

How much does an e-commerce marketplace lose when orders arrive late? Is lateness actually the *cause* of bad reviews? And what should the company fix first?

Built on the **public Kaggle dataset** [Brazilian E-Commerce by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (~100k orders, 2016–2018).

> Work in progress. Results will be added here.

## How to reproduce

1. Install PostgreSQL 16 and Python 3.11+.
   ```bash
   brew install postgresql@16
   brew services start postgresql@16
   createdb olist
   ```
2. Set up Python.
   ```bash
   python3.11 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   ```
3. Download the data into `data/raw/` (the raw data is not committed). Either download it by hand from the Kaggle page and unzip it, or use a Kaggle API token:
   ```bash
   .venv/bin/kaggle datasets download -d olistbr/brazilian-ecommerce -p data/raw --unzip
   ```
4. Build the database.
   ```bash
   bash sql/00_setup/run_all.sh
   ```
5. Data-quality checks: `psql -d olist -f sql/00_setup/03_data_quality_checks.sql`

## Folder guide

| Folder | What's in it |
|---|---|
| `sql/00_setup` | Create and load the raw tables, data-quality checks |
| `sql/01_staging` | Cleaned views, one per raw table |
| `sql/02_marts` | Analysis tables (`fct_orders`, …) |
| `sql/03_kpis` | Business KPI questions |
| `sql/04_causal_prep` | Samples for the causal analysis |
| `notebooks` | RDD, fixed effects, repeat purchase, money sizing |
| `docs` | Data quality, decisions log, metrics dictionary, memo |

## Data licence

Olist data is licensed under CC BY-NC-SA 4.0.
