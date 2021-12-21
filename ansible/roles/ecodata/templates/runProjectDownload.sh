#!/bin/bash
export EMAIL=$1
export FQ=$2
export TABS=$3
export FORM_SECTION_PER_TAB=true
export DOWNLOAD_URL={{merit_base_url}}/download/get/
export SENDER_EMAIL=merit@ala.org.au
export HUB_FQ=isMERIT%3Atrue
export API_KEY={{ ecodata_api_key }}
export ECODATA_BASE_URL={{ecodata_url}}/ws

curl -X POST -H "Authorization: $API_KEY" "$ECODATA_BASE_URL/search/downloadAllData.xlsx?formSectionPerTab=$FORM_SECTION_PER_TAB&view=xlsx&query=*&$FQ&$TABS&hubId=$MERIT_HUB&downloadUrl=$DOWNLOAD_URL&systemEmail=$SENDER_EMAIL&senderEmail=$SENDER_EMAIL&hubFq=$HUB_FQ&email=$EMAIL&max=10000&offset=0"
