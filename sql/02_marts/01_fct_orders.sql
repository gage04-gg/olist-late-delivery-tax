CREATE SCHEMA IF NOT EXISTS marts;

DROP TABLE IF EXISTS marts.fct_orders;

CREATE TABLE marts.fct_orders AS
WITH items_per_order AS (
    SELECT
        i.order_id,
        COUNT(*) AS n_items,
        COUNT(DISTINCT i.seller_id) AS n_sellers,
        SUM(i.price) AS order_value,
        SUM(i.freight_value) AS freight_value,
        SUM(p.product_weight_g) AS total_weight_g
    FROM staging.order_items i
    LEFT JOIN staging.products p ON i.product_id = p.product_id
    GROUP BY i.order_id
),

ranked_items AS (
    SELECT
        i.order_id,
        i.seller_id,
        p.category_name_english,
        ROW_NUMBER() OVER (PARTITION BY i.order_id ORDER BY i.price DESC, i.order_item_id) AS rn
    FROM staging.order_items i
    LEFT JOIN staging.products p ON i.product_id = p.product_id
),

main_item AS (
    SELECT
        order_id,
        seller_id AS main_seller_id,
        category_name_english AS main_category
    FROM ranked_items
    WHERE rn = 1
),

payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value,
        MAX(payment_installments) AS max_installments
    FROM staging.order_payments
    GROUP BY order_id
),

base AS (
    SELECT
        o.order_id,
        o.order_status,
        o.customer_id,
        c.customer_unique_id,
        c.customer_state,
        c.customer_zip_prefix,
        o.purchase_ts,
        o.purchase_ts::date AS purchase_date,
        DATE_TRUNC('month', o.purchase_ts)::date AS purchase_month,
        o.estimated_delivery_date,
        o.delivered_customer_ts,
        o.delivered_customer_ts::date AS delivered_date,
        ipo.n_items,
        ipo.n_sellers,
        ipo.order_value,
        ipo.freight_value,
        ipo.total_weight_g,
        m.main_seller_id,
        m.main_category,
        pay.payment_value,
        pay.max_installments,
        r.review_score,
        r.review_created_ts::date AS review_created_date,
        r.review_answered_ts
    FROM staging.orders o
    LEFT JOIN staging.customers c ON o.customer_id = c.customer_id
    LEFT JOIN items_per_order ipo ON o.order_id = ipo.order_id
    LEFT JOIN main_item m ON o.order_id = m.order_id
    LEFT JOIN payments_per_order pay ON o.order_id = pay.order_id
    LEFT JOIN staging.order_reviews r ON o.order_id = r.order_id
)

SELECT
    b.order_id,
    b.order_status,
    b.customer_id,
    b.customer_unique_id,
    b.customer_state,
    CASE
        WHEN b.customer_state IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'North'
        WHEN b.customer_state IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Northeast'
        WHEN b.customer_state IN ('PR', 'RS', 'SC') THEN 'South'
        WHEN b.customer_state IN ('ES', 'MG', 'RJ', 'SP') THEN 'Southeast'
        WHEN b.customer_state IN ('DF', 'GO', 'MS', 'MT') THEN 'Centre-West'
    END AS customer_region,
    b.purchase_ts,
    b.purchase_date,
    b.purchase_month,
    b.n_items,
    b.n_sellers,
    CASE WHEN b.n_sellers = 1 THEN b.main_seller_id END AS seller_id,
    b.main_seller_id,
    b.main_category,
    b.order_value,
    b.freight_value,
    b.payment_value,
    b.max_installments,
    b.total_weight_g,
    b.estimated_delivery_date,
    b.delivered_customer_ts,
    b.delivered_date,
    b.estimated_delivery_date - b.purchase_date AS promised_days,
    b.delivered_date - b.purchase_date AS delivery_days,
    b.delivered_date - b.estimated_delivery_date AS days_late,
    CASE
        WHEN b.delivered_date IS NULL THEN NULL
        WHEN b.delivered_date - b.estimated_delivery_date > 0 THEN 1
        ELSE 0
    END AS is_late,
    CASE
        WHEN b.order_status = 'delivered' AND b.delivered_date IS NOT NULL THEN 1
        ELSE 0
    END AS is_delivered,
    b.review_score,
    CASE
        WHEN b.review_score IS NULL THEN NULL
        WHEN b.review_score <= 2 THEN 1
        ELSE 0
    END AS low_review,
    b.review_created_date,
    b.review_answered_ts,
    6371 * 2 * ASIN(SQRT(
        POWER(SIN(RADIANS(gc.lat - gs.lat) / 2), 2)
        + COS(RADIANS(gs.lat)) * COS(RADIANS(gc.lat)) * POWER(SIN(RADIANS(gc.lng - gs.lng) / 2), 2)
    )) AS distance_km
FROM base b
LEFT JOIN staging.sellers s ON b.main_seller_id = s.seller_id
LEFT JOIN staging.geolocation gs ON s.seller_zip_prefix = gs.zip_prefix
LEFT JOIN staging.geolocation gc ON b.customer_zip_prefix = gc.zip_prefix;

ALTER TABLE marts.fct_orders ADD PRIMARY KEY (order_id);
