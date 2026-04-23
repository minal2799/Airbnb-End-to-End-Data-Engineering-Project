
  
    

create or replace transient table AIRBNB.dbt_schema_silver.silver_bookings
    
    
    
    as (


SELECT 
    BOOKING_ID,
    LISTING_ID,
    BOOKING_DATE,
    
    round(NIGHTS_BOOKED * BOOKING_AMOUNT,2)
 AS TOTAL_AMOUNT,
    SERVICE_FEE, 
    CLEANING_FEE, 
    BOOKING_STATUS,
    CREATED_AT
FROM 
    AIRBNB.dbt_schema_bronze.bronze_bookings
    )
;


  