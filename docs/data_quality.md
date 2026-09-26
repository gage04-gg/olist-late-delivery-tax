# Data quality report

Checks run on 2026-09-26 against the raw tables loaded from Kaggle (`olistbr/brazilian-ecommerce`).
Queries: `sql/00_setup/03_data_quality_checks.sql`.

## 1. Column names

All 9 files match the documented Kaggle column list exactly, including the misspelled `product_name_lenght` and `product_description_lenght` (renamed to `_length` in staging).

`product_category_name_translation.csv` starts with a UTF-8 BOM (bytes `EF BB BF`). It has no effect because the header row is skipped with `HEADER true`.

Zip code prefixes have leading zeros (e.g. `01037`), so they are stored as `TEXT`, not integers.

## 2. Row counts (match the Kaggle page)

| Table | Rows |
|---|---:|
| orders | 99,441 |
| order_items | 112,650 |
| order_payments | 103,886 |
| order_reviews | 99,224 |
| customers | 99,441 |
| sellers | 3,095 |
| products | 32,951 |
| geolocation | 1,000,163 |
| category_translation | 71 |

## 3. Key uniqueness

| Key | Rows | Distinct | Unique? |
|---|---:|---:|---|
| orders.order_id | 99,441 | 99,441 | Yes |
| customers.customer_id | 99,441 | 99,441 | Yes (one per order) |
| customers.customer_unique_id | 99,441 | 96,096 | No, as expected: a real person can have several orders |
| sellers.seller_id | 3,095 | 3,095 | Yes |
| products.product_id | 32,951 | 32,951 | Yes |
| order_items (order_id, order_item_id) | 112,650 | 112,650 | Yes |
| order_payments (order_id, payment_sequential) | 103,886 | 103,886 | Yes |
| order_reviews.review_id | 99,224 | 98,410 | **No** (see section 7) |
| order_reviews.order_id | 99,224 | 98,673 | **No** (see section 7) |
| geolocation.zip_prefix | 1,000,163 | 19,015 | No, as expected: many points per prefix |

## 4. Order status and date nulls

| Status | Orders |
|---|---:|
| delivered | 96,478 |
| shipped | 1,107 |
| canceled | 625 |
| unavailable | 609 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |

| Column | Nulls |
|---|---:|
| purchase timestamp | 0 |
| approved_at | 160 |
| delivered_carrier_date | 1,783 |
| delivered_customer_date | 2,965 |
| estimated_delivery_date | 0 |

- 8 orders are `delivered` but have no customer delivery date, so they are dropped from the causal sample.
- 6 `canceled` orders have a delivery date. They stay out of the causal sample because it uses `order_status = 'delivered'`.
- `estimated_delivery_date` always has time 00:00:00 (0 exceptions), so it is a pure date, as expected.

## 5. Impossible or odd dates

| Check | Orders |
|---|---:|
| Delivered to customer before purchase | 0 |
| Approved before purchase | 0 |
| Estimate before purchase | 0 |
| Handed to carrier before purchase | 166 |
| Delivered to customer before handed to carrier | 23 |

The carrier-date problems don't affect our main variables (`days_late` uses only the customer delivery date and the estimate). We keep these orders, and the carrier date is not used in the causal analysis.

## 6. Money values

- `price ≤ 0`: 0 items. Min price 0.85, max 6,735.00.
- `freight_value < 0`: 0. `freight_value = 0`: 383 items (free shipping). **This matters for `log(freight)` in Test 2**, which needs a rule (see `decisions_log.md`).
- `payment_value ≤ 0`: 9 payment rows (vouchers). `payment_installments = 0`: 2 rows.

## 7. Reviews

- 768 orders have no review.
- Reviews per order: 98,126 orders have 1, 543 have 2 and 4 have 3.
- 789 `review_id`s are shared by more than one order. In every case the score is the same. This looks like one review covering several orders bought together, so `review_id` is **not** a key and we don't use it for joins.
- **Rule:** keep the latest review per order (order by `review_creation_date` desc, then `review_answer_timestamp` desc). There are no ties under this ordering. After dedupe: 98,673 reviews, one per order.
- Score distribution: 1★ 11,424 · 2★ 3,151 · 3★ 8,179 · 4★ 19,142 · 5★ 57,328.
- 8,127 reviews in the causal sample (8.5%) were created before the delivery timestamp. This is relevant to the pre-specified mechanism check.
- Note: `review_creation_date` has no time of day (always 00:00), so a review created on the delivery day counts as "before delivery" when compared with the delivery timestamp. See the open question in `decisions_log.md`.

## 8. Orders without items, payments or reviews

| Status | Orders without items |
|---|---:|
| unavailable | 603 |
| canceled | 164 |
| created | 5 |
| invoiced | 2 |
| shipped | 1 |

No delivered order is missing items. 1 order has no payment row.

## 9. Products and categories

- 610 products have no category → shown as `unknown` in staging.
- 2 products have no weight and 4 have weight 0.
- 2 categories have no English translation (`portateis_cozinha_e_preparadores_de_alimentos`, `pc_gamer`) → staging keeps the Portuguese name.

## 10. Geolocation

- 42 raw rows have coordinates outside Brazil's bounding box (lat −34 to 6, lng −74 to −34). They are dropped before averaging, which leaves 19,010 prefixes after averaging.
- 157 customer zip prefixes (278 customers) and 7 sellers have no match in geolocation → their distance will be NULL in `fct_orders`.

## 11. Multi-seller orders

| Sellers in order | Orders |
|---|---:|
| 1 | 97,388 |
| 2 | 1,219 |
| 3 | 54 |
| 4 | 3 |
| 5 | 2 |

Among delivered orders, 95,203 of 96,478 (**98.68%**) are single-seller. That is the sample for the seller fixed-effects model.

## 12. Time coverage

Purchases run from 2016-09-04 to 2018-10-17. Partial or near-empty months:

- 2016-09 (4 orders), 2016-10 (324), 2016-11 (0), 2016-12 (1)
- 2018-09 (16), 2018-10 (4)

**Trend charts use Jan 2017 – Aug 2018 only.**

## 13. Causal sample size

Delivered orders with a delivery date, an estimate and a review: **95,824**.
