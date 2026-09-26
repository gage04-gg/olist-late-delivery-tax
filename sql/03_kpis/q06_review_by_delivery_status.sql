SELECT
    CASE
        WHEN days_late < 0 THEN '1_early'
        WHEN days_late = 0 THEN '2_on_time'
        ELSE '3_late'
    END AS delivery_status,
    COUNT(*) AS n_orders,
    ROUND(AVG(review_score), 3) AS avg_review_score,
    ROUND(100.0 * AVG(low_review), 2) AS low_review_pct
FROM marts.fct_orders
WHERE is_delivered = 1
  AND review_score IS NOT NULL
GROUP BY delivery_status
ORDER BY delivery_status;
