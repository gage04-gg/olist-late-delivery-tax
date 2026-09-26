# Pre-registered analysis plan

Written and committed on 2026-09-26, **before any causal regression was run**. The git commit time of this file is the proof.

What had been seen before writing it: the data-quality checks, the 10 descriptive KPI queries (including `q06`, average review by early / on time / late), a descriptive table of average review by `days_late` used to sanity-check `fct_orders`, and the sample sizes and base rates below. No regression, RDD or fixed-effects model had been estimated.

Anything not in this plan is labelled **Exploratory** wherever it appears. Any change to this plan is written in `docs/decisions_log.md`, with the date and the reason, before it is run.

---

## Main hypothesis

Breaking the delivery promise **causes** lower review scores.

## Definitions (exact variable names)

| Name | Definition | Source |
|---|---|---|
| `days_late` | `delivered_customer_ts::date − estimated_delivery_date` (integer days; negative = early) | `marts.fct_orders` |
| `late` | 1 if `days_late ≥ 1`, else 0 | `is_late` |
| `review_score` | 1–5, latest review per order | `staging.order_reviews` |
| `low_review` | 1 if `review_score ≤ 2`, else 0 | |
| `price` | sum of item prices in the order (R$) | |
| `freight` | sum of item freight in the order (R$) | |
| `log_price` | `ln(price)` (every price is > 0) | |
| `log_freight` | `ln(1 + freight)`, because 383 items have freight = 0 (see decisions log) | |
| `weight_g` | sum of product weights in the order (grams) | |
| `distance_km` | haversine distance, main seller zip → customer zip | |
| `n_items` | number of items in the order | |
| `promised_days` | `estimated_delivery_date − purchase_date` | |
| `answered_after_delivery` | 1 if `review_answer_timestamp > order_delivered_customer_date` (both have a time of day) | |

## Samples

| Sample | Table | Rule | N |
|---|---|---|---:|
| RDD | `causal.rdd_sample` | delivered, non-null delivery date, estimate and review | 95,824 |
| Fixed effects | `causal.fe_sample` | RDD sample restricted to single-seller orders (98.68% of it) | 94,563 |
| Repeat purchase | `causal.repeat_sample` | first valid order per `customer_unique_id`, delivered, purchased on or before 2018-02-28 | 55,491 |

Rows with a missing control (`distance_km` or `weight_g`) are dropped listwise in the regressions that use that control. The N used is reported.

---

## Test 1: Regression discontinuity (PRIMARY)

**Main estimate** (run for `review_score` and for `low_review`):

```
rdrobust(y, x = days_late, c = 0.5, p = 1, kernel = "triangular", bwselect = "mserd")
```

Report: the conventional point estimate, the robust bias-corrected 95% CI and p-value, the bandwidth h and the effective N on each side.

**Discrete running-variable check:** OLS on orders with −7 ≤ `days_late` ≤ 7:

```
y = a + b·late + c·(days_late − 0.5) + d·late·(days_late − 0.5) + e
```

SEs clustered by the value of `days_late` (15 clusters; with this few clusters the SEs are noisy, which will be said). b is the jump.

**Validity checks** (reported whatever they show):

1. **Density:** `rddensity(X = days_late, c = 0.5)`, and report the p-value. Note: the running variable is discrete, so this test is only approximate.
2. **Covariate balance:** `rdrobust` with the same settings, outcome in turn = `price`, `freight`, `weight_g`, `distance_km`, `promised_days`. There should be no jump.
3. **Robustness** (fixed list, nothing more), for both outcomes:
   - bandwidth = 0.5 × h and 2 × h, where h is the main MSE-optimal bandwidth for that outcome
   - donut: drop `days_late ∈ {0, 1}`, re-run the main specification

**Mechanism check:** re-run the main Test 1 for both outcomes on `answered_after_delivery = 1` only. Report it next to the full-sample result.

## Test 2: Seller fixed-effects regression (PRIMARY)

```
y = β·late + γ1·log_price + γ2·log_freight + γ3·distance_km + γ4·weight_g + γ5·n_items + γ6·promised_days
    | seller_id + category + purchase_month + customer_state
```

- Outcomes: `review_score` and `low_review` (linear probability model)
- Sample: `causal.fe_sample`
- SEs: clustered by `seller_id` (CRV1). Tool: `pyfixest.feols`

**Dose-response** (outcome `review_score`, same controls and FE): replace `late` with `days_late` bins

`[≤ −15]`, `[−14, −8]`, `[−7, −1]` **(reference)**, `[0]`, `[1, 3]`, `[4, 7]`, `[8, 14]`, `[≥ 15]`

Plot the coefficients with 95% CIs.

## Test 3: Repeat purchase (SECONDARY, likely underpowered)

- Unit: customer (`customer_unique_id`), first valid order (earliest `purchase_ts`, tie → lowest `order_id`)
- Sample: `causal.repeat_sample`: the first order was delivered and placed on or before 2018-02-28, so every customer has ≥ 180 days of follow-up (data end in Aug–Oct 2018)
- Outcome: `repurchase_180` = 1 if the customer placed another valid order on a **later calendar day**, within 180 days of the first purchase date. Same-day orders are excluded because they are usually one basket split into several orders
- Model (LPM):

```
repurchase_180 = β·late_first_order + same six controls | customer_state + purchase_month
```

- SEs: heteroskedasticity-robust (HC1)

**Power statement (computed before running):**

- N = 55,491; share with a late first order = 6.61% → n_late ≈ 3,668, n_on_time ≈ 51,823
- Base rate of `repurchase_180` = 2.00% (lower than the ~3% assumed earlier)
- Two-sided α = 0.05, power = 0.80:

1. SE(difference) = √[ p(1 − p) · (1/n₁ + 1/n₀) ]
2. = √[ 0.02 × 0.98 × (1/3,668 + 1/51,823) ]
3. = √[ 0.0196 × 0.0002919 ] ≈ 0.00239
4. MDE = (z₀.₉₇₅ + z₀.₈₀) × SE = (1.960 + 0.842) × 0.00239 ≈ **0.0067**

So the test can only detect a drop of about **0.67 percentage points** (about a third of the base rate). Smaller true effects will likely come out as "not significant". That would be reported as low power, not as "no effect".

## Heterogeneity (ONE pre-specified split)

Re-run Test 2 (the `late` model, both outcomes) separately for:

- **North + Northeast** (`customer_region IN ('North', 'Northeast')`)
- **South + Southeast + Centre-West** (the rest)

Report both β and a z-test for the difference: z = (β₁ − β₂) / √(SE₁² + SE₂²).

## Significance rule

α = 0.05, two-sided. Tests 1 and 2 are primary. Test 3 and the heterogeneity split are secondary. Everything else is exploratory.

---

## How results feed the money sizing (Phase 3)

- **Causal effect used for money sizing and the simulator:** β on `low_review` from **Test 2** (the average effect across all late orders, not only those just past the cutoff). The Test 1 RDD estimate is shown next to it as a check.
- Extra low reviews caused = number of late orders × β(`low_review`).
- The repeat-purchase effect is converted to money only if Test 3 is significant. Otherwise it is shown only as a range, labelled "not statistically significant".
- **Simulator:** for k = −5 … +5 days added to the promise, `days_late_new = days_late − k`. Report the mechanical late share and the predicted change in low reviews = Δ(late orders) × β(`low_review`), overall and by state. Assumption: actual delivery times don't change. Limitation: a longer promise may lower conversion, which this data cannot measure.
