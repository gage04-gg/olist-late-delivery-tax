# The Late-Delivery Tax: memo

*Analysis of the public Olist Kaggle dataset (Brazil, 2016–2018, ~99k orders). Personal project, not client work.*

**Question.** How much does the marketplace lose when orders arrive late, is lateness actually the *cause* of bad reviews, and what should be fixed first?

**Answer in one sentence.** Late delivery is the biggest controllable driver of bad reviews: a late order is **52 percentage points more likely to get a 1–2★ review** than the same seller's on-time order. The damage builds over the first week of delay, and it is concentrated in a small group of sellers and in the North-East.

## Three findings

1. **Lateness drives bad reviews.** Comparing each seller's late orders with their own on-time orders (seller, category, month and state fixed effects, plus order controls; N = 93,532): **−1.95 stars** and **+51.9 pp** probability of a 1–2★ review (both p < 0.001). The effect grows with the delay: −0.83★ at 1–3 days late, −2.00★ at 4–7 days and −2.40★ at 8–14 days. Applied to the 6,534 late orders, that is **about 3,390 extra low reviews, 28% of all low reviews**.
2. **There is no cliff exactly at the promised date.** The pre-registered regression discontinuity finds no significant jump between "on the day" and "1 day late" (−0.08★, p = 0.74). Validity checks also flag bunching just before the promise and differences in parcel weight, freight and promise length at the cutoff. Among reviews written *after* the parcel arrived, there is a significant drop (−0.28★, p < 0.001). Customers punish the experience of waiting, not the calendar date.
3. **Lateness is concentrated.** The **top 5% of sellers (148) account for 58.7% of late orders**. They also carry 50% of volume, and their late rate is 8.0% against 5.6% for everyone else. By customer state, late rates are highest in **Alagoas (21%), Maranhão (17%) and Sergipe (15%)**, against 6.8% overall.

## Size of the problem

| | |
|---|---|
| Late orders | 6,534 of 96,470 delivered (6.8%) |
| GMV delivered late | **R$0.99M** (7.5% of delivered GMV) |
| Extra 1–2★ reviews caused | **≈ 3,390** (95% CI 3,300–3,480) |
| Lost repeat purchases | **Not statistically significant** (−0.32 pp, p = 0.15; the test could only detect ≥ 0.67 pp). The 95% range is −R$0.6k to R$3.8k, because only about 2% of customers ever return |

The measurable cost is **reputational** (reviews), not direct lost revenue. The loyalty cost may exist, but this data is too small to measure it.

## Three recommendations

1. **Rescue orders heading for 4+ days late.** Most of the star loss happens after day 3. Flag these orders early and send proactive updates, vouchers or re-routing.
2. **Put the 148 highest-late-volume sellers on a delivery SLA,** with dispatch-time monitoring and ranking penalties. This is the smallest group that touches the largest share of late orders.
3. **Test a longer promise in the worst states.** The simulator shows that adding 3 days to the promise cuts the late share from 6.8% to 4.8% (about 970 fewer low reviews), assuming delivery times stay the same. Run it as an A/B test first, because a longer promise may reduce conversion.

## Limits

- Fixed effects remove stable seller and category differences, but not order-specific shocks (such as a parcel damaged in transit), so the effect may be somewhat overstated.
- The RDD failed its validity checks, so the causal claim rests on the fixed-effects model.
- The simulator ignores any conversion cost of a longer promise.
- Brazil 2016–2018 data. The pattern should generalise, but the numbers may not.

## What this means for Indian e-commerce (Tier-2/3 delivery)

India's growth is in Tier-2/3 cities, where last-mile delivery is slower and less predictable. That is the same situation as Brazil's North-East here, where late rates are 2–3 times the national average. The lessons carry over: the **promise** shown at checkout is a product decision, not just a logistics estimate. A **region-specific promise** (a longer, honest estimate for Tier-3 pin codes) and **early intervention once an order slips 3+ days** protect ratings more cheaply than faster delivery everywhere. For marketplaces like Meesho or Flipkart, whose sellers are small and ship themselves, a **seller-level late-dispatch SLA** targets the few sellers who generate most of the delays.
