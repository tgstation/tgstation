-- Version 5.9, 19 April 2020, by Jordie0608
-- Updates and improvements to poll handling.
-- Added the `deleted` column to tables 'poll_option', 'poll_textreply' and 'poll_vote' and the columns `created_datetime`, `subtitle`, `allow_revoting` and `deleted` to 'poll_question'.
-- Changes table 'poll_question' column `createdby_ckey` to be NOT NULL and index `idx_pquest_time_admin` to be `idx_pquest_time_deleted_id` and 'poll_textreply' column `adminrank` to have no default.
-- Added procedure `set_poll_deleted` that's called when deleting a poll to set deleted to true on each poll table where rows matching a poll_id argument.

ALTER TABLE `poll_option`
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `default_percentage_calc`;

ALTER TABLE `poll_question`
	CHANGE COLUMN `createdby_ckey` `createdby_ckey` VARCHAR(32) NOT NULL AFTER `multiplechoiceoptions`,
	ADD COLUMN `created_datetime` datetime NOT NULL AFTER `polltype`,
	ADD COLUMN `subtitle` VARCHAR(255) NULL DEFAULT NULL AFTER `question`,
	ADD COLUMN `allow_revoting` TINYINT(1) UNSIGNED NOT NULL AFTER `dontshow`,
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `allow_revoting`,
	DROP INDEX `idx_pquest_time_admin`,
	ADD INDEX `idx_pquest_time_deleted_id` (`starttime`, `endtime`, `deleted`, `id`);

ALTER TABLE `poll_textreply`
	CHANGE COLUMN `adminrank` `adminrank` varchar(32) NOT NULL AFTER `replytext`,
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `adminrank`;

ALTER TABLE `poll_vote`
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `rating`;

DELIMITER $$
CREATE PROCEDURE `set_poll_deleted`(
	IN `poll_id` INT
)
SQL SECURITY INVOKER
BEGIN
UPDATE `poll_question` SET deleted = 1 WHERE id = poll_id;
UPDATE `poll_option` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `poll_vote` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `poll_textreply` SET deleted = 1 WHERE pollid = poll_id;
END
$$
DELIMITER ;
