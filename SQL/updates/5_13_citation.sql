-- Version 5.13, 30 April 2021, by Atlanta Ned
-- Added the `citation` table for tracking security citations in the database.

CREATE TABLE `citation` (
	`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`round_id` INT(11) UNSIGNED NOT NULL,
	`server_ip` INT(11) UNSIGNED NOT NULL,
	`server_port` INT(11) UNSIGNED NOT NULL,
	`citation` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`action` VARCHAR(20) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	`sender` VARCHAR(32) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	`sender_ic` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'Longer because this is the character name, not the ckey' COLLATE 'utf8mb4_general_ci',
	`recipient` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'Longer because this is the character name, not the ckey' COLLATE 'utf8mb4_general_ci',
	`crime` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`fine` INT(4) NULL DEFAULT NULL,
	`paid` INT(4) NULL DEFAULT '0',
	`timestamp` DATETIME NOT NULL,
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `idx_constraints` (`round_id`, `server_ip`, `server_port`, `citation`(100)) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1
;
