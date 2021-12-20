export FQ=""
export TABS="tabs=Projects&tabs=Output+Targets&tabs=Sites&tabs=Reports&tabs=Report+Summary&tabs=Documents&tabs=Blog&tabs=Dataset&tabs=MERI_Outcomes&tabs=MERI_Monitoring&tabs=MERI_Project+Partnerships&tabs=MERI_Project+Implementation&tabs=MERI_Key+Evaluation+Question&tabs=MERI_Priorities&tabs=MERI_Budget&tabs=MERI_Risks+and+Threats&tabs=MERI_WHS+and+Case+Study&tabs=MERI_Attachments&tabs=MERI_Baseline&tabs=MERI_Event&tabs=MERI_Approvals&tabs=RLP_Outcomes&tabs=RLP_Project_Details&tabs=RLP_Key_Threats&tabs=RLP_Services_and_Targets&tabs=Activity+Summary"
export EMAIL=chris.godwin@csiro.au
./scheduledDownloads.sh $EMAIL "$FQ" $TABS

sleep 30m

