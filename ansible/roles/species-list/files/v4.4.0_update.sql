#Create a matched_species table
    CREATE TABLE `matched_species` (
           `id` int NOT NULL AUTO_INCREMENT,
           `taxon_concept_id` varchar(255) DEFAULT NULL,
           `scientific_name` varchar(255) NOT NULL,
           `scientific_name_authorship` varchar(255) DEFAULT NULL,
           `vernacular_name` varchar(255) DEFAULT NULL,
           `kingdom` varchar(255) DEFAULT NULL,
           `phylum` varchar(255) DEFAULT NULL,
           `taxon_class` varchar(255) DEFAULT NULL,
           `taxon_order` varchar(255) DEFAULT NULL,
           `family` varchar(255) DEFAULT NULL,
           `genus` varchar(255) DEFAULT NULL,
           `taxon_rank` varchar(255) DEFAULT NULL,
           `version` BIGINT NOT NULL DEFAULT 0,
           PRIMARY KEY (`id`,`scientific_name`),
           UNIQUE KEY `id_UNIQUE` (`id`)
    )

# Link the new created matchedSpecies table to speciesListItem table:
    ALTER TABLE `specieslist`.`species_list_item`
        ADD COLUMN `matched_species_id` INT DEFAULT NULL