#!/bin/bash

api_root="https://api.starlingbank.com"
auth="Authorization: Bearer $STARLING_TOKEN"

accounts=$(curl -s -H "$auth" "$api_root/api/v2/accounts")

account_uid_query=".accounts | .[0] | {uid: .accountUid, category: .defaultCategory}"
account_details=$(echo $accounts | jq "$account_uid_query")

account_uid=$(echo $account_details | jq -r '.uid')
category_uid=$(echo $account_details | jq -r '.category')

echo $account_uid $category_uid

transactions_query=""
transactions=$(curl -s -H "$auth" "$api_root/api/v2/feed/account/$account_uid/category/{$category_uid}?changesSince=2020-01-01T12:34:56.000Z")

echo $transactions

#caffeine_sources='"nero","cafe","costa","pret","starbucks","amt","coffee","café"'
#
#first_of_month=$(date +%Y-%m-%dT00:00:00Z -d "`date +%Y%m01`")
#
#api_root="https://api.monzo.com"
#auth="Authorization: Bearer $MONZO_TOKEN"
#
#transactions=$(curl -s -H "$auth" "$api_root/transactions?account_id=$MONZO_ACCOUNT_ID&since=$first_of_month")
#
#amounts=$(echo $transactions | jq '.[] | .[] | {desc: .description, amount: .amount} | select(.desc | ascii_downcase | contains('"$caffeine_sources"')) | .amount')
#
#sum_transactions=$(echo $amounts | sed 's/ /+/g' | bc | sed 's/-//g')
#scaled_sum=$(echo "scale = 2; $sum_transactions / 100" | bc)
#
#echo "Awake? You should be - you've spent £$scaled_sum on caffeine since the start of the month ☕😅."

