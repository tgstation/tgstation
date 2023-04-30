-- Version 5.16, 31 July 2021, by Atlanta-Ned
-- Added `library_action` table for tracking reported library books and actions taken on them.

DROP TABLE IF EXISTS `library_action`;
CREATE TABLE `library_action` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `book` int(10) unsigned NOT NULL,
  `reason` longtext DEFAULT NULL,
  `ckey` varchar(11) NOT NULL DEFAULT '',
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `action` varchar(11) NOT NULL DEFAULT '',
  `ip_addr` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
