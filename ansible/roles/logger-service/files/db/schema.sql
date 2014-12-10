-- MySQL dump 10.11
--
-- Host: localhost    Database: logger
-- ------------------------------------------------------
-- Server version	5.0.67

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `event_summary_breakdown_email`
--

DROP TABLE IF EXISTS `event_summary_breakdown_email`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `event_summary_breakdown_email` (
  `month` varchar(255) NOT NULL,
  `log_event_type_id` int(11) NOT NULL,
  `user_email_category` varchar(255) NOT NULL,
  `number_of_events` bigint(20) default NULL,
  `record_count` bigint(20) default NULL,
  PRIMARY KEY  (`month`,`log_event_type_id`,`user_email_category`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `event_summary_breakdown_email_entity`
--

DROP TABLE IF EXISTS `event_summary_breakdown_email_entity`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `event_summary_breakdown_email_entity` (
  `month` varchar(255) NOT NULL,
  `log_event_type_id` int(11) NOT NULL,
  `user_email_category` varchar(255) NOT NULL,
  `entity_uid` varchar(255) NOT NULL,
  `number_of_events` bigint(20) default NULL,
  `record_count` bigint(20) default NULL,
  PRIMARY KEY  (`month`,`log_event_type_id`,`user_email_category`,`entity_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `event_summary_breakdown_reason`
--

DROP TABLE IF EXISTS `event_summary_breakdown_reason`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `event_summary_breakdown_reason` (
  `month` varchar(255) NOT NULL,
  `log_event_type_id` int(11) NOT NULL,
  `log_reason_type_id` int(11) NOT NULL default '-1',
  `number_of_events` bigint(20) NOT NULL,
  `record_count` bigint(20) NOT NULL,
  PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `event_summary_breakdown_reason_entity`
--

DROP TABLE IF EXISTS `event_summary_breakdown_reason_entity`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `event_summary_breakdown_reason_entity` (
  `month` varchar(255) NOT NULL,
  `log_event_type_id` int(11) NOT NULL,
  `log_reason_type_id` int(11) NOT NULL default '-1',
  `entity_uid` varchar(255) NOT NULL,
  `number_of_events` bigint(20) NOT NULL,
  `record_count` bigint(20) NOT NULL,
  PRIMARY KEY  (`month`,`log_event_type_id`,`log_reason_type_id`,`entity_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `event_summary_totals`
--

DROP TABLE IF EXISTS `event_summary_totals`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `event_summary_totals` (
  `month` varchar(255) NOT NULL,
  `log_event_type_id` int(11) NOT NULL,
  `number_of_events` bigint(20) default NULL,
  `record_count` bigint(20) default NULL,
  PRIMARY KEY  (`month`,`log_event_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `log_event`
--

DROP TABLE IF EXISTS `log_event`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `log_event` (
  `id` int(11) NOT NULL auto_increment,
  `comment` text,
  `created` datetime default NULL,
  `log_event_type_id` int(11) default NULL,
  `month` varchar(255) default NULL,
  `user_email` varchar(255) default NULL,
  `user_ip` varchar(255) default NULL,
  `source` varchar(255) default NULL,
  `user_agent` varchar(255) default NULL,
  `log_reason_type_id` int(11) default NULL,
  `log_source_type_id` int(11) default NULL,
  `source_url` text,
  PRIMARY KEY  (`id`),
  KEY `SUMMARYINDEX1` (`id`,`month`,`log_event_type_id`,`log_reason_type_id`),
  KEY `SUMMARYINDEX2` (`id`,`month`,`log_event_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1047000834 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `log_event_type`
--

DROP TABLE IF EXISTS `log_event_type`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `log_event_type` (
  `id` int(11) NOT NULL,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `log_reason_type`
--

DROP TABLE IF EXISTS `log_reason_type`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `log_reason_type` (
  `id` int(11) NOT NULL,
  `rkey` varchar(255) default NULL,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `remote_address`
--

DROP TABLE IF EXISTS `remote_address`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `remote_address` (
  `id` int(11) NOT NULL auto_increment,
  `ip` varchar(255) NOT NULL,
  `host_name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

alter table remote_address add constraint ra_ip_unique unique (ip);


--
-- Table structure for table `log_source_type`
--

DROP TABLE IF EXISTS `log_source_type`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `log_source_type` (
  `id` int(11) NOT NULL,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-11  1:55:03


DROP TABLE IF EXISTS `log_detail`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `log_detail` (
  `id` int(11) NOT NULL auto_increment,
  `entity_type` varchar(255) default NULL,
  `entity_uid` varchar(255) default NULL,
  `record_count` bigint(20) default NULL,
  `log_event_id` int(11),
  PRIMARY KEY  (`id`),
  FOREIGN KEY (log_event_id) REFERENCES log_event(id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;