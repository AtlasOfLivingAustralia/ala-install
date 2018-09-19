# TODO Need to parameterise this function
CREATE OR REPLACE FUNCTION export_images() RETURNS void AS $$
    BEGIN
        COPY  
        (
            select
            data_resource_uid AS dataResourceUid, 
            split_part(original_filename, '||', 2) AS occurrenceID,
            CONCAT( '{{images_base_url}}{{images_context_path}}/image/proxyImageThumbnailLarge?imageId=', image_identifier) AS identifier, 
            creator AS creator, 
            date_taken AS created,
            title AS title,
            mime_type AS format, 
            license AS license, 
            rights AS rights, 
            rights_holder AS rightsHolder,
            CONCAT('{{images_base_url}}{{images_context_path}}/image/details/', image_identifier) AS "references"
            from image
            order by data_resource_uid
        )
        TO '/data/images/exports/images.csv' DELIMITER ',' CSV HEADER;
    END;
$$ LANGUAGE plpgsql;
