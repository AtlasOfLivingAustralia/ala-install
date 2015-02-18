#!/bin/bash

mkdir {{tomcat_webapps}}geoserver/data/layout
wget -O {{tomcat_webapps}}geoserver/data/layout/scale.xml https://github.com/AtlasOfLivingAustralia/spatial-database/raw/master/scale.xml 

#create workspace
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XDELETE {{geoserver_url}}/rest/workspaces/nurc?recurse=true
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XDELETE {{geoserver_url}}/rest/workspaces/cite?recurse=true
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XDELETE {{geoserver_url}}/rest/workspaces/it.geosolutions.html?recurse=true
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XDELETE {{geoserver_url}}/rest/workspaces/sde?recurse=true
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XDELETE {{geoserver_url}}/rest/workspaces/sf?recurse=true
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XDELETE {{geoserver_url}}/rest/workspaces/tiger?recurse=true
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XDELETE {{geoserver_url}}/rest/workspaces/topp?recurse=true
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPOST -H "Content-type: text/xml" -d "<workspace><name>ALA</name></workspace>" {{geoserver_url}}/rest/workspaces

#create LayersDB store
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPOST -H "Content-type: text/xml" -d "<dataStore><name>LayersDB</name><connectionParameters><host>{{postgis_host | default('localhost')}}</host><port>{{postgis_port | default('5432')}}</port><database>{{layers_db_name | default('layersdb')}}</database><schema>public</schema><user>{{postgis_username | default('postgres')}}</user><passwd>{{postgis_password | default('postgres')}}</passwd><dbtype>postgis</dbtype></connectionParameters></dataStore>" {{geoserver_url}}/rest/workspaces/ALA/datastores

#create styles
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPOST -H "Content-type: text/xml" -d "<style><name>distributions_style</name><filename>distributions_style.sld</filename></style>" {{geoserver_url}}/rest/styles
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPOST -H "Content-type: text/xml" -d "<style><name>envelope_style</name><filename>envelope_style.sld</filename></style>" {{geoserver_url}}/rest/styles
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPOST -H "Content-type: text/xml" -d "<style><name>alastyles</name><filename>alastyles.sld</filename></style>" {{geoserver_url}}/rest/styles

#upload styles
wget -O /tmp/distributions_style.sld https://github.com/AtlasOfLivingAustralia/spatial-database/raw/master/distributions_style.sld 
wget -O /tmp/envelope_style.sld https://github.com/AtlasOfLivingAustralia/spatial-database/raw/master/envelope_style.sld 
wget -O /tmp/alastyles.sld https://github.com/AtlasOfLivingAustralia/spatial-database/raw/master/alastyles.sld 
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPUT -H "Content-type: application/vnd.ogc.sld+xml" -d @/tmp/distributions_style.sld {{geoserver_url}}/rest/styles/distributions_style
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPUT -H "Content-type: application/vnd.ogc.sld+xml" -d @/tmp/envelope_style.sld {{geoserver_url}}/rest/styles/envelope_style
curl -v -u {{geoserver_username}}:{{geoserver_password}} -XPUT -H "Content-type: application/vnd.ogc.sld+xml" -d @/tmp/alastyles.sld {{geoserver_url}}/rest/styles/alastyles
  
#create layer
curl -u {{geoserver_username}}:{{geoserver_password}} -XPOST -H 'Content-type: text/xml' -T geoserver.objects.xml  {{geoserver_url}}/rest/workspaces/ALA/datastores/LayersDB/featuretypes
curl -u {{geoserver_username}}:{{geoserver_password}} -XPOST -H 'Content-type: text/xml' -T geoserver.distributions.xml  {{geoserver_url}}/rest/workspaces/ALA/datastores/LayersDB/featuretypes

#assign styles to layers
curl -u {{geoserver_username}}:{{geoserver_password}} -XPUT -H 'Content-type: text/xml' -d '<layer><defaultStyle><name>distributions_style</name><workspace>ALA</workspace></defaultStyle></layer>' {{geoserver_url}}/rest/layers/ALA:Objects
curl -u {{geoserver_username}}:{{geoserver_password}} -XPUT -H 'Content-type: text/xml' -d '<layer><defaultStyle><name>distributions_style</name><workspace>ALA</workspace></defaultStyle></layer>' {{geoserver_url}}/rest/layers/ALA:Distributions

#additional actions
echo ""
echo "May need to edit /etc/hosts and re-run"
echo "May need to login to geoserver, edit layer, 'Edit sql view' and resave for layers Objects and Distributions if layer previews fail"
echo ""
