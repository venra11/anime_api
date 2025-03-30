
psql $DATABASE_URL -f clean.sql
anime_id=1

while true; do
    # Get anime data
    response=$(curl -s "https://api.jikan.moe/v4/anime/$anime_id")
    
    # Check if valid data returned
    if ! echo "$response" | grep -q "Not Found"; then
        echo "Found anime ID: $anime_id"
        
        # Create temporary file
        echo "$response" > /tmp/anime.json
        
        # Insert JSON data safely
        psql $DATABASE_URL <<EOF
INSERT INTO anime_data (jsonb) 
SELECT '$response'::jsonb;
EOF
        
        echo "Saved anime ID: $anime_id"
    fi
    
    # Next anime
    anime_id=$((anime_id + 1))
    sleep 3
done

