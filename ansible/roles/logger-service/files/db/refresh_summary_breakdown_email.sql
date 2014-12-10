-- This stored procedure is used to populate the "event_summary_breakdown_email" and "event_summary_breakdown_email_entity" tables
-- from all existing log information
delimiter $$

DROP PROCEDURE IF EXISTS `logger`.`refresh_summary_breakdown_email`;

CREATE DEFINER=`logger_user`@`%` PROCEDURE `refresh_summary_breakdown_email`()
BEGIN
DECLARE current_month varchar(255);
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT DISTINCT month from log_event;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN cur1;

DELETE FROM event_summary_breakdown_email;
DELETE FROM event_summary_breakdown_email_entity;

SELECT 'Building temporary table for email categories';

-- create temporary table with email categories
CREATE TEMPORARY TABLE `email_category`
(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_email_category` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
);

-- populate temporary table
SELECT 'unspecified';
INSERT INTO email_category (id, user_email_category) 
   SELECT id, 'unspecified' FROM log_event WHERE user_email IS NULL OR user_email = '';

SELECT 'edu';
INSERT INTO email_category (id, user_email_category) 
   SELECT id, 'edu' FROM log_event WHERE user_email LIKE '%.edu%';

SELECT 'gov';
INSERT INTO email_category (id, user_email_category) 
   SELECT id, 'gov' FROM log_event WHERE user_email LIKE '%.gov%';

SELECT 'other';
INSERT INTO email_category (id, user_email_category) 
   SELECT id, 'other' FROM log_event WHERE user_email IS NOT NULL AND user_email <> '' AND 
    user_email NOT LIKE '%.gov%' AND user_email NOT LIKE '%.edu%';

SELECT 'Generating email breakdown';

the_loop: LOOP
	FETCH cur1 into current_month;

	IF done THEN
		CLOSE cur1;
		LEAVE the_loop;
	END IF;

	-- print progress
	SELECT current_month;

    -- Insert into table for breakdown by email only
	INSERT INTO event_summary_breakdown_email (month, log_event_type_id, user_email_category, number_of_events, record_count)
		SELECT le1.month, le1.log_event_type_id, ec.user_email_category,
			COUNT(distinct ld1.log_event_id) AS numberOfEvents, SUM(ld1.record_count) AS numberOfEventItems
	    FROM log_event le1 INNER JOIN email_category ec ON le1.id = ec.id INNER JOIN log_detail ld1 ON le1.id=ld1.log_event_id 
		WHERE le1.month = current_month GROUP BY le1.month, le1.log_event_type_id, ec.user_email_category;    

    -- Insert into table for breakdown by email and entity
	INSERT INTO event_summary_breakdown_email_entity (month, log_event_type_id, user_email_category, entity_uid, number_of_events, record_count)
		SELECT le1.month, le1.log_event_type_id, ec.user_email_category, ld1.entity_uid,
			COUNT(distinct ld1.log_event_id) AS numberOfEvents, SUM(ld1.record_count) AS numberOfEventItems
	    FROM log_event le1 INNER JOIN email_category ec ON le1.id = ec.id INNER JOIN log_detail ld1 ON le1.id=ld1.log_event_id 
		WHERE le1.month = current_month GROUP BY le1.month, ld1.entity_uid, le1.log_event_type_id, ec.user_email_category; 

END LOOP the_loop;

END$$

