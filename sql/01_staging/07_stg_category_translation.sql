CREATE OR REPLACE VIEW staging.category_translation AS
SELECT
    product_category_name AS category_name,
    product_category_name_english AS category_name_english
FROM raw.category_translation;
