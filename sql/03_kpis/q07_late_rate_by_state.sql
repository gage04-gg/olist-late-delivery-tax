WITH state_late AS (
    SELECT
        customer_state,
        COUNT(*) AS n_delivered,
        SUM(is_late) AS n_late,
        100.0 * SUM(is_late) / COUNT(*) AS late_pct,
        AVG(delivery_days) AS avg_delivery_days,
        AVG(promised_days) AS avg_promised_days
    FROM marts.fct_orders
    WHERE is_delivered = 1
    GROUP BY customer_state
)

SELECT
    RANK() OVER (ORDER BY late_pct DESC) AS late_rank,
    customer_state,
    n_delivered,
    n_late,
    ROUND(late_pct, 2) AS late_pct,
    ROUND(avg_delivery_days, 1) AS avg_delivery_days,
    ROUND(avg_promised_days, 1) AS avg_promised_days
FROM state_late
ORDER BY late_rank;
