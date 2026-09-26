CREATE OR REPLACE VIEW staging.order_reviews AS
WITH ranked AS (
    SELECT
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY review_creation_date DESC, review_answer_timestamp DESC
        ) AS rn
    FROM raw.order_reviews
)
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title AS comment_title,
    review_comment_message AS comment_message,
    review_creation_date AS review_created_ts,
    review_answer_timestamp AS review_answered_ts
FROM ranked
WHERE rn = 1;
