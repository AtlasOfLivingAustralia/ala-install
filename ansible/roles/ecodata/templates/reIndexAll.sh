export API_KEY={{ ecodata_api_key }}
export ECODATA_BASE_URL={{ecodata_url}}/ws

curl -X POST -H "Authorization: $API_KEY" "$ECODATA_BASE_URL/admin/reIndexAll"