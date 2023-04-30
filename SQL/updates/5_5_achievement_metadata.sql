-- Version 5.5, 26 October 2019 by Anturke
-- Added achievement_metadata table.

DROP TABLE IF EXISTS `achievement_metadata`;
CREATE TABLE `achievement_metadata` (
	`achievement_key` VARCHAR(32) NOT NULL,
	`achievement_version` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`achievement_type` enum('achievement','score','award') NULL DEFAULT NULL,
	PRIMARY KEY (`achievement_key`)
) ENGINE=InnoDB;
