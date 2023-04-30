-- Version 5.14, xx May 2021, by Anturke
-- Added exploration drone adventure table

DROP TABLE IF EXISTS `text_adventures`;
CREATE TABLE `text_adventures` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`adventure_data` LONGTEXT NOT NULL,
	`uploader` VARCHAR(32) NOT NULL,
	`timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`approved` TINYINT(1) NOT NULL DEFAULT FALSE,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB;
