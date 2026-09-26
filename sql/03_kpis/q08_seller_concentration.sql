WITH seller_gmv AS (
    SELECT
        i.seller_id,
        SUM(i.price) AS gmv
    FROM staging.order_items i
    JOIN staging.orders o ON i.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY i.seller_id
),

seller_deciles AS (
    SELECT
        seller_id,
        gmv,
        NTILE(10) OVER (ORDER BY gmv DESC) AS gmv_decile
    FROM seller_gmv
)

SELECT
    gmv_decile,
    COUNT(*) AS n_sellers,
    ROUND(SUM(gmv), 2) AS gmv,
    ROUND(100 * SUM(gmv) / (SELECT SUM(gmv) FROM seller_gmv), 2) AS pct_of_total_gmv
FROM seller_deciles
GROUP BY gmv_decile
ORDER BY gmv_decile;
