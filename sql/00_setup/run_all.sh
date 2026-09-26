#!/bin/bash
set -e
cd "$(dirname "$0")/../.."

psql -d olist -v ON_ERROR_STOP=1 -f sql/00_setup/01_create_raw_tables.sql
psql -d olist -v ON_ERROR_STOP=1 -f sql/00_setup/02_load_raw.sql

for f in sql/01_staging/*.sql; do
    psql -d olist -v ON_ERROR_STOP=1 -f "$f"
done
