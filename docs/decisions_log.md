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

## Open questions (decide before `analysis_plan.md` is committed)

1. **log(freight) with zero freight.** 383 items have `freight_value = 0`. Options: `log(1 + freight)`, or drop those orders. It must be fixed in the plan before any regression.
2. **"Review created after delivery" for the mechanism check.** `review_creation_date` has no time (always 00:00). Options: compare dates (`review_date > delivered_date`, or `>=`). It must be fixed in the plan.
