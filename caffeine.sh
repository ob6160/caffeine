#!/bin/bash

# Read dot env
set -a
[ -f .env ] && . .env
set +a

# All known caffeine sources, contributions welcome! (Very UK oriented)
caffeine_sources='"nero","cafe","costa","pret","starbucks","amt","coffee","café","patisseri","patisserie","expresso","espresso","yellow warbler","215 hackney","gails","greggs","leon","the good egg","roasters","pure food"'

if [ -n "$OFFSET_MONTHS" ]; then
    offset_months=$OFFSET_MONTHS
else
    offset_months=0
fi

# MacOS and GNU date utils handle date formatting really differently :(
if [ "$(uname)" == "Darwin" ]; then
    first_of_month=$(date -v1d -v"$(date '+%m')"m -v"-${offset_months}m" '+%Y-%m-%dT00:00:00Z')
    last_of_month=$(date  -v1d -v"$(date '+%m')"m -v"-${offset_months}m" -v'+1m' '+%Y-%m-%dT00:00:00Z')
    month_name=$(date -j -f %Y-%m-%dT00:00:00Z $first_of_month +%B)
    year_name=$(date -j -f %Y-%m-%dT00:00:00Z $first_of_month +%Y)
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    first_of_month=$(date +%Y-%m-%dT00:00:00Z -d "`date +%Y%m01` - ${offset_months} month")
    last_of_month=$(date +%Y-%m-%dT00:00:00Z -d "`date +%Y%m01` - ${offset_months} month + 1 month")
    month_name=$(date -d $first_of_month +%B)
    year_name=$(date -d $first_of_month +%Y)
fi

if [ -n "$STARLING_TOKEN" ]; then
    ## Starling ##
    api_root="https://api.starlingbank.com"
    auth="Authorization: Bearer $STARLING_TOKEN"
    accounts=$(curl -s -H "$auth" "$api_root/api/v2/accounts")
    account_details=$(echo $accounts | jq ".accounts | .[0] | {uid: .accountUid, category: .defaultCategory}")
    account_uid=$(echo $account_details | jq -r '.uid')
    category_uid=$(echo $account_details | jq -r '.category')
    transactions=$(curl -s -H "$auth" "$api_root/api/v2/feed/account/$account_uid/category/{$category_uid}/transactions-between?minTransactionTimestamp=$first_of_month&maxTransactionTimestamp=$last_of_month")
    transaction_details=$(echo $transactions | jq ".[] | .[] | {desc: .counterPartyName, amount: .amount.minorUnits}")
elif [ -n "$MONZO_TOKEN" ]; then
    ## Monzo ##
    api_root="https://api.monzo.com"
    auth="Authorization: Bearer $MONZO_TOKEN"
    transactions=$(curl -s -H "$auth" "$api_root/transactions?account_id=$MONZO_ACCOUNT_ID&since=$first_of_month&before=$last_of_month")
    transaction_details=$(echo $transactions | jq ".[] | .[] | {desc: .description, amount: .amount}")
else
    echo "Neither STARLING_TOKEN or MONZO_TOKEN environment variables are set. Please refer to the readme for instructions about how to set these! Have a great day ☀️"
fi

# Calculate the total caffeine spend
amounts=$(echo $transaction_details | jq 'select(.desc | ascii_downcase | contains('"$caffeine_sources"')) | .amount')

if [ "$amounts" == "" ]; then
  echo "Congrats, looks like you didn't spend any money on coffee in $month_name $year_name, good work!"
  exit 0
fi

sum_transactions=$(echo $amounts | sed 's/ /+/g' | bc | sed 's/-//g')
scaled_sum=$(echo "scale = 2; $sum_transactions / 100" | bc)

if [ "$offset_months" == 0 ]; then
    feedback_string="Awake? You should be - you've spent £$scaled_sum on caffeine so far in $month_name ☕😅."
else
    feedback_string="Awake? You should be - you spent £$scaled_sum on caffeine in $month_name $year_name ☕😅." 
fi

echo $feedback_string
