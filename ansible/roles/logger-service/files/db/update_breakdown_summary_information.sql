-- This trigger is called after inserts to the log_detail table. It updates the information in the following summary tables:
-- event_summary_totals
-- event_summary_breakdown_reason
-- event_summary_breakdown_reason_entity
-- event_summary_breakdown_email
-- event_summary_breakdown_email_entity
delimiter $$
DROP TRIGGER if exists `logger`.`update_breakdown_summary_information`;
CREATE
  DEFINER=`logger_user`@`%`
TRIGGER `logger`.`update_breakdown_summary_information`
AFTER INSERT ON `logger`.`log_detail`
FOR EACH ROW
  BEGIN
    DECLARE new_month INT(11) DEFAULT NULL;
    DECLARE new_user_email VARCHAR(255) DEFAULT NULL;
    DECLARE new_user_email_category VARCHAR(255) DEFAULT NULL;
    DECLARE new_log_event_type_id INT(11) DEFAULT 0;
    DECLARE new_log_reason_type_id INT(11) DEFAULT 0;

    DECLARE count_summary_total_rows INT(11) DEFAULT 0;
    DECLARE count_breakdown_reason_rows INT(11) DEFAULT 0;
    DECLARE count_breakdown_reason_entity_rows INT(11) DEFAULT 0;
    DECLARE count_breakdown_email_rows INT(11) DEFAULT 0;
    DECLARE count_breakdown_email_entity_rows INT(11) DEFAULT 0;
    DECLARE count_total_detail_rows_for_event INT(11) DEFAULT 0;
    DECLARE count_data_resource_detail_rows_for_event INT(11) DEFAULT 0;

    DECLARE uid_char CHAR(2);

    SET uid_char = (SUBSTR(NEW.entity_uid, 0, 2));

    -- get corresponding information from log_event table
    SELECT le.month, le.log_event_type_id, IFNULL(le.log_reason_type_id,-1), le.user_email FROM log_event le
    WHERE id = NEW.log_event_id
    INTO new_month, new_log_event_type_id, new_log_reason_type_id, new_user_email;

    -- determine how many detail rows have been added for the log event
    SELECT COUNT(*) FROM log_detail est
    WHERE log_event_id = NEW.log_event_id
    INTO count_total_detail_rows_for_event;

    -- determine how many detail rows for data resources have been added for the log event
    SELECT COUNT(*) FROM log_detail est
    WHERE log_event_id = NEW.log_event_id
    INTO count_data_resource_detail_rows_for_event;

    -- determine category for email address
    IF new_user_email IS NULL OR new_user_email = '' THEN
      SET new_user_email_category = 'unspecified';
    ELSEIF new_user_email LIKE '%.edu%' THEN
      SET new_user_email_category = 'edu';
    ELSEIF new_user_email LIKE '%.ac.%' THEN
      SET new_user_email_category = 'edu';
    ELSEIF new_user_email LIKE '%.gov%' THEN
      SET new_user_email_category = 'gov';
    ELSEIF new_user_email LIKE '%.csiro.au' THEN
      SET new_user_email_category = 'gov';
    ELSE
      SET new_user_email_category = 'other';
    END IF;

    -- determine if there is already a relevant row in the summary totals table
    SELECT COUNT(*) FROM event_summary_totals est
    WHERE est.month = new_month
          AND est.log_event_type_id = new_log_event_type_id
    INTO count_summary_total_rows;

    -- determine if there is already a relevant row in the reason breakdown table
    SELECT COUNT(*) FROM event_summary_breakdown_reason esbr
    WHERE esbr.month = new_month
          AND esbr.log_event_type_id = new_log_event_type_id AND esbr.log_reason_type_id = new_log_reason_type_id
    INTO count_breakdown_reason_rows;

    -- determine if there is already a relevant row in the reason/entity breakdown table
    SELECT COUNT(*) FROM event_summary_breakdown_reason_entity esbre
    WHERE esbre.month = new_month AND esbre.entity_uid = NEW.entity_uid
          AND esbre.log_event_type_id = new_log_event_type_id AND esbre.log_reason_type_id = new_log_reason_type_id
    INTO count_breakdown_reason_entity_rows;

    -- determine if there is already a relevant row in the email breakdown table
    SELECT COUNT(*) FROM event_summary_breakdown_email esbe
    WHERE esbe.month = new_month
          AND esbe.log_event_type_id = new_log_event_type_id AND esbe.user_email_category = new_user_email_category
    INTO count_breakdown_email_rows;

    -- determine if there is already a relevant row in the email/entity breakdown table
    SELECT COUNT(*) FROM event_summary_breakdown_email_entity esbee
    WHERE esbee.month = new_month AND esbee.entity_uid = NEW.entity_uid
          AND esbee.log_event_type_id = new_log_event_type_id AND esbee.user_email_category = new_user_email_category
    INTO count_breakdown_email_entity_rows;


    -- ############################################################################################################################################

    -- Update event_summary_totals
    IF count_summary_total_rows = 0 THEN

      INSERT INTO event_summary_totals (month, log_event_type_id, number_of_events, record_count)
      VALUES (new_month, new_log_event_type_id, 1, 0);

    ELSEIF count_total_detail_rows_for_event = 1 THEN

        -- only update the event count once per event!
        UPDATE event_summary_totals est SET number_of_events = number_of_events + 1, record_count = record_count + NEW.record_count
        WHERE est.month = new_month AND est.log_event_type_id = new_log_event_type_id;

    END IF;

    --  Update event_summary_breakdown_reason record counts - only update record counts for dr's
    IF NEW.entity_uid LIKE 'dr%' THEN
      UPDATE event_summary_totals est SET record_count = record_count + NEW.record_count
      WHERE est.month = new_month AND est.log_event_type_id = new_log_event_type_id;
    END IF;

    -- ############################################################################################################################################

    -- Update event_summary_breakdown_reason
    IF count_breakdown_reason_rows = 0 THEN

      INSERT INTO event_summary_breakdown_reason (month, log_event_type_id, log_reason_type_id, number_of_events, record_count)
      VALUES (new_month, new_log_event_type_id, new_log_reason_type_id, 1, 0);

    ELSEIF count_total_detail_rows_for_event = 1 THEN

      UPDATE event_summary_breakdown_reason esrb SET number_of_events = number_of_events + 1
      WHERE esrb.month = new_month AND esrb.log_event_type_id = new_log_event_type_id AND esrb.log_reason_type_id = new_log_reason_type_id;

    END IF;

    --  Update event_summary_breakdown_reason record counts - only update record counts for dr's
    IF NEW.entity_uid LIKE 'dr%' THEN
      UPDATE event_summary_breakdown_reason esrb SET record_count = record_count + NEW.record_count
      WHERE esrb.month = new_month AND esrb.log_event_type_id = new_log_event_type_id AND esrb.log_reason_type_id = new_log_reason_type_id;
    END IF;

    -- ############################################################################################################################################

    -- Update event_summary_breakdown_email
    IF count_breakdown_email_rows = 0 THEN

      INSERT INTO event_summary_breakdown_email (month, log_event_type_id, user_email_category, number_of_events, record_count)
      VALUES (new_month, new_log_event_type_id, new_user_email_category, 1, 0);

    ELSEIF count_total_detail_rows_for_event = 1 then

        UPDATE event_summary_breakdown_email esbe SET number_of_events = number_of_events + 1
        WHERE esbe.month = new_month AND esbe.log_event_type_id = new_log_event_type_id AND esbe.user_email_category = new_user_email_category;

    END IF;

    --  Update event_summary_breakdown_reason record counts - only update record counts for dr's
    IF NEW.entity_uid LIKE 'dr%' THEN
      UPDATE event_summary_breakdown_email esbe SET record_count = record_count + NEW.record_count
      WHERE esbe.month = new_month AND esbe.log_event_type_id = new_log_event_type_id AND esbe.user_email_category = new_user_email_category;
    END IF;

    -- ############################################################################################################################################

    -- Update event_summary_breakdown_reason_entity
    IF count_breakdown_reason_entity_rows = 0 THEN
      INSERT INTO event_summary_breakdown_reason_entity (month, log_event_type_id, log_reason_type_id, entity_uid, number_of_events, record_count)
      VALUES (new_month, new_log_event_type_id, new_log_reason_type_id, NEW.entity_uid, 1, NEW.record_count);
    ELSE
      -- can always update the number of events here, as there will always be a single to for each entity/log_event
      UPDATE event_summary_breakdown_reason_entity esrbe SET number_of_events = number_of_events + 1, record_count = record_count + NEW.record_count
      WHERE esrbe.month = new_month AND esrbe.entity_uid = NEW.entity_uid
            AND esrbe.log_event_type_id = new_log_event_type_id AND esrbe.log_reason_type_id = new_log_reason_type_id;
    END IF;

    -- ############################################################################################################################################

    -- Update event_summary_breakdown_email_entity
    IF count_breakdown_email_entity_rows = 0 THEN
      INSERT INTO event_summary_breakdown_email_entity (month, log_event_type_id, user_email_category, entity_uid, number_of_events, record_count)
      VALUES (new_month, new_log_event_type_id, new_user_email_category, NEW.entity_uid, 1, NEW.record_count);
    ELSE
      -- can always update the number of events here, as there will always be a single to for each entity/log_event
      UPDATE event_summary_breakdown_email_entity esbee SET number_of_events = number_of_events + 1, record_count = record_count + NEW.record_count
      WHERE esbee.month = new_month AND esbee.entity_uid = NEW.entity_uid
            AND esbee.log_event_type_id = new_log_event_type_id AND esbee.user_email_category = new_user_email_category;
    END IF;

  END
$$