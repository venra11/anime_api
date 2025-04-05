#!/bin/bash

anime_id=1

while true; do
    echo "Trying anime ID: $anime_id"
    
    response=$(curl -s "https://api.jikan.moe/v4/anime/$anime_id")
    
    if ! echo "$response" | grep -q "Not Found"; then
        mal_id=$(echo "$response" | jq -r '.data.mal_id')
        
        if [ ! -z "$mal_id" ] && [ "$mal_id" != "null" ]; then
            echo "Found valid anime with MAL ID: $mal_id"
            
            echo "$response" > /tmp/anime$anime_id.json
            
            psql $DATABASE_URL <<EOF
\set content \`cat /tmp/anime$anime_id.json\`
INSERT INTO anime_data (anime_id, jsonb) 
VALUES ($mal_id, :'content'::jsonb)
ON CONFLICT (anime_id) DO UPDATE 
SET jsonb = :'content'::jsonb, 
    scraped_at = CURRENT_TIMESTAMP;
EOF
            
            echo "Saved anime ID: $mal_id"
        else
            echo "Could not extract valid MAL ID"
        fi
    else
        echo "Skipping anime ID: $anime_id (not found)"
    fi
    
    anime_id=$((anime_id + 1))
    sleep 3
done

