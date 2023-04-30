-- Version 5.6, 6 December 2019 by Anturke
-- Added achievement_name and achievement_description columns to achievement_metadata table.

ALTER TABLE `achievement_metadata` ADD COLUMN (`achievement_name` VARCHAR(64) NULL DEFAULT NULL, `achievement_description` VARCHAR(512) NULL DEFAULT NULL);
