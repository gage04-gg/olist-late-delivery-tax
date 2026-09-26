DROP TABLE IF EXISTS causal.repeat_sample;

CREATE TABLE causal.repeat_sample AS
WITH valid_orders AS (
    SELECT *
    FROM marts.fct_orders
    WHERE order_status NOT IN ('canceled', 'unavailable')
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY purchase_ts, order_id) AS order_number
    FROM valid_orders
),

first_orders AS (
    SELECT *
    FROM ranked
    WHERE order_number = 1
),

repeat_flag AS (
    SELECT
        f.customer_unique_id,
        MAX(CASE
            WHEN v.purchase_date > f.purchase_date
             AND v.purchase_date <= f.purchase_date + 180 THEN 1
            ELSE 0
        END) AS repurchase_180
    FROM first_orders f
    LEFT JOIN valid_orders v ON f.customer_unique_id = v.customer_unique_id
    GROUP BY f.customer_unique_id
)

SELECT
    f.customer_unique_id,
    f.order_id AS first_order_id,
    f.purchase_date,
    f.purchase_month,
    f.customer_state,
    f.is_late AS late_first_order,
    f.days_late,
    f.order_value AS price,
    f.freight_value AS freight,
    f.distance_km,
    f.total_weight_g AS weight_g,
    f.n_items,
    f.promised_days,
    r.repurchase_180
FROM first_orders f
JOIN repeat_flag r ON f.customer_unique_id = r.customer_unique_id
WHERE f.is_delivered = 1
  AND f.purchase_date <= '2018-02-28';
