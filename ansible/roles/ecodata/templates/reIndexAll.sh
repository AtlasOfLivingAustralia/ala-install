source accessToken.sh
export ECODATA_BASE_URL={{ecodata_url}}/ws

curl -X POST -H "Authorization: Bearer $access_token" "$ECODATA_BASE_URL/admin/reIndexAll"