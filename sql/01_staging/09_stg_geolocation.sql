CREATE OR REPLACE VIEW staging.geolocation AS
SELECT
    geolocation_zip_code_prefix AS zip_prefix,
    AVG(geolocation_lat) AS lat,
    AVG(geolocation_lng) AS lng,
    COUNT(*) AS n_raw_rows
FROM raw.geolocation
WHERE geolocation_lat BETWEEN -34 AND 6
  AND geolocation_lng BETWEEN -74 AND -34
GROUP BY geolocation_zip_code_prefix;
