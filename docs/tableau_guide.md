# Tableau Public build guide

This builds **2 dashboard pages** from the CSVs in `outputs/tableau/`. Tableau Public can't connect to PostgreSQL, so every chart reads a CSV.

| File | One row per | Used on |
|---|---|---|
| `kpi_monthly.csv` | month (Jan 2017 – Aug 2018) | Page 1 KPI row, trend |
| `state_summary.csv` | customer state | Page 1 map, Page 2 late % map |
| `top_categories.csv` | category (top 10) | Page 1 |
| `rdd_bins.csv` | days_late value (−20 … 20) | Page 2 RDD chart |
| `simulator.csv` | state × k (k = −5 … +5; state `ALL` = whole country) | Page 2 simulator |
| `seller_scorecard.csv` | seller | Page 2 scorecard |

---

## 0. Setup

1. Install **Tableau Public** (desktop) from public.tableau.com and sign in with a free account.
2. **Connect → To a File → Text file** → pick `outputs/tableau/kpi_monthly.csv`.
3. Add the other files as **separate data sources**: **Data → New Data Source → Text file**, once per CSV. Don't join them.
4. For every data source, check the column types on the Data Source tab:
   - `purchase_month` → **Date**
   - `state` in `state_summary.csv` → click the type icon → **Geographic Role → State/Province**. Also set `country` → **Geographic Role → Country/Region**.
   - `k_days_added`, `days_late` → **Number (whole)**

---

## Page 1: Overview

### Sheet "KPI – GMV" (repeat for the other KPIs)
1. New sheet, data source `kpi_monthly`.
2. Drag `gmv` to **Text** on the Marks card. It becomes `SUM(gmv)`.
3. Right-click → **Format** → Numbers → Currency (custom), prefix `R$`, display units **Millions**.
4. Make the text big: Marks → Text → `…` → font size 28.
5. Rename the sheet `KPI GMV`.

Make four more KPI sheets the same way:

| Sheet | Field | Aggregation |
|---|---|---|
| KPI Orders | `n_orders` | SUM |
| KPI AOV | create a calculated field `SUM([gmv]) / SUM([n_orders])` | — |
| KPI Late % | `late_pct` | AVG, suffix `%` |
| KPI Review | `avg_review` | AVG, 2 decimals |

(Late % and review are averaged over the months, which is close enough for a KPI tile. The exact overall values are 6.8% and 4.16.)

### Sheet "Monthly trend"
1. Data source `kpi_monthly`.
2. `purchase_month` to **Columns**, then right-click it → **Month** (the continuous, green version).
3. `gmv` to **Rows**.
4. Drag `late_pct` to the **right side** of the chart (a dual axis appears). Right-click the right axis → **Synchronize axis** off. Set Marks for `late_pct` to **Line** and for `gmv` to **Bar**.
5. Title: *GMV and late-delivery rate by month (Jan 2017 – Aug 2018)*.

### Sheet "State map"
1. Data source `state_summary`.
2. Double-click `state`. Tableau draws a map of Brazil.
3. Marks → **Map** (filled). Drag `gmv` to **Color**.
4. Drag `state_name`, `n_orders`, `aov`, `late_pct` to **Tooltip**.

### Sheet "Top categories"
1. Data source `top_categories`.
2. `category` to **Rows**, `gmv` to **Columns**. Sort descending (toolbar sort button).
3. `pct_of_total_gmv` to **Label**.

### Dashboard "Overview"
1. **New Dashboard**. Size → **Fixed**, 1200 × 900.
2. Drag in a **Horizontal** container at the top and put the 5 KPI sheets inside it.
3. Below: Monthly trend (full width). Below that, State map (left) and Top categories (right).
4. Add a **Text** object at the bottom: *Source: Olist public Kaggle dataset (CC BY-NC-SA 4.0). Trend excludes partial months.*

---

## Page 2: The Late-Delivery Tax

### Sheet "RDD chart"
1. Data source `rdd_bins`.
2. `days_late` to **Columns** (continuous, green: right-click → Dimension, then → Continuous).
3. `avg_review` to **Rows**. Marks → **Circle**.
4. `side` to **Color**. Pick blue for "On time or early" and red for "Late".
5. `n_orders` to **Size**.
6. Add the cutoff line: **Analytics** pane → drag **Reference Line** onto the chart → **Table** → value: create a parameter `Cutoff` = 0.5 → label *Promised date*. Line style: dashed.
7. Title: *Reviews fall steeply in the first week after the promised date*.

### Sheet "Late % map"
1. Data source `state_summary`. Same steps as the State map, but put `late_pct` on **Color**. Palette: **Orange-Red sequential**.
2. Title: *Late-delivery rate by customer state*.

### Sheet "Simulator"
1. Data source `simulator`.
2. Create a **parameter**: right-click in the Data pane → **Create Parameter**
   - Name: `k (days added to promise)`
   - Data type: Integer; Allowable values: **Range** −5 to 5, step 1; current value 0.
   - Right-click the parameter → **Show Parameter**. This is the **slider**.
3. Create a calculated field `Selected k`: `[k_days_added] = [k (days added to promise)]`.
4. Drag `Selected k` to **Filters** → keep **True**.
5. Drag `state` to **Filters** → keep only **ALL** (or show it as a dropdown filter so viewers can pick a state).
6. Drag `late_pct` and `change_in_low_reviews` to **Text**. Format `late_pct` to 1 decimal with a `%` suffix, and `change_in_low_reviews` to 0 decimals.
7. Optional second view: a bar chart with `k_days_added` on Columns and `late_pct` on Rows, **without** the k filter, plus a calculated field `IF [k_days_added] = [k (days added to promise)] THEN "Selected" ELSE "Other" END` on Color, so the chosen bar lights up.
8. Add a caption: *Assumes delivery times don't change. A longer promise may reduce conversion, which this data cannot measure.*

### Sheet "Seller scorecard"
1. Data source `seller_scorecard`.
2. Filter `is_top_5pct` = 1.
3. `seller_id` to **Rows** (right-click → Alias isn't needed; you can shorten it with a calculated field `LEFT([seller_id], 8)`).
4. `n_late` to **Columns**. Sort descending.
5. `late_pct` to **Color**, and `n_delivered`, `avg_review`, `pct_of_all_late_orders` to **Tooltip**.
6. Title: *Top 5% of sellers (148) account for 58.7% of late orders, and 50% of all orders*.

### Dashboard "The Late-Delivery Tax"
1. New dashboard, 1200 × 1000.
2. Top row: RDD chart (left, wider) and Late % map (right).
3. Bottom row: Simulator (with the slider showing) and Seller scorecard.
4. Text box with the headline result: *Seller fixed-effects model: a late order gets 1.95 fewer stars and is 52 pp more likely to get a 1–2★ review.*

---

## Publish

1. **File → Save to Tableau Public As…** Give it the name *The Late-Delivery Tax: Olist*.
2. In the browser, open the viz → **Settings** → make sure *Show Viz on Profile* is on.
3. Copy the URL and paste it into `README.md` where it says `DASHBOARD_LINK`.
