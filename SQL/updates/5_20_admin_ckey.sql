-- Version 5.20, 11 November 2021, by Mothblocks
-- Adds `admin_ckey` field to the `known_alts` table to track who added what.

ALTER TABLE `known_alts`
ADD COLUMN `admin_ckey` VARCHAR(32) NOT NULL DEFAULT '*no key*' AFTER `ckey2`;
