# Decisions log

Every judgement call, with the date and the reason.

| Date | Decision | Reason |
|---|---|---|
| 2026-09-26 | Zip code prefixes stored as `TEXT` | They have leading zeros (`01037`); an integer type would drop them and break joins |
| 2026-09-26 | Duplicate reviews: keep the latest per order (`review_creation_date` desc, then `review_answer_timestamp` desc) | Rule from the project plan. 547 orders had 2–3 reviews, and there are no ties under this ordering |
| 2026-09-26 | `review_id` is not used as a key | 789 review IDs are shared across orders (same score each time) |
| 2026-09-26 | Geolocation: drop points outside Brazil's bounding box, then average lat/lng per zip prefix | 42 raw points fall outside Brazil and would distort the averages |
| 2026-09-26 | Missing category → `unknown`; missing translation → keep the Portuguese name | 610 products have no category; 2 categories have no translation |
| 2026-09-26 | Trend charts cover Jan 2017 – Aug 2018 only | 2016 months and Sep–Oct 2018 are partial or near-empty |
| 2026-09-26 | Orders with a carrier date before purchase (166) or a customer date before the carrier date (23) are kept | These fields aren't used in `days_late` or the causal models |
| 2026-09-26 | GMV = sum of item price for orders not canceled/unavailable (freight excluded) | Standard marketplace definition; freight is a pass-through cost |
| 2026-09-26 | Main item = most expensive item in the order; it defines `main_category` and `main_seller_id` (used for distance) | An order has one category and one distance in the models; 1.3% of orders have several sellers |
| 2026-09-26 | Order weight = sum of product weights | Heavier baskets ship slower; the sum matches the whole parcel |
| 2026-09-26 | `log_freight = ln(1 + freight)` | 383 items have freight = 0; this keeps them instead of dropping them. Fixed before any regression |
| 2026-09-26 | Mechanism check uses `review_answer_timestamp > order_delivered_customer_date` | `review_creation_date` has no time of day, but the answer timestamp does, so this is the cleanest "answered after receiving" rule. Fixed before any regression |
| 2026-09-26 | Repurchase = another valid order on a later calendar day, within 180 days | Same-day orders are usually one basket split into several orders |
| 2026-09-26 | Test 3 base rate is 2.0%, not the ~3% assumed in my project brief | q04's 3.04% counts any repeat over the whole period; the 180-day window with same-day orders excluded is lower. MDE recomputed in the plan |
| 2026-09-26 | Money sizing uses the Test 2 β on `low_review`; the RDD is shown as a check | The RDD is local to orders just past the promise; money sizing needs the average effect over all late orders |
| 2026-09-26 | Before writing the plan, a descriptive table of average review by `days_late` (−3 … 4) was viewed as a sanity check of `fct_orders` | Disclosed for transparency; no regression had been run |
| 2026-09-26 | RDD robustness "bandwidth ×0.5" is recorded as *could not be estimated* when rdrobust fails, with no substitute bandwidth | With h ≈ 1.9 days, only a handful of distinct `days_late` values fall inside the window, so rdrobust's bias-correction matrix is singular. Replacing it with another bandwidth would be specification hunting. Decided after the error, before any re-run |
