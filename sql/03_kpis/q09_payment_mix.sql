SELECT
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS n_orders,
    ROUND(SUM(p.payment_value), 2) AS total_paid,
    ROUND(100 * SUM(p.payment_value) / (SELECT SUM(payment_value) FROM staging.order_payments), 2) AS pct_of_value,
    ROUND(AVG(p.payment_installments), 2) AS avg_installments
FROM staging.order_payments p
GROUP BY p.payment_type
ORDER BY total_paid DESC;
