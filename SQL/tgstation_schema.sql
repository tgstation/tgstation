CREATE DATABASE  IF NOT EXISTS `feedback` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `feedback`;

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
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL DEFAULT 'Administrator',
  `level` int(2) NOT NULL DEFAULT '0',
  `flags` int(16) NOT NULL DEFAULT '0',
  `email` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_log`
--

DROP TABLE IF EXISTS `admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` varchar(18) NOT NULL,
  `log` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_ranks`
--

DROP TABLE IF EXISTS `admin_ranks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rank` varchar(40) NOT NULL,
  `flags` int(16) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

insert into admin_ranks (rank, flags) values ('Moderator',2);
insert into admin_ranks (rank, flags) values ('Admin Candidate',2);
insert into admin_ranks (rank, flags) values ('Trial Admin',5638);
insert into admin_ranks (rank, flags) values ('Badmin',5727);
insert into admin_ranks (rank, flags) values ('Game Admin',8063);
insert into admin_ranks (rank, flags) values ('Game Master',65535);
insert into admin_ranks (rank, flags) values ('Host',65535);
insert into admin_ranks (rank, flags) values ('Coder',5168);

--
-- Table structure for table `ban`
--

DROP TABLE IF EXISTS `ban`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) NOT NULL,
  `bantype` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `rounds` int(11) DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `who` text NOT NULL,
  `adminwho` text NOT NULL,
  `edits` text,
  `unbanned` int(2) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `connection_log`
--

DROP TABLE IF EXISTS `connection_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `serverip` varchar(45) DEFAULT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` varchar(18) DEFAULT NULL,
  `computerid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `death`
--

DROP TABLE IF EXISTS `death`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `death` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pod` text NOT NULL COMMENT 'Place of death',
  `coord` text NOT NULL COMMENT 'X, Y, Z POD',
  `mapname` text NOT NULL,
  `server` text NOT NULL,
  `tod` datetime NOT NULL COMMENT 'Time of death',
  `job` text NOT NULL,
  `special` text NOT NULL,
  `name` text NOT NULL,
  `byondkey` text NOT NULL,
  `laname` text NOT NULL COMMENT 'Last attacker name',
  `lakey` text NOT NULL COMMENT 'Last attacker key',
  `gender` text NOT NULL,
  `bruteloss` int(11) NOT NULL,
  `brainloss` int(11) NOT NULL,
  `fireloss` int(11) NOT NULL,
  `oxyloss` int(11) NOT NULL,
  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `round_id` int(8) NOT NULL,
  `var_name` varchar(32) NOT NULL,
  `var_value` int(16) DEFAULT NULL,
  `details` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `legacy_population`
--

DROP TABLE IF EXISTS `legacy_population`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legacy_population` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playercount` int(11) DEFAULT NULL,
  `admincount` int(11) DEFAULT NULL,
  `time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `library`
--

DROP TABLE IF EXISTS `library`;
CREATE TABLE `library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(45) NOT NULL,
  `title` varchar(45) NOT NULL,
  `content` text NOT NULL,
  `category` varchar(45) NOT NULL,
  `ckey` varchar(45) DEFAULT 'LEGACY',
  `datetime` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Create an index to speed up the libary
--
CREATE INDEX deleted_idx ON `library` (`deleted`);

--
-- Table structure for table `player`
--

DROP TABLE IF EXISTS `player`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `poll_option`
--

DROP TABLE IF EXISTS `poll_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `percentagecalc` tinyint(1) NOT NULL DEFAULT '1',
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `poll_question`
--

DROP TABLE IF EXISTS `poll_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` varchar(16) NOT NULL DEFAULT 'OPTION',
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `adminonly` tinyint(1) DEFAULT '0',
  `multiplechoiceoptions` int(2) DEFAULT NULL,
  `createdby_ckey` varchar(45) NULL DEFAULT NULL,
  `createdby_ip` varchar(45) NULL DEFAULT NULL,
  `for_trialmin` varchar(45) NULL DEFAULT NULL,
  `dontshow` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `poll_textreply`
--

DROP TABLE IF EXISTS `poll_textreply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` varchar(18) NOT NULL,
  `replytext` text NOT NULL,
  `adminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `poll_vote`
--

DROP TABLE IF EXISTS `poll_vote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(255) NOT NULL,
  `ip` varchar(16) NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ipintel`
--

DROP TABLE IF EXISTS `ipintel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ipintel` (
`ip` INT UNSIGNED NOT NULL ,
`date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL ,
`intel` REAL NOT NULL DEFAULT  '0',
PRIMARY KEY (  `ip` )
) ENGINE = INNODB;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT ,
  `type` varchar(32) NOT NULL ,
  `targetckey` varchar(32) NOT NULL ,
  `adminckey` varchar(32) NOT NULL ,
  `text` text NOT NULL ,
  `timestamp` datetime NOT NULL ,
  `server` varchar(32) NULL ,
  `secret` tinyint(1) NULL DEFAULT 1 ,
  `lasteditor` varchar(32) NULL ,
  `edits` text NULL ,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
