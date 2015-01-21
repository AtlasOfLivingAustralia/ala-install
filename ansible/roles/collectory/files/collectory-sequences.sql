CREATE TABLE IF NOT EXISTS `sequence` (`id` bigint(20) NOT NULL,`next_id` bigint(20) NOT NULL,`name` varchar(45) NOT NULL,`prefix` varchar(5) NOT NULL, PRIMARY KEY (`id`));
INSERT IGNORE INTO sequence (id, name, prefix, `next_id`) VALUES 
 (1, 'collection', 'co', 0), 
 (2, 'institution', 'in', 0), 
 (3, 'dataProvider', 'dp', 0), 
 (4, 'dataResource', 'dr', 0), 
 (5, 'dataHub', 'dh', 0), 
 (6, 'attribution', 'at', 0), 
 (7, 'tempDataResource', 'drt', 0);