SELECT
    'month' AS breakdown,
    purchase_month::text AS breakdown_value,
    COUNT(*) AS n_orders,
    ROUND(SUM(order_value), 2) AS gmv,
    ROUND(AVG(order_value), 2) AS aov
FROM marts.fct_orders
WHERE order_status NOT IN ('canceled', 'unavailable')
  AND purchase_month BETWEEN '2017-01-01' AND '2018-08-01'
GROUP BY purchase_month

UNION ALL

SELECT
    'state' AS breakdown,
    customer_state AS breakdown_value,
    COUNT(*) AS n_orders,
    ROUND(SUM(order_value), 2) AS gmv,
    ROUND(AVG(order_value), 2) AS aov
FROM marts.fct_orders
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY customer_state

ORDER BY breakdown, breakdown_value;
