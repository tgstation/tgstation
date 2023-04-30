-- Version 5.8, 7 April 2020, by Jordie0608
-- Modified table `messages`, adding column `deleted_ckey` to record who deleted a message.

ALTER TABLE `messages` ADD COLUMN `deleted_ckey` VARCHAR(32) NULL DEFAULT NULL AFTER `deleted`;
