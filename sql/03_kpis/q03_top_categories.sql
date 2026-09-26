WITH category_gmv AS (
    SELECT
        p.category_name_english AS category,
        SUM(i.price) AS gmv
    FROM staging.order_items i
    JOIN staging.orders o ON i.order_id = o.order_id
    JOIN staging.products p ON i.product_id = p.product_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY p.category_name_english
),

with_share AS (
    SELECT
        category,
        gmv,
        gmv / SUM(gmv) OVER () AS share_of_total,
        RANK() OVER (ORDER BY gmv DESC) AS gmv_rank
    FROM category_gmv
)

SELECT
    gmv_rank,
    category,
    ROUND(gmv, 2) AS gmv,
    ROUND(100 * share_of_total, 2) AS pct_of_total_gmv
FROM with_share
WHERE gmv_rank <= 10
ORDER BY gmv_rank;
