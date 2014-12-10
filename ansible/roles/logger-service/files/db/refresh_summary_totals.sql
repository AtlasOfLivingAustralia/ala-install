-- This stored procedure is used to populate the "event_summary_totals" table from all existing log information

delimiter $$

DROP PROCEDURE IF EXISTS `logger`.`refresh_summary_totals`;

CREATE DEFINER=`logger_user`@`%` PROCEDURE `refresh_summary_totals`()
BEGIN
DECLARE current_month varchar(255);
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT DISTINCT month from log_event;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN cur1;

DELETE FROM event_summary_totals;

the_loop: LOOP
  FETCH cur1 into current_month;

  IF done THEN
    CLOSE cur1;
    LEAVE the_loop;
	END IF;

  -- print progress
  SELECT current_month;

  -- Insert into summary totals table
  INSERT INTO event_summary_totals (month, log_event_type_id, number_of_events, record_count)
    SELECT le.month, le.log_event_type_id, COUNT(DISTINCT ld.log_event_id), SUM(ld.record_count)
    FROM log_event le
    INNER JOIN log_detail ld  ON le.id=ld.log_event_id
    WHERE
    le.month = current_month AND
    ld.entity_uid like 'dr%'
    GROUP BY le.month, le.log_event_type_id;

END LOOP the_loop;
END$$

