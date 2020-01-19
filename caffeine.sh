#!/bin/bash

caffeine_sources='"nero","cafe","costa","pret","starbucks","amt","coffee","café"'

first_of_month=$(date +%Y-%m-%dT00:00:00Z -d "`date +%Y%m01`")

api_root="https://api.monzo.com"
auth="Authorization: Bearer $MONZO_TOKEN"

transactions=$(curl -s -H "$auth" "$api_root/transactions?account_id=$MONZO_ACCOUNT_ID&since=$first_of_month")

amounts=$(echo $transactions | jq '.[] | .[] | {desc: .description, amount: .amount} | select(.desc | ascii_downcase | contains('"$caffeine_sources"')) | .amount')

sum_transactions=$(echo $amounts | sed 's/ /+/g' | bc | sed 's/-//g')
scaled_sum=$(echo "scale = 2; $sum_transactions / 100" | bc)

echo "Awake? You should be - you've spent £$scaled_sum on caffeine since the start of the month ☕😅."

