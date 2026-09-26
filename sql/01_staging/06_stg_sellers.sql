CREATE OR REPLACE VIEW staging.sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix AS seller_zip_prefix,
    seller_city,
    seller_state
FROM raw.sellers;
