#!/bin/bash
# Loads a contextual layer using from a shape file (.shp)
# NOTE: The following 9 variables need to be modified for each new layer
export SHAPEFILE="/data/ala/data/layers/raw/lakepoly/lakepoly.shp"
export LAYERID="3"
export LAYER_SHORT_NAME="lakepoly"
export LAYER_DISPLAY_NAME="UK Lakes"
export FIELDSSID="WBID"
export FIELDSSNAME="OSNAME"
export FIELDSSDESCRIPTION="OSNAME"
export NAME_SEARCH="true"
export INTERSECT="false"

export DBUSERNAME="postgres"
export DBPASSWORD="postgres"
export DBHOST="localhost"
export DBNAME="layersdb"
export DBJDBCURL="jdbc:postgresql://localhost:5432/layersdb"

export GEOSERVERBASEURL="http://130.56.250.41:8080/geoserver"
export GEOSERVERUSERNAME="admin"
export GEOSERVERPASSWORD="geoserver"

export REPROJECTEDSHAPEFILE="/data/ala/data/layers/ready/shape/${LAYER_SHORT_NAME}.shp"

export JAVA_CLASSPATH="target/layer-ingestion-1.0-SNAPSHOT.jar:target/dependencies/*"

echo "Reprojecting shapefile to WGS 84" \
&& ogr2ogr  -s_srs EPSG:4326 -t_srs EPSG:4326  "${REPROJECTEDSHAPEFILE}" "${SHAPEFILE}" \
&& echo "Creating layer and fields table entries for layer, converting shapefile to database table" \
&& java -Xmx10G -cp "${JAVA_CLASSPATH}" au.org.ala.layers.ingestion.contextual.ContextualFromShapefileDatabaseLoader "${LAYERID}" "${LAYER_SHORT_NAME}" "${LAYER_DISPLAY_NAME}" "${FIELDSSID}" "${FIELDSSNAME}" "${FIELDSSDESCRIPTION}" "${NAME_SEARCH}" "${INTERSECT}" "${REPROJECTEDSHAPEFILE}" "${DBUSERNAME}" "${DBPASSWORD}" "${DBJDBCURL}" "${DBHOST}" "${DBNAME}" \
&& echo "Create objects from layer" \
&& java -Xmx10G -cp "${JAVA_CLASSPATH}" au.org.ala.layers.ingestion.contextual.ContextualObjectCreator "${LAYERID}" "${DBUSERNAME}" "${DBPASSWORD}" "${DBJDBCURL}" \
&& echo "Load layer into geoserver" \
&& java -Xmx10G -cp "${JAVA_CLASSPATH}" au.org.ala.layers.ingestion.PostgisTableGeoserverLoader "${GEOSERVERBASEURL}" "${GEOSERVERUSERNAME}" "${GEOSERVERPASSWORD}" "${LAYERID}" "${LAYER_SHORT_NAME}" "${LAYER_DISPLAY_NAME}"                                                                                                                                                                                                                                        