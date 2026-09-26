# Metrics dictionary

All metrics come from `marts.fct_orders` (one row per order), built by `sql/02_marts/01_fct_orders.sql`, unless another table is named.

## Base definitions

| Term | Definition |
|---|---|
| **Valid order** | `order_status NOT IN ('canceled', 'unavailable')` |
| **Delivered order** | `order_status = 'delivered'` and `delivered_customer_ts` is not null (`is_delivered = 1`) |
| **GMV** | Sum of item `price` for valid orders. Freight is excluded |
| **Trend window** | Jan 2017 – Aug 2018 (earlier and later months are partial) |
| **Main item** | The most expensive item in the order (tie → lowest `order_item_id`). It gives `main_category` and `main_seller_id` |
| **promised_days** | `estimated_delivery_date − purchase_date` (days) |
| **delivery_days** | `delivered_date − purchase_date` (days) |
| **days_late** | `delivered_date − estimated_delivery_date` (whole days; negative = early) |
| **is_late** | 1 if `days_late > 0` |
| **low_review** | 1 if `review_score ≤ 2` |
| **distance_km** | Haversine distance between the main seller's zip prefix and the customer's zip prefix, using average lat/lng per prefix |
| **customer_region** | IBGE macro-region of `customer_state` (North, Northeast, South, Southeast, Centre-West) |

Haversine formula (R = 6371 km, φ = latitude, λ = longitude, in radians):

1. a = sin²(Δφ / 2) + cos φ₁ · cos φ₂ · sin²(Δλ / 2)
2. c = 2 · asin(√a)
3. distance = R · c

## KPI queries

| File | Metric | Formula | Headline result |
|---|---|---|---|
| `q01_monthly_gmv_trend.sql` | Monthly GMV, order count | `SUM(order_value)`, `COUNT(*)` per `purchase_month`, valid orders | Total GMV R$13.49M from 98,207 valid orders (all months) |
| `q02_aov_by_month_and_state.sql` | Average order value | `SUM(order_value) / COUNT(orders)` per month and per state | Overall AOV R$137.42 |
| `q03_top_categories.sql` | Category GMV share | category GMV / `SUM(GMV) OVER ()`, item level | Top: health_beauty 9.3% |
| `q04_repeat_purchase_rate.sql` | Repeat-purchase rate | customers (`customer_unique_id`) with ≥ 2 valid orders / all customers | 3.04% (2,888 of 94,990) |
| `q05_retention_cohorts.sql` | Monthly retention | customers active in month k after their first-order month / cohort size | Under 1% in every month after the first |
| `q06_review_by_delivery_status.sql` | Avg review by delivery status | `AVG(review_score)` for early (< 0), on time (= 0), late (> 0) | Early 4.29, on time 4.03, late 2.27 |
| `q07_late_rate_by_state.sql` | Late-delivery rate by state | `SUM(is_late) / COUNT(*)` for delivered orders, `RANK()` | Worst: AL 21.4% |
| `q08_seller_concentration.sql` | Seller GMV concentration | GMV share by seller decile, `NTILE(10)` | Top 10% of sellers = 67.5% of GMV |
| `q09_payment_mix.sql` | Payment mix | share of payment value by type; `AVG(payment_installments)` | Credit card 78.3% of value, 3.5 instalments on average |
| `q10_cancellation_rate_by_month.sql` | Cancellation / non-delivery rate | canceled orders / all orders; non-delivered orders / all orders, per month | Cancellations stay around 0.5–1.2% |
| `sql/04_causal_prep/04_seller_scorecard.sql` | Seller late-order share | seller's late orders / all late orders | See `outputs/tables/seller_scorecard.csv` |
