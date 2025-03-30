psql $DATABASE_URL -f clean.sql
anime_id=1

while true; do
    echo "Trying anime ID: $anime_id"
    
    # Get anime data
    response=$(curl -s "https://api.jikan.moe/v4/anime/$anime_id")
    
    # Check if valid data returned (not a 404)
    if ! echo "$response" | grep -q "Not Found"; then
        # Create a temporary JSON file
        echo "$response" > /tmp/anime$anime_id.json
        
        # Use psql's meta-command to safely read the file
        psql $DATABASE_URL <<EOF
\set content \`cat /tmp/anime$anime_id.json\`
INSERT INTO anime_data (jsonb) VALUES (:'content'::jsonb);
EOF
        
        echo "Saved anime ID: $anime_id"
    else
        echo "Skipping anime ID: $anime_id (not found)"
    fi
    
    # Next anime
    anime_id=$((anime_id + 1))
    sleep 3
done
