
  
    

create or replace transient table AIRBNB.dbt_schema_bronze.bronze_listings
    
    
    
    as (


SELECT * FROM AIRBNB.staging.listings


    )
;


  