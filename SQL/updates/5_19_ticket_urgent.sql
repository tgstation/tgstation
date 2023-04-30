-- Version 5.19, 10 November 2021, by WalterMeldron
-- Adds an urgent column to tickets for ahelps marked as urgent.

ALTER TABLE `ticket` ADD COLUMN `urgent` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `sender`;
