
  
    

create or replace transient table AIRBNB.dbt_schema_bronze.bronze_bookings
    
    
    
    as (


SELECT * FROM  AIRBNB.staging.bookings


    )
;


  