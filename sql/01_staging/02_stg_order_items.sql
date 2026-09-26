CREATE OR REPLACE VIEW staging.order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date AS shipping_limit_ts,
    price,
    freight_value
FROM raw.order_items;
