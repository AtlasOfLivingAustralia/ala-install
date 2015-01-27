CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;

-- sql to create layersdb on top of a postgis enabled database.
-- run this on a postgis enabled database.

--- DATA TYPES


CREATE TYPE searchobjectstype AS (
	pid character varying,
	id character varying,
	name character varying,
	"desc" character varying,
	fid character varying,
	fieldname character varying
);


--- FUNCTIONS

-- Function: searchobjects(text, integer)

-- DROP FUNCTION searchobjects(text, integer);

CREATE OR REPLACE FUNCTION searchobjects(q text, lim integer)
  RETURNS SETOF searchobjectstype AS
$BODY$
DECLARE
    q2 text;
    strresult text;
    found integer;
    r RECORD;
    s RECORD;
BEGIN
    strresult := '';
    found := 0;
    IF position('%' in q) > 0 THEN 
        q2 := substring(q from 2 for length(q)-2);
    ELSE
	q2 := q;
    END IF;
    FOR r IN SELECT id FROM obj_names WHERE position(q2 in name) > 0 order by position(q2 in name), name LIMIT lim LOOP
        FOR s IN SELECT o.pid as pid, o.id as id, o.name as name, o.desc as desc, o.fid as fid, f.name as fieldname FROM objects o, fields f WHERE o.fid = f.id and o.name_id=r.id LOOP
         RETURN NEXT s;
         found := found + 1;
         IF found >= lim THEN
             RETURN;
         END IF;
     END LOOP;
    END LOOP;

    RETURN;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER
  COST 10
  ROWS 1000;
ALTER FUNCTION searchobjects(text, integer) OWNER TO postgres;


--- SEQUENCES

-- Sequence: distributiondata_id_seq

-- DROP SEQUENCE distributiondata_id_seq;

CREATE SEQUENCE distributiondata_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE distributiondata_id_seq OWNER TO postgres;

-- Sequence: distributionshapes_id_seq

-- DROP SEQUENCE distributionshapes_id_seq;

CREATE SEQUENCE distributionshapes_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE distributionshapes_id_seq OWNER TO postgres;

-- Sequence: obj_names_id_seq

-- DROP SEQUENCE obj_names_id_seq;

CREATE SEQUENCE obj_names_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE obj_names_id_seq OWNER TO postgres;


-- Sequence: objects_id_seq

-- DROP SEQUENCE objects_id_seq;

CREATE SEQUENCE objects_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE objects_id_seq OWNER TO postgres;


--- TABLES

-- Table: distributiondata

-- DROP TABLE distributiondata;

CREATE TABLE distributiondata (
    gid integer DEFAULT nextval('distributiondata_id_seq'::regclass) NOT NULL,
    spcode numeric,
    scientific character varying(254),
    authority_ character varying(254),
    common_nam character varying(254),
    family character varying(254),
    genus_name character varying(254),
    specific_n character varying(254),
    min_depth numeric,
    max_depth numeric,
    pelagic_fl numeric,
    metadata_u character varying(254),
    the_geom geometry,
    wmsurl character varying,
    lsid character varying,
    geom_idx integer,
    type character(1),
    checklist_name character varying,
    notes text,
    estuarine_fl numeric,
    coastal_fl numeric,
    desmersal_fl numeric,
    group_name text,
    genus_exemplar boolean,
    family_exemplar boolean,
    caab_species_number text,
    caab_species_url text,
    caab_family_number text,
    caab_family_url text,
    metadata_uuid text,
    family_lsid text,
    genus_lsid text,
    bounding_box geometry,
    data_resource_uid character varying,
    original_scientific_name character varying,
    image_quality character(1),
    the_geom_orig geometry,
    endemic boolean DEFAULT false,
    CONSTRAINT distributiondata_the_geom_check CHECK ((st_ndims(the_geom) = 2)),
    CONSTRAINT distributiondata_the_geom_check1 CHECK (((geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT distributiondata_the_geom_check3 CHECK ((st_srid(the_geom) = 4326))
);
ALTER TABLE distributiondata OWNER TO postgres;

-- Index: distributiondata_idx

-- DROP INDEX distributiondata_idx;

CREATE INDEX distributiondata_idx
  ON distributiondata
  USING btree
  (geom_idx);

-- Index: distributiondata_the_geom_idx

-- DROP INDEX distributiondata_the_geom_idx;

CREATE INDEX distributiondata_the_geom_idx
  ON distributiondata
  USING gist
  (the_geom);

-- Index: distributiondata_type_idx

-- DROP INDEX distributiondata_type_idx;

CREATE INDEX distributiondata_type_idx
  ON distributiondata
  USING btree
  (type);


-- Table: distributionshapes

-- DROP TABLE distributionshapes;

CREATE TABLE distributionshapes
(
  id serial NOT NULL,
  the_geom geometry,
  "name" character varying(256),
  pid character varying,
  area_km double precision,
  CONSTRAINT copy_distributionshapes_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE distributionshapes OWNER TO postgres;


-- Table: fields

-- DROP TABLE fields;

CREATE TABLE fields
(
  "name" character varying(256),
  id character varying(8) NOT NULL,
  "desc" character varying(256),
  "type" character(1),
  spid character varying(256),
  sid character varying(256),
  sname character varying(256),
  sdesc character varying(256),
  indb boolean DEFAULT false,
  enabled boolean DEFAULT false,
  last_update timestamp without time zone,
  namesearch boolean DEFAULT false,
  defaultlayer boolean,
  "intersect" boolean DEFAULT false,
  layerbranch boolean DEFAULT false,
  analysis boolean DEFAULT true,
  addtomap boolean DEFAULT true,
  CONSTRAINT pk_id PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE fields OWNER TO postgres;

-- Index: idx_fields_id

-- DROP INDEX idx_fields_id;

CREATE INDEX idx_fields_id
  ON fields
  USING btree
  (id);

-- Table: layers

-- DROP TABLE layers;

CREATE TABLE layers
(
  id integer NOT NULL,
  "name" character varying(150),
  description text,
  "type" character varying(20),
  source character varying(150),
  path character varying(500),
  extents character varying(100),
  minlatitude numeric(18,5),
  minlongitude numeric(18,5),
  maxlatitude numeric(18,5),
  maxlongitude numeric(18,5),
  notes text,
  enabled boolean,
  displayname character varying(150),
  displaypath character varying(500),
  scale character varying(20),
  environmentalvaluemin character varying(30),
  environmentalvaluemax character varying(30),
  environmentalvalueunits character varying(150),
  lookuptablepath character varying(300),
  metadatapath character varying(300),
  classification1 character varying(150),
  classification2 character varying(150),
  uid character varying(50),
  mddatest character varying(30),
  citation_date character varying(30),
  datalang character varying(5),
  mdhrlv character varying(5),
  respparty_role character varying(30),
  licence_level character varying,
  licence_link character varying(300),
  licence_notes character varying(1024),
  source_link character varying(300),
  path_orig character varying,
  path_1km character varying(256),
  path_250m character varying(256),
  pid character varying,
  keywords character varying,
  "domain" character varying(100),
  CONSTRAINT pk_layers_id PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE layers OWNER TO postgres;


-- Table: obj_names

-- DROP TABLE obj_names;

CREATE TABLE obj_names
(
  id serial NOT NULL,
  "name" character varying,
  CONSTRAINT obj_names_id_pk PRIMARY KEY (id),
  CONSTRAINT obj_names_name_unique UNIQUE (name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE obj_names OWNER TO postgres;


-- Table: objects

-- DROP TABLE objects;

CREATE TABLE objects
(
  pid character varying(256) NOT NULL,
  id character varying(256) DEFAULT nextval('objects_id_seq'::regclass),
  "desc" character varying(256),
  "name" character varying,
  fid character varying(6),
  the_geom geometry,
  name_id integer,
  namesearch boolean DEFAULT false,
  bbox character varying(200),
  area_km double precision,
  CONSTRAINT objects_pid_pk PRIMARY KEY (pid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE objects OWNER TO postgres;

-- Index: idx_objects_name_id

-- DROP INDEX idx_objects_name_id;

CREATE INDEX idx_objects_name_id
  ON objects
  USING btree
  (name_id);

-- Index: objects_fid_idx

-- DROP INDEX objects_fid_idx;

CREATE INDEX objects_fid_idx
  ON objects
  USING btree
  (fid);

-- Index: objects_geom_idx

-- DROP INDEX objects_geom_idx;

CREATE INDEX objects_geom_idx
  ON objects
  USING gist
  (the_geom);

-- Index: objects_namesearch_idx

-- DROP INDEX objects_namesearch_idx;

CREATE INDEX objects_namesearch_idx
  ON objects
  USING btree
  (namesearch);


-- Table: tabulation

-- DROP TABLE tabulation;

CREATE TABLE tabulation
(
  fid1 character varying,
  pid1 character varying,
  fid2 character varying,
  pid2 character varying,
  the_geom geometry,
  area double precision,
  occurrences integer DEFAULT 0,
  species integer DEFAULT 0,
  CONSTRAINT tabulation_unqiue_constraint UNIQUE (fid1, pid1, fid2, pid2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tabulation OWNER TO postgres;

-- Index: tabulation_fid1_idx

-- DROP INDEX tabulation_fid1_idx;

CREATE INDEX tabulation_fid1_idx
  ON tabulation
  USING btree
  (fid1);

-- Index: tabulation_fid2_idx

-- DROP INDEX tabulation_fid2_idx;

CREATE INDEX tabulation_fid2_idx
  ON tabulation
  USING btree
  (fid2);

-- Index: tabulation_pid1_idx

-- DROP INDEX tabulation_pid1_idx;

CREATE INDEX tabulation_pid1_idx
  ON tabulation
  USING btree
  (pid1);

-- Index: tabulation_pid2_idx

-- DROP INDEX tabulation_pid2_idx;

CREATE INDEX tabulation_pid2_idx
  ON tabulation
  USING btree
  (pid2);



--- VIEWS

-- View: distributions

-- DROP VIEW distributions;

CREATE OR REPLACE VIEW distributions AS 
 SELECT d.gid, d.spcode, d.scientific, d.authority_, d.common_nam, d.family, d.genus_name, d.specific_n, d.min_depth, d.max_depth, d.pelagic_fl, d.estuarine_fl, d.coastal_fl, d.desmersal_fl, d.metadata_u, d.wmsurl, d.lsid, d.family_lsid, d.genus_lsid, d.caab_species_number, d.caab_family_number, o.the_geom, o.name AS area_name, o.pid, d.type, d.checklist_name, o.area_km, d.notes, d.geom_idx, d.group_name, d.genus_exemplar, d.family_exemplar
   FROM distributionshapes o
   JOIN distributiondata d ON d.geom_idx = o.id;

ALTER TABLE distributions OWNER TO postgres;


CREATE OR REPLACE FUNCTION updatefieldsnames()
  RETURNS trigger AS
$BODY$
    BEGIN
	UPDATE fields
	SET name = NEW.displayname
	WHERE spid = '' || NEW.id
		AND fields.name <> NEW.displayname;
	RETURN NULL;
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION updatefieldsnames()
  OWNER TO postgres;

CREATE TRIGGER trig_layers_displayname_update
  AFTER UPDATE
  ON layers
  FOR EACH ROW
  EXECUTE PROCEDURE updatefieldsnames();
  
  
  
CREATE TABLE points_of_interest
(
  id serial NOT NULL,
  object_id character varying(256),
  name character varying NOT NULL,
  type character varying NOT NULL,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  bearing double precision,
  user_id character varying,
  description character varying,
  focal_length_millimetres double precision,
  the_geom geometry,
  CONSTRAINT pk_points_of_interest PRIMARY KEY (id),
  CONSTRAINT fk_points_of_interest_object_pid FOREIGN KEY (object_id)
      REFERENCES objects (pid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE points_of_interest
  OWNER TO postgres;


CREATE TABLE uploaded_objects_metadata
(
  pid character varying(256) NOT NULL,
  user_id text,
  time_last_updated timestamp with time zone,
  id serial NOT NULL,
  CONSTRAINT pk_uploaded_objects_metadata PRIMARY KEY (id),
  CONSTRAINT fk_uploaded_objects_metadata FOREIGN KEY (pid)
      REFERENCES objects (pid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE uploaded_objects_metadata
  OWNER TO postgres;
