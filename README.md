# caffeine
Find out how much you've spent on coffee so far this month.

Monzo and Starling are supported currently.

![Usage](demo.png)

## Monzo setup
You'll need a Monzo access token and your account id. Find them here: https://developers.monzo.com/api/playground

## Starling setup
You'll need a Starling access token, your account info is automatically fetched using it.
Generate one by signing up here: https://developer.starlingbank.com/personal/list

(I think) you'll need the following scopes: `account:read, account-identifier:read, payee-transaction:read, transaction:read`

## Deps
* jq - https://stedolan.github.io/jq/
* bc - (B)asic (C)alculator
* curl
* sed

## Usage

### Monzo
`$ MONZO_TOKEN=xxx MONZO_ACCOUNT_ID=xxx ./caffeine.sh`

### Starling
`$ STARLING_TOKEN=xxx ./caffeine.sh`

### Month offset
You are able to view past months by setting the `OFFSET_MONTHS` flag to the number of months you want to check in the past.

As an example, if you're in October and you want to check your spend in August, pass **2** to this flag.

`$ STARLING_TOKEN=xxx OFFSET_MONTHS=2 ./caffeine.sh`
