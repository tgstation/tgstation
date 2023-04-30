-- Version 5.7, 10 January 2020 by Atlanta-Ned
-- Added ticket table for tracking ahelp tickets in the database.

DROP TABLE IF EXISTS `ticket`;
CREATE TABLE `ticket` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `ticket` smallint(11) unsigned NOT NULL,
  `action` varchar(20) NOT NULL DEFAULT 'Message',
  `message` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `recipient` varchar(32) DEFAULT NULL,
  `sender` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
