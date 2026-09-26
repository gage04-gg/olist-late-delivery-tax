DROP TABLE IF EXISTS causal.seller_scorecard;

CREATE TABLE causal.seller_scorecard AS
WITH seller_stats AS (
    SELECT
        f.main_seller_id AS seller_id,
        s.seller_state,
        COUNT(*) AS n_delivered,
        SUM(f.is_late) AS n_late,
        AVG(f.is_late) AS late_rate,
        AVG(f.days_late) AS avg_days_late,
        AVG(f.review_score) AS avg_review,
        SUM(f.order_value) AS gmv
    FROM marts.fct_orders f
    LEFT JOIN staging.sellers s ON f.main_seller_id = s.seller_id
    WHERE f.is_delivered = 1
    GROUP BY f.main_seller_id, s.seller_state
),

ranked AS (
    SELECT
        *,
        RANK() OVER (ORDER BY n_late DESC) AS late_rank,
        NTILE(20) OVER (ORDER BY n_late DESC, n_delivered DESC) AS late_ventile
    FROM seller_stats
)

SELECT
    seller_id,
    seller_state,
    n_delivered,
    n_late,
    ROUND(100 * late_rate, 2) AS late_pct,
    ROUND(avg_days_late, 2) AS avg_days_late,
    ROUND(avg_review, 3) AS avg_review,
    ROUND(gmv, 2) AS gmv,
    ROUND(100.0 * n_late / (SELECT SUM(n_late) FROM seller_stats), 3) AS pct_of_all_late_orders,
    late_rank,
    CASE WHEN late_ventile = 1 THEN 1 ELSE 0 END AS is_top_5pct
FROM ranked;
