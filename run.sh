#!/bin/bash
psql $DATABASE_URL -f clean.sql

for anime_id in {1..10}; do
    response=$(curl -s "https://api.jikan.moe/v4/anime/$anime_id")
    echo "$response" | psql $DATABASE_URL -c "INSERT INTO anime_data (jsonb) VALUES ('\$1'::jsonb);" -f -
    sleep 2
done
