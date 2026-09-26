CREATE OR REPLACE VIEW staging.products AS
SELECT
    p.product_id,
    p.product_category_name AS category_name,
    COALESCE(t.category_name_english, p.product_category_name, 'unknown') AS category_name_english,
    p.product_name_lenght AS product_name_length,
    p.product_description_lenght AS product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM raw.products p
LEFT JOIN staging.category_translation t
    ON p.product_category_name = t.category_name;
