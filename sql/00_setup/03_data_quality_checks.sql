SELECT 'orders' AS table_name, COUNT(*) AS n_rows FROM raw.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM raw.order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM raw.order_reviews
UNION ALL SELECT 'customers', COUNT(*) FROM raw.customers
UNION ALL SELECT 'sellers', COUNT(*) FROM raw.sellers
UNION ALL SELECT 'products', COUNT(*) FROM raw.products
UNION ALL SELECT 'geolocation', COUNT(*) FROM raw.geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM raw.category_translation;

SELECT 'orders.order_id' AS key_name, COUNT(*) AS n_rows, COUNT(DISTINCT order_id) AS n_distinct FROM raw.orders
UNION ALL SELECT 'customers.customer_id', COUNT(*), COUNT(DISTINCT customer_id) FROM raw.customers
UNION ALL SELECT 'customers.customer_unique_id', COUNT(*), COUNT(DISTINCT customer_unique_id) FROM raw.customers
UNION ALL SELECT 'sellers.seller_id', COUNT(*), COUNT(DISTINCT seller_id) FROM raw.sellers
UNION ALL SELECT 'products.product_id', COUNT(*), COUNT(DISTINCT product_id) FROM raw.products
UNION ALL SELECT 'reviews.review_id', COUNT(*), COUNT(DISTINCT review_id) FROM raw.order_reviews
UNION ALL SELECT 'reviews.order_id', COUNT(*), COUNT(DISTINCT order_id) FROM raw.order_reviews
UNION ALL SELECT 'translation.category', COUNT(*), COUNT(DISTINCT product_category_name) FROM raw.category_translation
UNION ALL SELECT 'geolocation.zip_prefix', COUNT(*), COUNT(DISTINCT geolocation_zip_code_prefix) FROM raw.geolocation;

SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id || '-' || order_item_id) AS n_distinct_order_item
FROM raw.order_items;

SELECT COUNT(*) AS n_rows, COUNT(DISTINCT order_id || '-' || payment_sequential) AS n_distinct_order_payment
FROM raw.order_payments;

SELECT order_status, COUNT(*) AS n_orders
FROM raw.orders
GROUP BY order_status
ORDER BY n_orders DESC;

SELECT
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS null_carrier,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated
FROM raw.orders;

SELECT
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS delivered_but_no_date,
    SUM(CASE WHEN order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL THEN 1 ELSE 0 END) AS usable_for_causal
FROM raw.orders
WHERE order_status = 'delivered';

SELECT order_status, COUNT(*) AS has_delivery_date_but_not_delivered
FROM raw.orders
WHERE order_status <> 'delivered' AND order_delivered_customer_date IS NOT NULL
GROUP BY order_status;

SELECT
    SUM(CASE WHEN order_delivered_customer_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS delivered_before_purchase,
    SUM(CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END) AS approved_before_purchase,
    SUM(CASE WHEN order_delivered_carrier_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS carrier_before_purchase,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS customer_before_carrier,
    SUM(CASE WHEN order_estimated_delivery_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS estimate_before_purchase
FROM raw.orders;

SELECT
    SUM(CASE WHEN order_estimated_delivery_date::time <> '00:00:00' THEN 1 ELSE 0 END) AS estimate_with_time_not_midnight
FROM raw.orders;

SELECT
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS price_zero_or_less,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS freight_negative,
    SUM(CASE WHEN freight_value = 0 THEN 1 ELSE 0 END) AS freight_zero,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    MAX(freight_value) AS max_freight
FROM raw.order_items;

SELECT
    SUM(CASE WHEN payment_value <= 0 THEN 1 ELSE 0 END) AS payment_zero_or_less,
    SUM(CASE WHEN payment_installments = 0 THEN 1 ELSE 0 END) AS installments_zero
FROM raw.order_payments;

SELECT o.order_status, COUNT(*) AS orders_without_items
FROM raw.orders o
LEFT JOIN raw.order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
GROUP BY o.order_status
ORDER BY orders_without_items DESC;

SELECT COUNT(*) AS orders_without_payment
FROM raw.orders o
LEFT JOIN raw.order_payments p ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

SELECT COUNT(*) AS orders_without_review
FROM raw.orders o
LEFT JOIN raw.order_reviews r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

SELECT n_reviews, COUNT(*) AS n_orders
FROM (
    SELECT order_id, COUNT(*) AS n_reviews
    FROM raw.order_reviews
    GROUP BY order_id
) t
GROUP BY n_reviews
ORDER BY n_reviews;

SELECT COUNT(*) AS review_ids_used_more_than_once
FROM (
    SELECT review_id
    FROM raw.order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) t;

SELECT COUNT(*) AS orders_with_reviews_same_creation_date
FROM (
    SELECT order_id
    FROM raw.order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1 AND COUNT(DISTINCT review_creation_date) < COUNT(*)
) t;

SELECT review_score, COUNT(*) AS n_reviews
FROM raw.order_reviews
GROUP BY review_score
ORDER BY review_score;

SELECT
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weight,
    SUM(CASE WHEN product_weight_g = 0 THEN 1 ELSE 0 END) AS zero_weight
FROM raw.products;

SELECT DISTINCT p.product_category_name AS category_missing_translation
FROM raw.products p
LEFT JOIN raw.category_translation t ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL;

SELECT COUNT(DISTINCT c.customer_zip_code_prefix) AS customer_zips_missing_geo
FROM raw.customers c
LEFT JOIN (SELECT DISTINCT geolocation_zip_code_prefix FROM raw.geolocation) g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT COUNT(*) AS customers_missing_geo
FROM raw.customers c
LEFT JOIN (SELECT DISTINCT geolocation_zip_code_prefix FROM raw.geolocation) g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT COUNT(*) AS sellers_missing_geo
FROM raw.sellers s
LEFT JOIN (SELECT DISTINCT geolocation_zip_code_prefix FROM raw.geolocation) g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

SELECT COUNT(*) AS geo_rows_outside_brazil
FROM raw.geolocation
WHERE geolocation_lat NOT BETWEEN -34 AND 6 OR geolocation_lng NOT BETWEEN -74 AND -34;

SELECT n_sellers, COUNT(*) AS n_orders
FROM (
    SELECT order_id, COUNT(DISTINCT seller_id) AS n_sellers
    FROM raw.order_items
    GROUP BY order_id
) t
GROUP BY n_sellers
ORDER BY n_sellers;

SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS purchase_month, COUNT(*) AS n_orders
FROM raw.orders
GROUP BY purchase_month
ORDER BY purchase_month;

SELECT MIN(order_purchase_timestamp) AS first_purchase, MAX(order_purchase_timestamp) AS last_purchase
FROM raw.orders;
