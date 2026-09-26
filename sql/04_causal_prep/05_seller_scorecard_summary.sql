SELECT
    is_top_5pct,
    COUNT(*) AS n_sellers,
    SUM(n_delivered) AS n_delivered,
    SUM(n_late) AS n_late,
    ROUND(100.0 * SUM(n_late) / (SELECT SUM(n_late) FROM causal.seller_scorecard), 2) AS pct_of_all_late_orders,
    ROUND(100.0 * SUM(n_delivered) / (SELECT SUM(n_delivered) FROM causal.seller_scorecard), 2) AS pct_of_all_delivered_orders,
    ROUND(100.0 * SUM(n_late) / SUM(n_delivered), 2) AS late_pct
FROM causal.seller_scorecard
GROUP BY is_top_5pct
ORDER BY is_top_5pct DESC;
