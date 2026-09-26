CREATE SCHEMA IF NOT EXISTS causal;

DROP TABLE IF EXISTS causal.rdd_sample;

CREATE TABLE causal.rdd_sample AS
SELECT
    order_id,
    days_late,
    is_late AS late,
    review_score,
    low_review,
    order_value AS price,
    freight_value AS freight,
    total_weight_g AS weight_g,
    distance_km,
    promised_days,
    CASE WHEN review_answered_ts > delivered_customer_ts THEN 1 ELSE 0 END AS answered_after_delivery
FROM marts.fct_orders
WHERE is_delivered = 1
  AND estimated_delivery_date IS NOT NULL
  AND review_score IS NOT NULL;
