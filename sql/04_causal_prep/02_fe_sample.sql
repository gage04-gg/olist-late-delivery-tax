DROP TABLE IF EXISTS causal.fe_sample;

CREATE TABLE causal.fe_sample AS
SELECT
    order_id,
    seller_id,
    main_category AS category,
    purchase_month,
    customer_state,
    customer_region,
    days_late,
    is_late AS late,
    review_score,
    low_review,
    order_value AS price,
    freight_value AS freight,
    distance_km,
    total_weight_g AS weight_g,
    n_items,
    promised_days
FROM marts.fct_orders
WHERE is_delivered = 1
  AND estimated_delivery_date IS NOT NULL
  AND review_score IS NOT NULL
  AND n_sellers = 1;
