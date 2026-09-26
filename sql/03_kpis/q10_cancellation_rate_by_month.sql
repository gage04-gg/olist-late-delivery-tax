SELECT
    purchase_month,
    COUNT(*) AS n_orders,
    SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS n_canceled,
    SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) AS n_unavailable,
    SUM(CASE WHEN order_status <> 'delivered' THEN 1 ELSE 0 END) AS n_not_delivered,
    ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS canceled_pct,
    ROUND(100.0 * SUM(CASE WHEN order_status <> 'delivered' THEN 1 ELSE 0 END) / COUNT(*), 2) AS not_delivered_pct
FROM marts.fct_orders
WHERE purchase_month BETWEEN '2017-01-01' AND '2018-08-01'
GROUP BY purchase_month
ORDER BY purchase_month;
