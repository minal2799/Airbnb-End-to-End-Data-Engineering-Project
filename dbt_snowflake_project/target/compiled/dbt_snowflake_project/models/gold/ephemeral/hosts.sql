

WITH hosts AS 
(
    SELECT 
        HOST_ID,
        HOST_NAME,
        HOST_SINCE,
        IS_SUPERHOST,
        RESPONSE_RATE_QUALITY,
        HOST_CREATED_AT
    FROM 
        AIRBNB.dbt_schema_gold.obt
)
SELECT * FROM hosts