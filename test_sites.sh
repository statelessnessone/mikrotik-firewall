#!/bin/bash
ALLOWED_SITES_FILE="allowed_sites.txt"
site_count=0

while IFS= read -r line; do
    echo "Processing line: '$line'"
    if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "$(echo "$line" | tr -d '[:space:]')" ]]; then
        site=$(echo "$line" | tr -d '[:space:]')
        echo "Adding site: $site"
        ((site_count++))
    fi
done < "$ALLOWED_SITES_FILE"

echo "Total sites: $site_count"
