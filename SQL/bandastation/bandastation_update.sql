--
-- Table structure for table `schema_revision_220`
--
DROP TABLE IF EXISTS `schema_revision_220`;
CREATE TABLE `schema_revision_220` (
  `major` TINYINT(3) unsigned NOT NULL,
  `minor` TINYINT(3) unsigned NOT NULL,
  `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`major`, `minor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `ckey_whitelist`
--
DROP TABLE IF EXISTS `ckey_whitelist`;
CREATE TABLE `ckey_whitelist` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`date` DATETIME DEFAULT now() NOT NULL,
	`ckey` VARCHAR(32) NOT NULL,
	`adminwho` VARCHAR(32) NOT NULL,
	`port` INT(5) UNSIGNED NOT NULL,
	`date_start` DATETIME DEFAULT now() NOT NULL,
	`date_end` DATETIME NULL,
	`is_valid` BOOLEAN DEFAULT true NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `admin_wl`
--
DROP TABLE IF EXISTS `admin_wl`;
CREATE TABLE `admin_wl` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
	`admin_rank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Administrator',
	`level` int(2) NOT NULL DEFAULT '0',
	`flags` int(16) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `budget`
--
DROP TABLE IF EXISTS `budget`;
CREATE TABLE `budget` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `date` DATETIME NOT NULL DEFAULT current_timestamp(),
    `ckey` VARCHAR(32) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',
    `amount` INT(10) UNSIGNED NOT NULL,
    `source` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
    `date_start` DATETIME NOT NULL DEFAULT current_timestamp(),
    `date_end` DATETIME NULL DEFAULT (current_timestamp() + interval 1 month),
    `is_valid` TINYINT(1) NOT NULL DEFAULT '1',
    `discord_id` bigint(20) DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

--
-- Table structure for table `minesweeper`
--
DROP TABLE IF EXISTS `minesweeper`;
CREATE TABLE `minesweeper` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`date` DATETIME NOT NULL DEFAULT current_timestamp(),
	`ckey` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`nickname` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`time` INT(10) UNSIGNED NOT NULL,
	`points` INT(10) UNSIGNED NOT NULL,
	`points_per_sec` FLOAT(10) UNSIGNED NOT NULL,
	`width` TINYINT(3) UNSIGNED NOT NULL,
	`height` TINYINT(3) UNSIGNED NOT NULL,
	`bombs` TINYINT(3) UNSIGNED NOT NULL,
	PRIMARY KEY (`id`)
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

--
-- Table structure for table `admin_prime`
--
DROP TABLE IF EXISTS `admin_prime`;
CREATE TABLE `admin_prime` (
    `ckey` varchar(32) NOT NULL,
    `rank` varchar(32) NOT NULL,
    `feedback` varchar(255) DEFAULT NULL,
    PRIMARY KEY (`ckey`)
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
