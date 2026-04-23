
  
    

create or replace transient table AIRBNB.dbt_schema_bronze.bronze_hosts
    
    
    
    as (


SELECT * FROM  AIRBNB.staging.hosts


    )
;


  