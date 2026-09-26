SELECT
    purchase_month,
    COUNT(*) AS n_orders,
    ROUND(SUM(order_value), 2) AS gmv
FROM marts.fct_orders
WHERE order_status NOT IN ('canceled', 'unavailable')
  AND purchase_month BETWEEN '2017-01-01' AND '2018-08-01'
GROUP BY purchase_month
ORDER BY purchase_month;
