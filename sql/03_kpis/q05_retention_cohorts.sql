WITH customer_orders AS (
    SELECT
        customer_unique_id,
        purchase_month,
        MIN(purchase_month) OVER (PARTITION BY customer_unique_id) AS cohort_month
    FROM marts.fct_orders
    WHERE order_status NOT IN ('canceled', 'unavailable')
),

with_month_number AS (
    SELECT DISTINCT
        customer_unique_id,
        cohort_month,
        (EXTRACT(YEAR FROM purchase_month) - EXTRACT(YEAR FROM cohort_month)) * 12
            + (EXTRACT(MONTH FROM purchase_month) - EXTRACT(MONTH FROM cohort_month)) AS months_since_first
    FROM customer_orders
),

cohort_counts AS (
    SELECT
        cohort_month,
        months_since_first,
        COUNT(DISTINCT customer_unique_id) AS n_customers
    FROM with_month_number
    GROUP BY cohort_month, months_since_first
)

SELECT
    cohort_month,
    MAX(CASE WHEN months_since_first = 0 THEN n_customers END) AS cohort_size,
    ROUND(100.0 * MAX(CASE WHEN months_since_first = 1 THEN n_customers END) / MAX(CASE WHEN months_since_first = 0 THEN n_customers END), 2) AS m1_pct,
    ROUND(100.0 * MAX(CASE WHEN months_since_first = 2 THEN n_customers END) / MAX(CASE WHEN months_since_first = 0 THEN n_customers END), 2) AS m2_pct,
    ROUND(100.0 * MAX(CASE WHEN months_since_first = 3 THEN n_customers END) / MAX(CASE WHEN months_since_first = 0 THEN n_customers END), 2) AS m3_pct,
    ROUND(100.0 * MAX(CASE WHEN months_since_first = 4 THEN n_customers END) / MAX(CASE WHEN months_since_first = 0 THEN n_customers END), 2) AS m4_pct,
    ROUND(100.0 * MAX(CASE WHEN months_since_first = 5 THEN n_customers END) / MAX(CASE WHEN months_since_first = 0 THEN n_customers END), 2) AS m5_pct,
    ROUND(100.0 * MAX(CASE WHEN months_since_first = 6 THEN n_customers END) / MAX(CASE WHEN months_since_first = 0 THEN n_customers END), 2) AS m6_pct
FROM cohort_counts
WHERE cohort_month BETWEEN '2017-01-01' AND '2018-08-01'
GROUP BY cohort_month
ORDER BY cohort_month;
