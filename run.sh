psql $DATABASE_URL -f clean.sql
anime_id=1

while true; do
    # Get data and add to database if valid
    response=$(curl -s "https://api.jikan.moe/v4/anime/$anime_id")
    
    if ! echo "$response" | grep -q "Not Found"; then
        echo "Adding anime ID: $anime_id"
        echo "$response" | psql $DATABASE_URL -c "INSERT INTO anime_data (jsonb) VALUES ('\$1'::jsonb);" -f -
    fi
    
    # Move to next ID and wait
    anime_id=$((anime_id + 1))
    sleep 3
done

