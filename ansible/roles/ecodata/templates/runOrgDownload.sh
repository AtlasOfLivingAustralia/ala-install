#!/bin/bash
export EMAIL=$1
export SUMMARY_FLAG=$2
export END_DATE=$3
export DOWNLOAD_URL={{merit_base_url}}/download/get/
export SENDER_EMAIL=merit@ala.org.au
export HUB_FQ=isMERIT%3Atrue
export API_KEY={{ ecodata_api_key }}
export ECODATA_BASE_URL={{ecodata_url}}/ws

curl -X GET -H "Authorization: $API_KEY" "$ECODATA_BASE_URL/report/generateReportsInPeriod/?startDate=2023-07-01T00:00:00Z&endDate=$END_DATE&summaryFlag=$SUMMARY_FLAG&email=$EMAIL&senderEmail=$SENDER_EMAIL&systemEmail=$SENDER_EMAIL&reportDownloadBaseUrl=$DOWNLOAD_URL&entity=organisation"