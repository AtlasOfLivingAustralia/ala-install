#!/bin/bash

#get data for testing
wget -O /tmp/ala.tar.gz https://github.com/AtlasOfLivingAustralia/spatial-database/blob/master/ala.tar.gz?raw=true
wget -O /tmp/testdata.sql.gz https://github.com/AtlasOfLivingAustralia/spatial-database/blob/master/testdata.sql.gz?raw=true

#export
tar -zxvf /tmp/ala.tar.gz -C /data
gzip -d /tmp/testdata.sql.gz
sudo -u postgres psql layersdb -f /tmp/testdata.sql

#create layers in geoserver
curl -v -u admin:geoserver -XPUT -H "Content-type: text/plain" -d "file:///data/ala/data/layers/ready/shape/aus1.shp" http://localhost:8080/geoserver/rest/workspaces/ALA/datastores/aus1/external.shp
curl -v -u admin:geoserver -XPUT -H "Content-type: text/plain" -d "file:///data/ala/data/layers/ready/shape/lga_aust.shp" http://localhost:8080/geoserver/rest/workspaces/ALA/datastores/lga_aust/external.shp
curl -v -u admin:geoserver -XPUT -H "Content-type: text/plain" -d "file:///data/ala/data/layers/ready/geotiff/relief_ave.tif" http://localhost:8080/geoserver/rest/workspaces/ALA/coveragestores/relief_ave/external.geotiff
curl -v -u admin:geoserver -XPUT -H "Content-type: text/plain" -d "file:///data/ala/data/layers/ready/geotiff/slope_2.tif" http://localhost:8080/geoserver/rest/workspaces/ALA/coveragestores/slope_2/external.geotiff

curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<style><name>slope_2_style</name><filename>slope_2.sld</filename></style>" http://localhost:8080/geoserver/rest/styles
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<style><name>relief_ave_style</name><filename>relief_ave.sld</filename></style>" http://localhost:8080/geoserver/rest/styles

curl -v -u admin:geoserver -XPUT -H "Content-type: application/vnd.ogc.sld+xml" -d @/data/ala/data/layers/ready/geotiff/slope_2.sld http://localhost:8080/geoserver/rest/styles/slope_2_style
curl -v -u admin:geoserver -XPUT -H "Content-type: application/vnd.ogc.sld+xml" -d @/data/ala/data/layers/ready/geotiff/relief_ave.sld http://localhost:8080/geoserver/rest/styles/relief_ave_style

curl -u admin:geoserver -XPUT -H 'Content-type: text/xml' -d '<layer><defaultStyle><name>slope_2_style</name><workspace>ALA</workspace></defaultStyle></layer>' http://localhost:8080/geoserver/rest/layers/ALA:slope_2
curl -u admin:geoserver -XPUT -H 'Content-type: text/xml' -d '<layer><defaultStyle><name>relief_ave_style</name><workspace>ALA</workspace></defaultStyle></layer>' http://localhost:8080/geoserver/rest/layers/ALA:relief_ave

#additional actions
echo ""
echo "May need to edit /etc/hosts and re-run"
echo "May need to login to geoserver, edit layer, 'Edit sql view' and resave if a layer preview fail"
echo ""
