CREATE OR REPLACE VIEW staging.orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp AS purchase_ts,
    order_approved_at AS approved_ts,
    order_delivered_carrier_date AS delivered_carrier_ts,
    order_delivered_customer_date AS delivered_customer_ts,
    order_estimated_delivery_date::date AS estimated_delivery_date
FROM raw.orders;
