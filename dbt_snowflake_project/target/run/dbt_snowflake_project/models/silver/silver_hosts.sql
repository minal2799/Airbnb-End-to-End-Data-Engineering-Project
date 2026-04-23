
  
    

create or replace transient table AIRBNB.dbt_schema_silver.silver_hosts
    
    
    
    as (

SELECT 
    HOST_ID,
    REPLACE(HOST_NAME, ' ', '_') AS HOST_NAME,
    HOST_SINCE AS HOST_SINCE,
    IS_SUPERHOST AS IS_SUPERHOST,
    RESPONSE_RATE AS RESPONSE_RATE,
    CASE 
    WHEN RESPONSE_RATE > 95 THEN 'VERY GOOD'
    WHEN RESPONSE_RATE > 80 THEN 'GOOD'
    WHEN RESPONSE_RATE > 60 THEN 'FAIR'
    ELSE 'POOR'
    END AS RESPONSE_RATE_QUALITY,
    CREATED_AT AS CREATED_AT
FROM 
    AIRBNB.dbt_schema_bronze.bronze_hosts
    )
;


  