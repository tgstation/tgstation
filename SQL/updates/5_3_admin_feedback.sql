-- Version 5.3, 6 July 2019, by Atlanta-Ned
-- Added a `feedback` column to the admin table, used for linking to individual admin feedback threads. Currently this is only used for statistics tracking tools such as Statbus and isn't used by the game.

ALTER TABLE `admin` ADD `feedback` VARCHAR(255) NULL DEFAULT NULL AFTER `rank`;
