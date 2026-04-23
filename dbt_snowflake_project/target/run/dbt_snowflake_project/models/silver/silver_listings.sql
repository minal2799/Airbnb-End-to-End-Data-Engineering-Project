
  
    

create or replace transient table AIRBNB.dbt_schema_silver.silver_listings
    
    
    
    as (

SELECT 
    LISTING_ID,
    HOST_ID,
    PROPERTY_TYPE,
    ROOM_TYPE,
    CITY,
    COUNTRY,
    ACCOMMODATES,
    BEDROOMS,
    BATHROOMS,
    PRICE_PER_NIGHT,
    
    CASE 
        WHEN CAST(PRICE_PER_NIGHT AS INT) < 100 THEN 'low'
        WHEN CAST(PRICE_PER_NIGHT AS INT) < 200 THEN 'medium'
        ELSE 'high'
    END
 AS PRICE_PER_NIGHT_TAG,
    CREATED_AT
FROM 
    AIRBNB.dbt_schema_bronze.bronze_listings
    )
;


  