-- Version 5.10, 7 August 2020, by oranges
-- Changes how the discord verification process works.
-- Adds the discord_links table, and migrates discord id entries from player table to the discord links table in a once off operation and then removes the discord id
-- on the player table

START TRANSACTION;

DROP TABLE IF EXISTS `discord_links`;
CREATE TABLE `discord_links` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`ckey` VARCHAR(32) NOT NULL,
	`discord_id` BIGINT(20) DEFAULT NULL,
	`timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`one_time_token` VARCHAR(100) NOT NULL,
	`valid` BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO `discord_links` (`ckey`, `discord_id`, `one_time_token`, `valid`) SELECT `ckey`, `discord_id`, CONCAT("presync_from_player_table_", `ckey`), TRUE FROM `player` WHERE discord_id IS NOT NULL;

ALTER TABLE `player` DROP COLUMN `discord_id`;

COMMIT;
