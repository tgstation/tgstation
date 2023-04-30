-- Version 5.2, 30 May 2019, by AffectedArc07
-- Added a field to the `player` table to track ckey and discord ID relationships

ALTER TABLE `player`
	ADD COLUMN `discord_id` BIGINT NULL DEFAULT NULL AFTER `flags`;
