WITH all_customers AS (
    SELECT DISTINCT customer_unique_id
    FROM marts.fct_orders
    WHERE order_status NOT IN ('canceled', 'unavailable')
),

repeat_customers AS (
    SELECT customer_unique_id
    FROM marts.fct_orders
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY customer_unique_id
    HAVING COUNT(*) >= 2
)

SELECT
    (SELECT COUNT(*) FROM all_customers) AS n_customers,
    (SELECT COUNT(*) FROM repeat_customers) AS n_repeat_customers,
    ROUND(100.0 * (SELECT COUNT(*) FROM repeat_customers) / (SELECT COUNT(*) FROM all_customers), 2) AS repeat_rate_pct;
