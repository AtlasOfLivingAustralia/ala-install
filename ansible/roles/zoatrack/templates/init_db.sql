#create user oztrack with password 'changeme';
#create database oztrack with owner oztrack;;
#-d oztrack -f /usr/share/postgresql/9.1/contrib/postgis-2.2/postgis.sql
#-d oztrack -f /usr/share/postgresql/9.1/contrib/postgis-2.2/spatial_ref_sys.sql
-- alter table geometry_columns owner to oztrack
-- alter table spatial_ref_sys owner to oztrack
-- alter view geography_columns owner to oztrack
-- create extension "uuid-ossp"