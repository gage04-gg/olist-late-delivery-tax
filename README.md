# The Late-Delivery Tax

**A late order is 52 percentage points more likely to get a 1–2★ review than the same seller's on-time order.** That accounts for about 3,390 extra bad reviews, 28% of all low reviews on the marketplace.

A causal analysis of delivery-promise breaches, built on the **public Kaggle dataset** [Brazilian E-Commerce by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (~99k orders, 2016–2018). This is a personal portfolio project, not client work.

**Dashboard:** DASHBOARD_LINK (Tableau Public)
**One-page memo:** [docs/memo.md](docs/memo.md)

![Average review by days late](outputs/figures/rdd_review_by_days_late.png)

## Questions

1. How much does the marketplace lose when orders arrive late?
2. Is lateness actually the **cause** of bad reviews, or just correlated with them?
3. What should the company fix first?

## Results

| Test | Status | Result |
|---|---|---|
| **Seller fixed effects** (Test 2) | Primary | Late → **−1.95★** (95% CI −2.00 to −1.90) and **+51.9 pp** P(1–2★), p < 0.001, N = 93,532 |
| Dose-response | Primary | −0.16★ on the promised day, −0.83★ at 1–3 days late, −2.00★ at 4–7 days, −2.40★ at 8–14 days (vs 1–7 days early) |
| **Regression discontinuity** at the promise (Test 1) | Primary | **Not significant**: −0.08★, p = 0.74. Validity checks fail (bunching before the promise; weight, freight and promise length jump at the cutoff) |
| RDD, reviews answered after delivery | Pre-specified mechanism check | −0.28★ (p < 0.001), +5.7 pp P(1–2★) |
| Repeat purchase within 180 days (Test 3) | Secondary | **Not significant**: −0.32 pp, p = 0.15. Underpowered (MDE 0.67 pp on a 2% base rate) |
| North/North-East vs rest | Secondary | Similar star effect (p = 0.12); slightly larger low-review effect in N/NE (54.9 vs 51.1 pp, p = 0.035) |

**Size of the problem:** 6.8% of delivered orders are late, carrying R$0.99M of GMV. Lateness causes about 3,390 extra 1–2★ reviews. The top 5% of sellers account for 58.7% of late orders. Adding 3 days to the promise would cut the late share from 6.8% to 4.8%, if delivery times stayed the same.

**How to read the two primary tests together:** the fixed-effects model shows a large effect of being late. The RDD shows that the effect is not a cliff at the exact promised date: it builds over the first week of delay. The RDD also failed its validity checks, so the causal claim rests on the fixed-effects model.

## Method

- **PostgreSQL 16:** raw load → cleaned staging views → `marts.fct_orders` (one row per order: `days_late`, `promised_days`, haversine seller–customer distance, latest review) → 10 KPI queries → causal samples and a seller scorecard.
- **Pre-registration:** [`analysis_plan.md`](analysis_plan.md) was committed *before* any regression was run (see `git log`). Deviations are logged in [`docs/decisions_log.md`](docs/decisions_log.md).
- **Python:** `rdrobust` / `rddensity` (local-linear RDD, triangular kernel, MSE-optimal bandwidth, robust bias-corrected CIs, density test, covariate balance, bandwidth and donut robustness), `pyfixest` (seller + category + month + state fixed effects, SEs clustered by seller), linear probability model for repeat purchase.
- **Money sizing and promise-date simulator** (k = −5 … +5 days, overall and by state).
- **Tableau Public** dashboard (2 pages) built from CSV extracts.

## How to reproduce

1. Install PostgreSQL 16 and Python 3.11+.
   ```bash
   brew install postgresql@16
   brew services start postgresql@16
   export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
   createdb olist
   ```
2. Set up Python.
   ```bash
   python3.11 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   ```
3. Download the data into `data/raw/` (it is not committed). Either download it by hand from the Kaggle page and unzip it, or use a Kaggle API token:
   ```bash
   .venv/bin/kaggle datasets download -d olistbr/brazilian-ecommerce -p data/raw --unzip
   ```
4. Build everything: the database, KPI tables, causal samples and all four notebooks. It takes a few minutes.
   ```bash
   bash sql/00_setup/run_all.sh
   ```
5. Outputs appear in `outputs/tables/`, `outputs/figures/` and `outputs/tableau/`.

## Folder guide

| Folder | What's in it |
|---|---|
| `sql/00_setup` | Create and load the raw tables, data-quality checks, `run_all.sh` |
| `sql/01_staging` | Cleaned views, one per raw table |
| `sql/02_marts` | `fct_orders`, the one-row-per-order analysis table |
| `sql/03_kpis` | q01–q10 business KPI questions |
| `sql/04_causal_prep` | RDD, fixed-effects and repeat-purchase samples; seller scorecard |
| `notebooks` | 01 RDD · 02 seller fixed effects · 03 repeat purchase · 04 money sizing and simulator |
| `outputs/tables` | KPI and regression results (CSV + Markdown) |
| `outputs/figures` | Charts |
| `outputs/tableau` | CSV extracts for the dashboard |
| `docs` | Data quality, decisions log, metrics dictionary, Tableau guide, memo |

## Data licence

Olist data is licensed under **CC BY-NC-SA 4.0**. The raw data is not included in this repo.
