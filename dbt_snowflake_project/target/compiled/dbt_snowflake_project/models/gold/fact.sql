



SELECT 
        GOLD_obt.BOOKING_ID, GOLD_obt.LISTING_ID, GOLD_obt.HOST_ID,GOLD_obt.TOTAL_AMOUNT, GOLD_obt.SERVICE_FEE, GOLD_obt.CLEANING_FEE, GOLD_obt.ACCOMMODATES, GOLD_obt.BEDROOMS, GOLD_obt.BATHROOMS, GOLD_obt.PRICE_PER_NIGHT, GOLD_obt.RESPONSE_RATE

FROM
    
    
      AIRBNB.GOLD.OBT AS GOLD_obt
    
        
    
        LEFT JOIN AIRBNB.GOLD.DIM_LISTINGS AS DIM_listings
        ON GOLD_obt.listing_id = DIM_listings.listing_id
        
        
    
        LEFT JOIN AIRBNB.GOLD.DIM_HOSTS AS DIM_hosts
        ON GOLD_obt.host_id = DIM_hosts.host_id
        
        