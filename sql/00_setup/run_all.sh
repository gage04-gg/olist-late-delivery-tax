#!/bin/bash
set -e
cd "$(dirname "$0")/../.."

psql -d olist -v ON_ERROR_STOP=1 -f sql/00_setup/01_create_raw_tables.sql
psql -d olist -v ON_ERROR_STOP=1 -f sql/00_setup/02_load_raw.sql

for f in sql/01_staging/*.sql; do
    psql -d olist -v ON_ERROR_STOP=1 -f "$f"
done

for f in sql/02_marts/*.sql; do
    psql -d olist -v ON_ERROR_STOP=1 -f "$f"
done

for f in sql/03_kpis/*.sql; do
    name=$(basename "$f" .sql)
    psql -d olist -v ON_ERROR_STOP=1 --csv -f "$f" -o "outputs/tables/$name.csv"
done

for f in sql/04_causal_prep/01_rdd_sample.sql sql/04_causal_prep/02_fe_sample.sql sql/04_causal_prep/03_repeat_sample.sql sql/04_causal_prep/04_seller_scorecard.sql; do
    psql -d olist -v ON_ERROR_STOP=1 -f "$f"
done

psql -d olist -v ON_ERROR_STOP=1 --csv -f sql/04_causal_prep/05_seller_scorecard_summary.sql -o outputs/tables/seller_scorecard_summary.csv

cd notebooks
for nb in 01_rdd_promise_date.ipynb 02_seller_fixed_effects.ipynb 03_repeat_purchase.ipynb 04_money_sizing_and_simulator.ipynb; do
    ../.venv/bin/jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=1800 "$nb"
done
