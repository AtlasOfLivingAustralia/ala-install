echo "Running scheduled download"

export EMAIL=merit@awe.gov.au

export FQ=""
export TABS="tabs=Projects&tabs=Output+Targets&tabs=Sites&tabs=Reports&tabs=Report+Summary&tabs=Documents&tabs=Blog&tabs=Dataset&tabs=MERI_Outcomes&tabs=MERI_Monitoring&tabs=MERI_Project+Partnerships&tabs=MERI_Project+Implementation&tabs=MERI_Key+Evaluation+Question&tabs=MERI_Priorities&tabs=MERI_Budget&tabs=MERI_Risks+and+Threats&tabs=MERI_WHS+and+Case+Study&tabs=MERI_Attachments&tabs=MERI_Baseline&tabs=MERI_Event&tabs=MERI_Project+Assets&tabs=MERI_Approvals&tabs=RLP_Outcomes&tabs=RLP_Project_Details&tabs=RLP_Key_Threats&tabs=RLP_Services_and_Targets&tabs=Activity+Summary"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 25m

export FQ="fq=associatedProgramFacet%3AAgriculture+Stewardship&fq=associatedProgramFacet%3AFuture+Drought+Fund"
export TABS="tabs=RLP+Output+Report&tabs=RLP+Annual+Report&tabs=RLP+Short+term+project+outcomes"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 1m

export FQ="fq=associatedProgramFacet%3ABiodiversity+Fund"
export TABS="tabs=Indigenous+Employment+and+Businesses&tabs=Outcomes%2C+Evaluation+and+Learning+-+final+report&tabs=Project+Administration&tabs=Progress%2C+Outcomes+and+Learning+-+stage+report&tabs=Biodiversity+Fund+-+Outcomes+and+Monitoring&&tabs=Site+assessment&tabs=Fauna+Survey+-+general&tabs=Flora+Survey+-+general&tabs=Pest+Animal+Survey&tabs=Plant+Survival+Survey&tabs=Site+Monitoring+Plan&tabs=Water+Quality+Survey&tabs=Weed+Mapping+%26+Monitoring&tabs=Vegetation+Assessment+-+Commonwealth+government+methodology&tabs=Community+Participation+and+Engagement&tabs=Debris+Removal&tabs=Disease+Management&tabs=Erosion+Management&tabs=Fencing&tabs=Conservation+Grazing+Management&tabs=Ecological+Fire+Management&tabs=Fire+Management&tabs=Heritage+Conservation&tabs=Management+Plan+Development&tabs=Management+Practice+Change&tabs=Conservation+Actions+for+Species+and+Communities&tabs=Pest+Management&tabs=Plant+Propagation&tabs=Public+Access+and+Infrastructure&tabs=Research&tabs=Revegetation&tabs=Seed+Collection&tabs=Site+Preparation&tabs=Water+Management&tabs=Weed+Treatment&tabs=Works+Planning+and+Risk&tabs=Upload+of+stage+1+and+2+reporting+data&tabs=Indigenous+Knowledge+Transfer&tabs=Training+and+Skills+Development"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 5m

export FQ="fq=associatedProgramFacet%3ACaring+for+Our+Country+2"
export TABS="tabs=Indigenous+Employment+and+Businesses&tabs=Outcomes%2C+Evaluation+and+Learning+-+final+report&tabs=Project+Administration&tabs=Progress%2C+Outcomes+and+Learning+-+stage+report&tabs=Annual+Stage+Report&&tabs=Feral+animal+assessment&tabs=Site+assessment&tabs=Fauna+Survey+-+general&tabs=Flora+Survey+-+general&tabs=Pest+Animal+Survey&tabs=Plant+Survival+Survey&tabs=Site+Monitoring+Plan&tabs=Water+Quality+Survey&tabs=Weed+Mapping+%26+Monitoring&tabs=Vegetation+Assessment+-+Commonwealth+government+methodology&tabs=Community+Grants&tabs=Community+Participation+and+Engagement&tabs=Debris+Removal&tabs=Disease+Management&tabs=Erosion+Management&tabs=Fencing&tabs=Conservation+Grazing+Management&tabs=Fire+Management&tabs=Heritage+Conservation&tabs=Management+Plan+Development&tabs=Management+Practice+Change&tabs=Conservation+Actions+for+Species+and+Communities&tabs=Pest+Management&tabs=Plant+Propagation&tabs=Public+Access+and+Infrastructure&tabs=Research&tabs=Revegetation&tabs=Seed+Collection&tabs=Site+Preparation&tabs=Water+Management&tabs=Weed+Treatment&tabs=Works+Planning+and+Risk&tabs=Post+revegetation+site+management&tabs=Indigenous+Knowledge+Transfer&tabs=Training+and+Skills+Development"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 3m

export FQ="fq=associatedProgramFacet%3ABushfire+Recovery+for+Species+and+Landscapes+Program&fq=associatedProgramFacet%3ABushfire+Wildlife+and+Habitat+Recovery"
export TABS="tabs=Wildlife+Recovery+Progress+Report+-+CVA&tabs=Wildlife+Recovery+Progress+Report+-+GA&tabs=Wildlife+Recovery+Progress+Report+-+WRR&tabs=Wildlife+Recovery+Final+Report+-+WRR&tabs=GA+Final+Reporting&tabs=RLP+Output+Report&tabs=RLP+Annual+Report&tabs=RLP+Short+term+project+outcomes&tabs=State+Intervention+Progress+Report&tabs=Bushfires+States+Progress+Report&tabs=State+Intervention+Final+Report"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 5m

export FQ="fq=associatedProgramFacet%3AGreen+Army"
export TABS="tabs=Regional+Funding+Final+Report&tabs=Project+Administration&tabs=Annual+Stage+Report&tabs=Fauna+Survey+-+general&tabs=Flora+Survey+-+general&tabs=Pest+Animal+Survey&tabs=Plant+Survival+Survey&tabs=Site+Monitoring+Plan&tabs=Water+Quality+Survey&tabs=Weed+Mapping+%26+Monitoring&tabs=Vegetation+Assessment+-+Commonwealth+government+methodology&tabs=Community+Participation+and+Engagement&tabs=Debris+Removal&tabs=Disease+Management&tabs=Erosion+Management&tabs=Fencing&tabs=Fire+Management&tabs=Heritage+Conservation&tabs=Conservation+Actions+for+Species+and+Communities&tabs=Pest+Management&tabs=Plant+Propagation&tabs=Public+Access+and+Infrastructure&tabs=Research&tabs=Revegetation&tabs=Seed+Collection&tabs=Site+Preparation&tabs=Weed+Treatment&tabs=Works+Planning+and+Risk&tabs=25th+Anniversary+Landcare+Grants+-+Final+Report&tabs=Indigenous+Knowledge+Transfer&tabs=Training+and+Skills+Development"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 2m

export FQ="fq=associatedProgramFacet%3ACumberland+Plain&fq=associatedProgramFacet%3AImproving+Your+Local+Parks+and+Environment&fq=associatedProgramFacet%3AReef+2050+Plan&fq=associatedProgramFacet%3AReef+Trust"
export TABS="tabs=Indigenous+Employment+and+Businesses&tabs=Outcomes%2C+Evaluation+and+Learning+-+final+report&tabs=Project+Administration&tabs=Progress%2C+Outcomes+and+Learning+-+stage+report&tabs=Annual+Stage+Report&tabs=Reef+Trust+Final+Report&tabs=Fauna+Survey+-+general&tabs=Flora+Survey+-+general&tabs=Pest+Animal+Survey&tabs=Plant+Survival+Survey&tabs=Site+Monitoring+Plan&tabs=Water+Quality+Survey&tabs=Weed+Mapping+%26+Monitoring&tabs=Vegetation+Assessment+-+Commonwealth+government+methodology&tabs=Community+Participation+and+Engagement&tabs=Debris+Removal&tabs=Erosion+Management&tabs=Fencing&tabs=Conservation+Grazing+Management&tabs=Heritage+Conservation&tabs=Management+Plan+Development&tabs=Management+Practice+Change&tabs=Conservation+Actions+for+Species+and+Communities&tabs=Pest+Management&tabs=Plant+Propagation&tabs=Public+Access+and+Infrastructure&tabs=Research&tabs=Revegetation&tabs=Seed+Collection&tabs=Site+Preparation&tabs=Water+Management&tabs=Weed+Treatment&tabs=Works+Planning+and+Risk&tabs=Public+Access+and+Infrastructure+-+with+map&tabs=Sediment+Savings&tabs=RLP+Output+Report&tabs=RLP+Annual+Report&tabs=RLP+Short+term+project+outcomes&tabs=Reef+2050+Plan+Action+Reporting+2018&tabs=Reef+2050+Plan+Action+Reporting&tabs=Indigenous+Knowledge+Transfer&tabs=Training+and+Skills+Development"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 1m

export FQ="fq=associatedProgramFacet%3AComplementary+Investment+%28RLP%29&fq=associatedProgramFacet%3AEnvironmental+Restoration+Fund&fq=associatedProgramFacet%3AMER+Network+Pilot"
export TABS="tabs=RLP+Output+Report&tabs=RLP+Annual+Report&tabs=RLP+Short+term+project+outcomes&tabs=RLP+Medium+term+project+outcomes&tabs=RLP+Output+Report+Adjustment"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 1m

export FQ="fq=associatedProgramFacet%3ANational+Landcare+Programme&fq=associatedSubProgramFacet%3ARegional+Land+Partnerships&fq=associatedSubProgramFacet:WA+NLP+Projects"
export TABS="tabs=RLP+Output+Report&tabs=RLP+Annual+Report&tabs=RLP+Short+term+project+outcomes&tabs=RLP+Medium+term+project+outcomes&tabs=RLP+Output+Report+Adjustment"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 6m

export FQ="fq=associatedProgramFacet%3ANational+Landcare+Programme&fq=associatedSubProgramFacet%3A20+Million+Trees+Cumberland+Conservation+Corridor+Grants&fq=associatedSubProgramFacet%3A20+Million+Trees+Cumberland+Conservation+Corridor+Land+Management&fq=associatedSubProgramFacet%3A20+Million+Trees+Discretionary+Grants&fq=associatedSubProgramFacet%3A20+Million+Trees+Grants+Round+1&fq=associatedSubProgramFacet%3A20+Million+Trees+Grants+Round+2&fq=associatedSubProgramFacet%3A20+Million+Trees+Grants+Round+3&fq=associatedSubProgramFacet%3A20+Million+Trees+Service+Providers&fq=associatedSubProgramFacet%3A20+Million+Trees+Service+Providers+Tranche+2&fq=associatedSubProgramFacet%3A20+Million+Trees+Service+Providers+Tranche+3&fq=associatedSubProgramFacet%3A20+Million+Trees+West+Melbourne"
export TABS="tabs=Indigenous+Employment+and+Businesses&tabs=Outcomes%2C+Evaluation+and+Learning+-+final+report&tabs=Project+Administration&tabs=Progress%2C+Outcomes+and+Learning+-+stage+report&tabs=Fauna+Survey+-+general&tabs=Flora+Survey+-+general&tabs=Pest+Animal+Survey&tabs=Plant+Survival+Survey&tabs=Site+Monitoring+Plan&tabs=Water+Quality+Survey&tabs=Weed+Mapping+%26+Monitoring&tabs=Vegetation+Assessment+-+Commonwealth+government+methodology&tabs=Community+Participation+and+Engagement&tabs=Debris+Removal&tabs=Erosion+Management&tabs=Fencing&tabs=Fire+Management&tabs=Heritage+Conservation&tabs=Management+Plan+Development&tabs=Management+Practice+Change&tabs=Conservation+Actions+for+Species+and+Communities&tabs=Pest+Management&tabs=Plant+Propagation&tabs=Public+Access+and+Infrastructure&tabs=Research&tabs=Revegetation&tabs=Seed+Collection&tabs=Site+Preparation&tabs=Weed+Treatment&tabs=Works+Planning+and+Risk&tabs=Post+revegetation+site+management&tabs=Indigenous+Knowledge+Transfer&tabs=Training+and+Skills+Development"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 2m

export FQ="fq=associatedProgramFacet%3ANational+Landcare+Programme&fq=associatedSubProgramFacet%3A25th+Anniversary+Landcare+Grants+2014-15&fq=associatedSubProgramFacet%3ALandcare+Network+Grants+2014-16&fq=associatedSubProgramFacet%3ALocal+Programmes&fq=associatedSubProgramFacet%3ARegional+Funding"
export TABS="tabs=Regional+Funding+Final+Report&tabs=Indigenous+Employment+and+Businesses&tabs=Outcomes%2C+Evaluation+and+Learning+-+final+report&tabs=Project+Administration&tabs=Progress%2C+Outcomes+and+Learning+-+stage+report&tabs=Stage+Report&tabs=Annual+Stage+Report&tabs=Fauna+Survey+-+general&tabs=Flora+Survey+-+general&tabs=Pest+Animal+Survey&tabs=Plant+Survival+Survey&tabs=Site+Monitoring+Plan&tabs=Water+Quality+Survey&tabs=Weed+Mapping+%26+Monitoring&tabs=Vegetation+Assessment+-+Commonwealth+government+methodology&tabs=Community+Grants&tabs=Community+Participation+and+Engagement&tabs=Debris+Removal&tabs=Disease+Management&tabs=Erosion+Management&tabs=Fencing&tabs=Conservation+Grazing+Management&tabs=Ecological+Fire+Management&tabs=Fire+Management&tabs=Heritage+Conservation&tabs=Management+Plan+Development&tabs=Management+Practice+Change&tabs=Conservation+Actions+for+Species+and+Communities&tabs=Pest+Management&tabs=Plant+Propagation&tabs=Public+Access+and+Infrastructure&tabs=Research&tabs=Revegetation&tabs=Seed+Collection&tabs=Site+Preparation&tabs=Water+Management&tabs=Weed+Treatment&tabs=Works+Planning+and+Risk&tabs=Post+revegetation+site+management&tabs=25th+Anniversary+Landcare+Grants+-+Progress+Report&tabs=25th+Anniversary+Landcare+Grants+-+Final+Report&tabs=Indigenous+Knowledge+Transfer&tabs=Training+and+Skills+Development"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 5m

export FQ="fq=associatedProgramFacet%3AEnvironmental+Stewardship"
export TABS="tabs=ESP+Annual+Report+Submission&tabs=ESP+PMU+or+Zone+reporting&tabs=ESP+SMU+Reporting&tabs=ESP+Species"
/{{data_dir}}/ecodata/scripts/runProjectDownload.sh $EMAIL "$FQ" $TABS
sleep 5m

export END_DATE="$(date +%Y-%m-%d)T00:00:00Z"

export SUMMARY_FLAG=false
/{{data_dir}}/ecodata/scripts/runMuDownload.sh "$EMAIL" "$SUMMARY_FLAG" "$END_DATE"
sleep 2m

export SUMMARY_FLAG=true
/{{data_dir}}/ecodata/scripts/runMuDownload.sh "$EMAIL" "$SUMMARY_FLAG" "$END_DATE"