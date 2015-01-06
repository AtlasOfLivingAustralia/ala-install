delimiter $$

DROP PROCEDURE IF EXISTS `logger`.`refresh_summary_breakdown_reason`;

CREATE DEFINER=`logger_user`@`%` PROCEDURE `refresh_summary_breakdown_reason`()
  BEGIN

-- ############ Create temporary tables #################
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_record_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_event_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_record_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_event_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason;

    CREATE TABLE `fix_event_summary_breakdown_reason` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `number_of_events` bigint(20) NOT NULL,
      `record_count` bigint(20) NOT NULL,
      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

    CREATE TABLE `fix_event_summary_breakdown_reason_entity` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `entity_uid` varchar(255) NOT NULL,
      `number_of_events` bigint(20) NOT NULL,
      `record_count` bigint(20) NOT NULL,
      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`,`entity_uid`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

    CREATE TABLE `fix_event_summary_breakdown_reason_entity_record_counts` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `entity_uid` varchar(255) NOT NULL,
      `record_count` bigint(20) NOT NULL,
      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`,`entity_uid`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

    CREATE TABLE `fix_event_summary_breakdown_reason_entity_event_counts` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `entity_uid` varchar(255) NOT NULL,
      `event_count` bigint(20) NOT NULL,
      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`,`entity_uid`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;


    CREATE TABLE `fix_event_summary_breakdown_reason_record_counts` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `record_count` bigint(20) NOT NULL,
      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;


    CREATE TABLE `fix_event_summary_breakdown_reason_event_counts` (
      `month` varchar(255) NOT NULL,
      `log_event_type_id` int(11) NOT NULL,
      `log_reason_type_id` int(11) NOT NULL default '-1',
      `event_count` bigint(20) NOT NULL,
      PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- ############ Populate reason summarys #################

-- record count sums
    insert into fix_event_summary_breakdown_reason_entity_record_counts
      select month, log_event_type_id, IFNULL(log_reason_type_id, -1) AS reason, entity_uid, SUM(record_count) from logger.log_event le
        inner join logger.log_detail ld ON ld.log_event_id=le.id
      group by month, log_event_type_id, reason, entity_uid;

-- event count sums
    insert into fix_event_summary_breakdown_reason_entity_event_counts
      select month, log_event_type_id, IFNULL(log_reason_type_id, -1) AS reason, entity_uid, COUNT(log_event_id) from logger.log_event le
        inner join logger.log_detail ld ON ld.log_event_id=le.id
      group by month, log_event_type_id, reason, entity_uid;

-- join into single table
    insert into fix_event_summary_breakdown_reason_entity
      select rc.month, rc.log_event_type_id, rc.log_reason_type_id, rc.entity_uid, ec.event_count, rc.record_count
      from logger.fix_event_summary_breakdown_reason_entity_record_counts rc
        inner join logger.fix_event_summary_breakdown_reason_entity_event_counts ec
          ON rc.month=ec.month AND rc.log_event_type_id=ec.log_event_type_id AND rc.log_reason_type_id=ec.log_reason_type_id AND rc.entity_uid=ec.entity_uid;

-- overall event counts
    insert into fix_event_summary_breakdown_reason_event_counts
      select month, log_event_type_id, IFNULL(log_reason_type_id, -1) AS reason, COUNT(id) from logger.log_event le
      group by month, log_event_type_id, reason;

-- overall record counts
    insert into fix_event_summary_breakdown_reason_record_counts
      select month, log_event_type_id, log_reason_type_id, SUM(record_count)
      from fix_event_summary_breakdown_reason_entity
      where entity_uid like 'dr%'
      group by month, log_event_type_id, log_reason_type_id;


-- create combined table of event and record counts
    insert into fix_event_summary_breakdown_reason
      select rc.month, rc.log_event_type_id, rc.log_reason_type_id, ec.event_count, rc.record_count from fix_event_summary_breakdown_reason_record_counts rc
        inner join logger.fix_event_summary_breakdown_reason_event_counts ec
          ON rc.month=ec.month AND rc.log_event_type_id=ec.log_event_type_id AND rc.log_reason_type_id=ec.log_reason_type_id;


-- ############ Swap new and old #################
    drop table IF EXISTS old_event_summary_breakdown_reason;
    drop table IF EXISTS old_event_summary_breakdown_reason_entity;

    RENAME table event_summary_breakdown_reason TO old_event_summary_breakdown_reason;
    RENAME table fix_event_summary_breakdown_reason TO event_summary_breakdown_reason;
    RENAME table event_summary_breakdown_reason_entity TO old_event_summary_breakdown_reason_entity;
    RENAME table fix_event_summary_breakdown_reason_entity TO event_summary_breakdown_reason_entity;

-- drop temporary tables
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_record_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity_event_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_record_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_event_counts;
    drop table IF EXISTS fix_event_summary_breakdown_reason_entity;
    drop table IF EXISTS fix_event_summary_breakdown_reason;

  END$$