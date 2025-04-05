#!/bin/bash
anime_id=1
while true; do
    echo "Trying anime ID: $anime_id"
    
    response=$(curl -s "https://api.jikan.moe/v4/anime/$anime_id")
    
    if ! echo "$response" | grep -q "Not Found"; then
        echo "$response" > /tmp/anime$anime_id.json
        
        psql $DATABASE_URL <<EOF
\set content \`cat /tmp/anime$anime_id.json\`
INSERT INTO anime_data (jsonb) VALUES (:'content'::jsonb);
EOF
        
        echo "Saved anime ID: $anime_id"
    else
        echo "Skipping anime ID: $anime_id (not found)"
    fi
    
    anime_id=$((anime_id + 1))
    sleep 3
done

