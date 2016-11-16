# noinspection SqlNoDataSourceInspectionForFile
delimiter $$

DROP PROCEDURE IF EXISTS `logger`.`refresh_summary_breakdown_source`;

CREATE DEFINER=`logger_user`@`%` PROCEDURE `refresh_summary_breakdown_source`()
  BEGIN

-- ############ Create temporary tables #################
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_source;
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_source_record_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_source_event_counts;

    CREATE TABLE `fix_event_summary_breakdown_reason_entity_source` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `entity_uid` varchar(255) NOT NULL,
      `log_source_type_id` int(11) NOT NULL default '-1',
      `number_of_events` bigint(20) NOT NULL,
      `record_count` bigint(20) NOT NULL,

      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`,`entity_uid`, `log_source_type_id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

    CREATE TABLE `fix_event_summary_breakdown_reason_entity_source_record_counts` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `entity_uid` varchar(255) NOT NULL,
      `log_source_type_id` int(11) NOT NULL default '-1',
      `record_count` bigint(20) NOT NULL,

      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`,`entity_uid`, `log_source_type_id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

    CREATE TABLE `fix_event_summary_breakdown_reason_entity_source_event_counts` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `entity_uid` varchar(255) NOT NULL,
      `log_source_type_id` int(11) NOT NULL default '-1',
      `event_count` bigint(20) NOT NULL,
      
      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`,`entity_uid`, `log_source_type_id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ############ Populate reason summarys #################

-- record source count sums
    insert into fix_event_summary_breakdown_reason_entity_source_record_counts
      select month, log_event_type_id, IFNULL(log_reason_type_id, -1) AS reason, entity_uid, IFNULL(log_source_type_id, -1), SUM(record_count) from logger.log_event le
        inner join logger.log_detail ld ON ld.log_event_id=le.id
      group by month, log_event_type_id, reason, entity_uid, log_source_type_id;

-- event source count sums
    insert into fix_event_summary_breakdown_reason_entity_source_event_counts
      select month, log_event_type_id, IFNULL(log_reason_type_id, -1) AS reason, entity_uid, IFNULL(log_source_type_id, -1) as source, COUNT(log_event_id) from logger.log_event le
        inner join logger.log_detail ld ON ld.log_event_id=le.id
      group by month, log_event_type_id, reason, entity_uid, log_source_type_id;

-- join into single table
    insert into fix_event_summary_breakdown_reason_entity_source
      select rc.month, rc.log_event_type_id, rc.log_reason_type_id, rc.entity_uid, rc.log_source_type_id, ec.event_count, rc.record_count
      from logger.fix_event_summary_breakdown_reason_entity_source_record_counts rc
        inner join logger.fix_event_summary_breakdown_reason_entity_source_event_counts ec
          ON rc.month=ec.month AND rc.log_event_type_id=ec.log_event_type_id AND rc.log_reason_type_id=ec.log_reason_type_id AND rc.log_source_type_id=ec.log_source_type_id AND rc.entity_uid=ec.entity_uid;

-- ############ Swap new and old #################
	  drop table IF EXISTS old_event_summary_breakdown_reason_entity_source;

    RENAME table event_summary_breakdown_reason_entity_source TO old_event_summary_breakdown_reason_entity_source;
    RENAME table fix_event_summary_breakdown_reason_entity_source TO event_summary_breakdown_reason_entity_source;

-- drop temporary tables
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_source_record_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_source_event_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_source;

  END$$
