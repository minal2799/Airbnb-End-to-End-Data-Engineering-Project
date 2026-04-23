



SELECT 
    
        SILVER_bookings.*,
    
        SILVER_listings.HOST_ID, SILVER_listings.PROPERTY_TYPE, SILVER_listings.ROOM_TYPE, SILVER_listings.CITY, SILVER_listings.COUNTRY, SILVER_listings.ACCOMMODATES, SILVER_listings.BEDROOMS, SILVER_listings.BATHROOMS, SILVER_listings.PRICE_PER_NIGHT, silver_listings.PRICE_PER_NIGHT_TAG, SILVER_listings.CREATED_AT AS LISTING_CREATED_AT,
    
        SILVER_hosts.HOST_NAME, SILVER_hosts.HOST_SINCE, SILVER_hosts.IS_SUPERHOST, SILVER_hosts.RESPONSE_RATE, SILVER_hosts.RESPONSE_RATE_QUALITY, SILVER_hosts.CREATED_AT AS HOST_CREATED_AT
    
FROM
    
    
      AIRBNB.SILVER.SILVER_BOOKINGS AS SILVER_bookings
    
        
    
        LEFT JOIN AIRBNB.SILVER.SILVER_LISTINGS AS SILVER_listings
        ON SILVER_bookings.listing_id = SILVER_listings.listing_id
        
        
    
        LEFT JOIN AIRBNB.SILVER.SILVER_HOSTS AS SILVER_hosts
        ON SILVER_listings.host_id = SILVER_hosts.host_id
        
        