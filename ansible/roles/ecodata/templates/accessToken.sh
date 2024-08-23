#!/bin/bash

CLIENT_ID="{{ ecodata_read_staging_client_id | default ('') }}"
CLIENT_SECRET="{{ ecodata_read_staging_client_secret | default ('') }}"
TOKEN_URL="{{ token_endpoint | default ('') }}"
SCOPE="ecodata/read_staging ecodata/write_staging" # ecodata staging read and write scope

# Function to get the access token
get_access_token() {
  response=$(curl -s --request POST "$TOKEN_URL" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "client_id=$CLIENT_ID" \
    --data-urlencode "client_secret=$CLIENT_SECRET" \
    --data-urlencode "scope=$SCOPE")

  if echo "$response" | jq -e .access_token >/dev/null 2>&1; then
    access_token=$(echo "$response" | jq -r .access_token)
    echo "Access Token: $access_token"
  else
    echo "Failed to obtain access token"
    echo "Response: $response"
    exit 1
  fi
}

# Get the access token
get_access_token