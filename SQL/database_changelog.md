Any time you make a change to the schema files, remember to increment the database schema version. Generally increment the minor number, major should be reserved for significant changes to the schema. Both values go up to 255.

Make sure to also update `DB_MAJOR_VERSION` and `DB_MINOR_VERSION`, which can be found in `code/__DEFINES/subsystem.dm`.

The latest database version is 5.27; The query to update the schema revision table is:

```sql
INSERT INTO `schema_revision` (`major`, `minor`) VALUES (5, 27);
```
or

```sql
INSERT INTO `SS13_schema_revision` (`major`, `minor`) VALUES (5, 27);
```

In any query remember to add a prefix to the table names if you use one.
-----------------------------------------------------
Version 5.27, 26 April 2024, by zephyrtfa
Add the ip intel whitelist table
```sql
DROP TABLE IF EXISTS `ipintel_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ipintel_whitelist` (
	`ckey` varchar(32) NOT NULL,
	`admin_ckey` varchar(32) NOT NULL,
	PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
```
-----------------------------------------------------
Version 5.26, 03 December 2023, by distributivgesetz
Set the default value of cloneloss to 0, as it's obsolete and it won't be set by blackbox anymore.
```sql
ALTER TABLE `death` MODIFY COLUMN `cloneloss` SMALLINT(5) UNSIGNED DEFAULT '0';
```

-----------------------------------------------------
Version 5.25, 27 September 2023, by Jimmyl
Removes the text_adventures table because it is no longer used
```sql
 DROP TABLE IF EXISTS `text_adventures`;
```

-----------------------------------------------------
Version 5.24, 17 May 2023, by LemonInTheDark
Modified the library action table to fit ckeys properly, and to properly store ips.
```sql
 ALTER TABLE `library_action` MODIFY COLUMN `ckey` varchar(32) NOT NULL;
 ALTER TABLE `library_action` MODIFY COLUMN `ip_addr` int(10) unsigned NOT NULL;
```

-----------------------------------------------------
Version 5.23, 28 December 2022, by Mothblocks
Added `tutorial_completions` to mark what ckeys have completed contextual tutorials.

```sql
CREATE TABLE `tutorial_completions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ckey` VARCHAR(32) NOT NULL,
  `tutorial_key` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `ckey_tutorial_unique` (`ckey`, `tutorial_key`));
```

-----------------------------------------------------
Version 5.22, 22 December 2021, by Mothblocks
Fixes a bug in `telemetry_connections` that limited the range of IPs.

```sql
ALTER TABLE `telemetry_connections` MODIFY COLUMN `address` INT(10) UNSIGNED NOT NULL;
```
-----------------------------------------------------

Version 5.21, 15 December 2021, by Mothblocks
Adds `telemetry_connections` table for tracking tgui telemetry.

```sql
CREATE TABLE `telemetry_connections` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `ckey` VARCHAR(32) NOT NULL,
    `telemetry_ckey` VARCHAR(32) NOT NULL,
    `address` INT(10) NOT NULL,
    `computer_id` VARCHAR(32) NOT NULL,
    `first_round_id` INT(11) UNSIGNED NULL,
    `latest_round_id` INT(11) UNSIGNED NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `unique_constraints` (`ckey` , `telemetry_ckey` , `address` , `computer_id`)
);
```
-----------------------------------------------------

Version 5.20, 11 November 2021, by Mothblocks
Adds `admin_ckey` field to the `known_alts` table to track who added what.

```sql
ALTER TABLE `known_alts`
ADD COLUMN `admin_ckey` VARCHAR(32) NOT NULL DEFAULT '*no key*' AFTER `ckey2`;
```

-----------------------------------------------------
Version 5.19, 10 November 2021, by WalterMeldron
Adds an urgent column to tickets for ahelps marked as urgent.

```sql
ALTER TABLE `ticket` ADD COLUMN `urgent` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `sender`;
```

-----------------------------------------------------
Version 5.18, 1 November 2021, by Mothblocks
Added `known_alts` table for tracking who not to create suspicious logins for.

```sql
CREATE TABLE `known_alts` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `ckey1` VARCHAR(32) NOT NULL,
    `ckey2` VARCHAR(32) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `unique_contraints` (`ckey1` , `ckey2`)
);
```

-----------------------------------------------------
Version 5.17, 8 October 2021, by MrStonedOne + Mothblocks
Changes any table that requrired a NOT NULL round ID to now accept NULL. In the BSQL past, these were handled as 0, but in the move to rust-g this behavior was lost.

```sql
ALTER TABLE `admin_log` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `ban` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `citation` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `connection_log` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `death` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `feedback` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `legacy_population` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `library` CHANGE `round_id_created` `round_id_created` INT(11) UNSIGNED NULL;
ALTER TABLE `messages` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `player` CHANGE `firstseen_round_id` `firstseen_round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `player` CHANGE `lastseen_round_id` `lastseen_round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `ticket` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
```

-----------------------------------------------------
Version 5.16, 31 July 2021, by Atlanta-Ned
Added `library_action` table for tracking reported library books and actions taken on them.

```sql
DROP TABLE IF EXISTS `library_action`;
CREATE TABLE `library_action` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `book` int(10) unsigned NOT NULL,
  `reason` longtext DEFAULT NULL,
  `ckey` varchar(11) NOT NULL DEFAULT '',
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `action` varchar(11) NOT NULL DEFAULT '',
  `ip_addr` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
```


-----------------------------------------------------
Version 5.15, 2 June 2021, by Mothblocks
Added verified admin connection log used for 2FA

```sql
DROP TABLE IF EXISTS `admin_connections`;
CREATE TABLE `admin_connections` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ckey` VARCHAR(32) NOT NULL,
  `ip` INT(11) UNSIGNED NOT NULL,
  `cid` VARCHAR(32) NOT NULL,
  `verification_time` DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_constraints` (`ckey`, `ip`, `cid`));
```

-----------------------------------------------------

Version 5.14, xx May 2021, by Anturke
Added exploration drone adventure table

```sql
DROP TABLE IF EXISTS `text_adventures`;
CREATE TABLE `text_adventures` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`adventure_data` LONGTEXT NOT NULL,
	`uploader` VARCHAR(32) NOT NULL,
	`timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`approved` TINYINT(1) NOT NULL DEFAULT FALSE,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB;
```

-----------------------------------------------------

Version 5.13, 30 April 2021, by Atlanta Ned
Added the `citation` table for tracking security citations in the database.

```sql
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
```

-----------------------------------------------------

Version 5.12, 29 December 2020, by Missfox
Modified table `messages`, adding column `playtime` to show the user's playtime when the note was created.

ALTER TABLE `messages` ADD `playtime` INT(11) NULL DEFAULT(NULL) AFTER `severity`

-----------------------------------------------------

Version 5.11, 7 September 2020, by bobbahbrown, MrStonedOne, and Jordie0608 (Updated 26 March 2021 by bobbahbrown)

Adds indices to support search operations on the adminhelp ticket tables. This is to support improved performance on Atlanta Ned's Statbus.

```sql
ALTER TABLE `ticket`
	ADD INDEX `idx_ticket_act_recip` (`action`, `recipient`),
	ADD INDEX `idx_ticket_act_send` (`action`, `sender`),
	ADD INDEX `idx_ticket_tic_rid` (`ticket`, `round_id`),
	ADD INDEX `idx_ticket_act_time_rid` (`action`, `timestamp`, `round_id`);
```

-----------------------------------------------------

Version 5.10, 7 August 2020, by oranges

Changes how the discord verification process works.
Adds the discord_links table, and migrates discord id entries from player table to the discord links table in a once off operation and then removes the discord id
on the player table

```sql
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
```

-----------------------------------------------------

Version 5.9, 19 April 2020, by Jordie0608
Updates and improvements to poll handling.
Added the `deleted` column to tables 'poll_option', 'poll_textreply' and 'poll_vote' and the columns `created_datetime`, `subtitle`, `allow_revoting` and `deleted` to 'poll_question'.
Changes table 'poll_question' column `createdby_ckey` to be NOT NULL and index `idx_pquest_time_admin` to be `idx_pquest_time_deleted_id` and 'poll_textreply' column `adminrank` to have no default.
Added procedure `set_poll_deleted` that's called when deleting a poll to set deleted to true on each poll table where rows matching a poll_id argument.

```sql
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
```

-----------------------------------------------------

Version 5.8, 7 April 2020, by Jordie0608
Modified table `messages`, adding column `deleted_ckey` to record who deleted a message.

```sql
ALTER TABLE `messages` ADD COLUMN `deleted_ckey` VARCHAR(32) NULL DEFAULT NULL AFTER `deleted`;
```

-----------------------------------------------------

Version 5.7, 10 January 2020 by Atlanta-Ned
Added ticket table for tracking ahelp tickets in the database.

```sql
DROP TABLE IF EXISTS `ticket`;
CREATE TABLE `ticket` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `ticket` smallint(11) unsigned NOT NULL,
  `action` varchar(20) NOT NULL DEFAULT 'Message',
  `message` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `recipient` varchar(32) DEFAULT NULL,
  `sender` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

-----------------------------------------------------

Version 5.6, 6 December 2019 by Anturke
Added achievement_name and achievement_description columns to achievement_metadata table.

```sql
ALTER TABLE `achievement_metadata` ADD COLUMN (`achievement_name` VARCHAR(64) NULL DEFAULT NULL, `achievement_description` VARCHAR(512) NULL DEFAULT NULL);
```

-----------------------------------------------------

Version 5.5, 26 October 2019 by Anturke
Added achievement_metadata table.

```sql
DROP TABLE IF EXISTS `achievement_metadata`;
CREATE TABLE `achievement_metadata` (
	`achievement_key` VARCHAR(32) NOT NULL,
	`achievement_version` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`achievement_type` enum('achievement','score','award') NULL DEFAULT NULL,
	PRIMARY KEY (`achievement_key`)
) ENGINE=InnoDB;
```

-----------------------------------------------------

Version 5.4, 5 October 2019 by Anturke
Added achievements table.
See hub migration verb in _achievement_data.dm for details on migrating.

```sql
CREATE TABLE `achievements` (
	`ckey` VARCHAR(32) NOT NULL,
	`achievement_key` VARCHAR(32) NOT NULL,
	`value` INT NULL,
	`last_updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`ckey`,`achievement_key`)
) ENGINE=InnoDB;
```

----------------------------------------------------

Version 5.3, 6 July 2019, by Atlanta-Ned
Added a `feedback` column to the admin table, used for linking to individual admin feedback threads. Currently this is only used for statistics tracking tools such as Statbus and isn't used by the game.

```sql
ALTER TABLE `admin` ADD `feedback` VARCHAR(255) NULL DEFAULT NULL AFTER `rank`;
```

----------------------------------------------------

Version 5.2, 30 May 2019, by AffectedArc07
Added a field to the `player` table to track ckey and discord ID relationships

```sql
ALTER TABLE `player`
	ADD COLUMN `discord_id` BIGINT NULL DEFAULT NULL AFTER `flags`;
```
----------------------------------------------------

Version 5.1, 25 Feb 2018, by MrStonedOne
Added four tables to enable storing of stickybans in the database since byond can lose them, and to enable disabling stickybans for a round without depending on a crash free round. Existing stickybans are automagically imported to the tables.

```sql
CREATE TABLE `stickyban` (
	`ckey` VARCHAR(32) NOT NULL,
	`reason` VARCHAR(2048) NOT NULL,
	`banning_admin` VARCHAR(32) NOT NULL,
	`datetime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (`ckey`)
) ENGINE=InnoDB;

CREATE TABLE `stickyban_matched_ckey` (
	`stickyban` VARCHAR(32) NOT NULL,
	`matched_ckey` VARCHAR(32) NOT NULL,
	`first_matched` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`last_matched` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	`exempt` TINYINT(1) NOT NULL DEFAULT '0',
	PRIMARY KEY (`stickyban`, `matched_ckey`)
) ENGINE=InnoDB;

CREATE TABLE `stickyban_matched_ip` (
	`stickyban` VARCHAR(32) NOT NULL,
	`matched_ip` INT UNSIGNED NOT NULL,
	`first_matched` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`last_matched` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`stickyban`, `matched_ip`)
) ENGINE=InnoDB;

CREATE TABLE `stickyban_matched_cid` (
	`stickyban` VARCHAR(32) NOT NULL,
	`matched_cid` VARCHAR(32) NOT NULL,
	`first_matched` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`last_matched` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`stickyban`, `matched_cid`)
) ENGINE=InnoDB;
```

----------------------------------------------------

Version 5.0, 28 October 2018, by Jordie0608
Modified ban table to remove the need for the `bantype` column, a python script is used to migrate data to this new format.

See the file 'ban_conversion_2018-10-28.py' for instructions on how to use the script.

A new ban table can be created with the query:

```sql
CREATE TABLE `ban` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `bantime` DATETIME NOT NULL,
  `server_ip` INT(10) UNSIGNED NOT NULL,
  `server_port` SMALLINT(5) UNSIGNED NOT NULL,
  `round_id` INT(11) UNSIGNED NOT NULL,
  `role` VARCHAR(32) NULL DEFAULT NULL,
  `expiration_time` DATETIME NULL DEFAULT NULL,
  `applies_to_admins` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  `reason` VARCHAR(2048) NOT NULL,
  `ckey` VARCHAR(32) NULL DEFAULT NULL,
  `ip` INT(10) UNSIGNED NULL DEFAULT NULL,
  `computerid` VARCHAR(32) NULL DEFAULT NULL,
  `a_ckey` VARCHAR(32) NOT NULL,
  `a_ip` INT(10) UNSIGNED NOT NULL,
  `a_computerid` VARCHAR(32) NOT NULL,
  `who` VARCHAR(2048) NOT NULL,
  `adminwho` VARCHAR(2048) NOT NULL,
  `edits` TEXT NULL DEFAULT NULL,
  `unbanned_datetime` DATETIME NULL DEFAULT NULL,
  `unbanned_ckey` VARCHAR(32) NULL DEFAULT NULL,
  `unbanned_ip` INT(10) UNSIGNED NULL DEFAULT NULL,
  `unbanned_computerid` VARCHAR(32) NULL DEFAULT NULL,
  `unbanned_round_id` INT(11) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ban_isbanned` (`ckey`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_isbanned_details` (`ckey`,`ip`,`computerid`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_count` (`bantime`,`a_ckey`,`applies_to_admins`,`unbanned_datetime`,`expiration_time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

----------------------------------------------------

Version 4.7, 18 August 2018, by CitrusGender
Modified table `messages`, adding column `severity` to classify notes based on their severity.

ALTER TABLE `messages` ADD `severity` enum('high','medium','minor','none') DEFAULT NULL AFTER `expire_timestamp`

----------------------------------------------------

Version 4.6, 11 August 2018, by Jordie0608
Modified table `messages`, adding column `expire_timestamp` to allow for auto-"deleting" messages.

ALTER TABLE `messages` ADD `expire_timestamp` DATETIME NULL DEFAULT NULL AFTER `secret`;

----------------------------------------------------

Version 4.5, 9 July 2018, by Jordie0608
Modified table `player`, adding column `byond_key` to store a user's key along with their ckey.
To populate this new column run the included script 'populate_key_2018-07', see the file for use instructions.

ALTER TABLE `player` ADD `byond_key` VARCHAR(32) DEFAULT NULL AFTER `ckey`;

----------------------------------------------------

Version 4.4, 9 May 2018, by Jordie0608
Modified table `round`, renaming column `start_datetime` to `initialize_datetime` and `end_datetime` to `shutdown_datetime` and adding columns to replace both under the same name in preparation for changes to TGS server initialization.

ALTER TABLE `round`
	ALTER `start_datetime` DROP DEFAULT;
ALTER TABLE `round`
	CHANGE COLUMN `start_datetime` `initialize_datetime` DATETIME NOT NULL AFTER `id`,
	ADD COLUMN `start_datetime` DATETIME NULL DEFAULT NULL AFTER `initialize_datetime`,
	CHANGE COLUMN `end_datetime` `shutdown_datetime` DATETIME NULL DEFAULT NULL AFTER `start_datetime`,
	ADD COLUMN `end_datetime` DATETIME NULL DEFAULT NULL AFTER `shutdown_datetime`;

----------------------------------------------------

Version 4.3, 9 May 2018, by MrStonedOne
Added table `role_time_log` and triggers `role_timeTlogupdate`, `role_timeTloginsert` and `role_timeTlogdelete` to update it from changes to `role_time`

CREATE TABLE `role_time_log` ( `id` BIGINT NOT NULL AUTO_INCREMENT , `ckey` VARCHAR(32) NOT NULL , `job` VARCHAR(128) NOT NULL , `delta` INT NOT NULL , `datetime` TIMESTAMP on update CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP , PRIMARY KEY (`id`), INDEX (`ckey`), INDEX (`job`), INDEX (`datetime`)) ENGINE = InnoDB;

DELIMITER $$
CREATE TRIGGER `role_timeTlogupdate` AFTER UPDATE ON `role_time` FOR EACH ROW BEGIN INSERT into role_time_log (ckey, job, delta) VALUES (NEW.CKEY, NEW.job, NEW.minutes-OLD.minutes);
END
$$
CREATE TRIGGER `role_timeTloginsert` AFTER INSERT ON `role_time` FOR EACH ROW BEGIN INSERT into role_time_log (ckey, job, delta) VALUES (NEW.ckey, NEW.job, NEW.minutes);
END
$$
CREATE TRIGGER `role_timeTlogdelete` AFTER DELETE  ON `role_time` FOR EACH ROW BEGIN INSERT into role_time_log (ckey, job, delta) VALUES (OLD.ckey, OLD.job, 0-OLD.minutes);
END
$$
DELIMITER ;
----------------------------------------------------

Version 4.2, 17 April 2018, by Jordie0608
Modified table 'admin', adding the columns 'round_id' and 'target'
ALTER TABLE `admin_log`
	ADD COLUMN `round_id` INT UNSIGNED NOT NULL AFTER `datetime`,
	ADD COLUMN `target` VARCHAR(32) NOT NULL AFTER `operation`;

----------------------------------------------------

Version 4.1, 3 February 2018, by Jordie0608
Modified tables 'admin', 'admin_log' and 'admin_rank', removing unnecessary columns and adding support for excluding rights flags from admin ranks.
This change was made to enable use of sql-based admin loading.
To import your existing admins and ranks run the included script 'admin_import_2018-02-03.py', see the file for use instructions.
Legacy file-based admin loading is still supported, if you want to continue using it the script doesn't need to be run.

ALTER TABLE `admin`
	CHANGE COLUMN `rank` `rank` VARCHAR(32) NOT NULL AFTER `ckey`,
	DROP COLUMN `id`,
	DROP COLUMN `level`,
	DROP COLUMN `flags`,
	DROP COLUMN `email`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`ckey`);

ALTER TABLE `admin_log`
	CHANGE COLUMN `datetime` `datetime` DATETIME NOT NULL AFTER `id`,
	CHANGE COLUMN `adminckey` `adminckey` VARCHAR(32) NOT NULL AFTER `datetime`,
	CHANGE COLUMN `adminip` `adminip` INT(10) UNSIGNED NOT NULL AFTER `adminckey`,
	ADD COLUMN `operation` ENUM('add admin','remove admin','change admin rank','add rank','remove rank','change rank flags') NOT NULL AFTER `adminip`,
	CHANGE COLUMN `log` `log` VARCHAR(1000) NOT NULL AFTER `operation`;

ALTER TABLE `admin_ranks`
	CHANGE COLUMN `rank` `rank` VARCHAR(32) NOT NULL FIRST,
	CHANGE COLUMN `flags` `flags` SMALLINT UNSIGNED NOT NULL AFTER `rank`,
	ADD COLUMN `exclude_flags` SMALLINT UNSIGNED NOT NULL AFTER `flags`,
	ADD COLUMN `can_edit_flags` SMALLINT(5) UNSIGNED NOT NULL AFTER `exclude_flags`,
	DROP COLUMN `id`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`rank`);

----------------------------------------------------

Version 4.0, 12 November 2017, by Jordie0608
Modified feedback table to use json, a python script is used to migrate data to this new format.

See the file 'feedback_conversion_2017-11-12.py' for instructions on how to use the script.

A new json feedback table can be created with:
CREATE TABLE `feedback` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `key_name` varchar(32) NOT NULL,
  `key_type` enum('text', 'amount', 'tally', 'nested tally', 'associative') NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `json` json NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM

----------------------------------------------------

Version 3.4, 28 August 2017, by MrStonedOne
Modified table 'messages', adding a deleted column and editing all indexes to include it

ALTER TABLE `messages`
ADD COLUMN `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0' AFTER `edits`,
DROP INDEX `idx_msg_ckey_time`,
DROP INDEX `idx_msg_type_ckeys_time`,
DROP INDEX `idx_msg_type_ckey_time_odr`,
ADD INDEX `idx_msg_ckey_time` (`targetckey`,`timestamp`, `deleted`),
ADD INDEX `idx_msg_type_ckeys_time` (`type`,`targetckey`,`adminckey`,`timestamp`, `deleted`),
ADD INDEX `idx_msg_type_ckey_time_odr` (`type`,`targetckey`,`timestamp`, `deleted`);

----------------------------------------------------

Version 3.3, 25 August 2017, by Jordie0608

Modified tables 'connection_log', 'legacy_population', 'library', 'messages' and 'player' to add additional 'round_id' tracking in various forms and 'server_ip' and 'server_port' to the table 'messages'.

ALTER TABLE `connection_log` ADD COLUMN `round_id` INT(11) UNSIGNED NOT NULL AFTER `server_port`;
ALTER TABLE `legacy_population` ADD COLUMN `round_id` INT(11) UNSIGNED NOT NULL AFTER `server_port`;
ALTER TABLE `library` ADD COLUMN `round_id_created` INT(11) UNSIGNED NOT NULL AFTER `deleted`;
ALTER TABLE `messages` ADD COLUMN `server_ip` INT(10) UNSIGNED NOT NULL AFTER `server`, ADD COLUMN `server_port` SMALLINT(5) UNSIGNED NOT NULL AFTER `server_ip`, ADD COLUMN `round_id` INT(11) UNSIGNED NOT NULL AFTER `server_port`;
ALTER TABLE `player` ADD COLUMN `firstseen_round_id` INT(11) UNSIGNED NOT NULL AFTER `firstseen`, ADD COLUMN `lastseen_round_id` INT(11) UNSIGNED NOT NULL AFTER `lastseen`;

----------------------------------------------------

Version 3.2, 18 August 2017, by Cyberboss and nfreader

Modified table 'death', adding the columns `last_words` and 'suicide'.

ALTER TABLE `death`
ADD COLUMN `last_words` varchar(255) DEFAULT NULL AFTER `staminaloss`,
ADD COLUMN `suicide` tinyint(0) NOT NULL DEFAULT '0' AFTER `last_words`;

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

Version 3.1, 20th July 2017, by Shadowlight213
Added role_time table to track time spent playing departments.
Also, added flags column to the player table.

CREATE TABLE `role_time` ( `ckey` VARCHAR(32) NOT NULL , `job` VARCHAR(128) NOT NULL , `minutes` INT UNSIGNED NOT NULL, PRIMARY KEY (`ckey`, `job`) ) ENGINE = InnoDB;

ALTER TABLE `player` ADD `flags` INT NOT NULL default '0' AFTER `accountjoindate`;

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

Version 3.0, 28 June 2017, by oranges
Added schema_revision to store the current db revision, why start at 3.0?

because:
15:09 <+MrStonedOne> 1.0 was erro, 2.0 was when i removed erro_, 3.0 was when jordie made all the strings that hold numbers numbers

CREATE TABLE `schema_revision` (
`major` TINYINT(3) UNSIGNED NOT NULL ,
`minor` TINYINT(3) UNSIGNED NOT NULL ,
`date` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
PRIMARY KEY ( `major`,`minor` )
) ENGINE = INNODB;

INSERT INTO `schema_revision` (`major`, `minor`) VALUES (3, 0);

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

26 June 2017, by Jordie0608

Modified table 'poll_option', adding the column 'default_percentage_calc'.

ALTER TABLE `poll_option` ADD COLUMN `default_percentage_calc` TINYINT(1) UNSIGNED NOT NULL DEFAULT '1' AFTER `descmax`

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

22 June 2017, by Jordie0608

Modified table 'poll_option', removing the column 'percentagecalc'.

ALTER TABLE `poll_option` DROP COLUMN `percentagecalc`

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

8 June 2017, by Jordie0608

Modified table 'death', adding column 'round_id', removing column 'gender' and replacing column 'coord' with the columns 'x_coord', 'y_coord' and 'z_coord'.

START TRANSACTION;
ALTER TABLE `death` DROP COLUMN `gender`, ADD COLUMN `x_coord` SMALLINT(5) UNSIGNED NOT NULL AFTER `coord`, ADD COLUMN `y_coord` SMALLINT(5) UNSIGNED NOT NULL AFTER `x_coord`, ADD COLUMN `z_coord` SMALLINT(5) UNSIGNED NOT NULL AFTER `y_coord`, ADD COLUMN `round_id` INT(11) NOT NULL AFTER `server_port`;
SET SQL_SAFE_UPDATES = 0;
UPDATE `death` SET `x_coord` = SUBSTRING_INDEX(`coord`, ',', 1), `y_coord` = SUBSTRING_INDEX(SUBSTRING_INDEX(`coord`, ',', 2), ',', -1), `z_coord` = SUBSTRING_INDEX(`coord`, ',', -1);
SET SQL_SAFE_UPDATES = 1;
ALTER TABLE `death` DROP COLUMN `coord`;
COMMIT;

Remember to add a prefix to the table name if you use them.

---------------------------------------------------

30 May 2017, by MrStonedOne

Z levels changed, this query allows you to convert old ss13 death records:

UPDATE death SET coord = CONCAT(SUBSTRING_INDEX(coord, ',', 2), ', ', CASE TRIM(SUBSTRING_INDEX(coord, ',', -1)) WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE TRIMSUBSTRING_INDEX(coord, ',', -1) END)

---------------------------------------------------

26 May 2017, by Jordie0608

Modified table 'ban', adding the column 'round_id'.

ALTER TABLE `ban` ADD COLUMN `round_id` INT(11) NOT NULL AFTER `server_port`

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

20 May 2017, by Jordie0608

Created table `round` to replace tracking of the datapoints 'round_start', 'round_end', 'server_ip', 'game_mode', 'round_end_results', 'end_error', 'end_proper', 'emergency_shuttle', 'map_name' and 'station_renames' in the `feedback` table.
Once created this table is populated with rows from the `feedback` table.

START TRANSACTION;
CREATE TABLE `round` (`id` INT(11) NOT NULL AUTO_INCREMENT, `start_datetime` DATETIME NOT NULL, `end_datetime` DATETIME NULL, `server_ip` INT(10) UNSIGNED NOT NULL, `server_port` SMALLINT(5) UNSIGNED NOT NULL, `commit_hash` CHAR(40) NULL, `game_mode` VARCHAR(32) NULL, `game_mode_result` VARCHAR(64) NULL, `end_state` VARCHAR(64) NULL, `shuttle_name` VARCHAR(64) NULL, `map_name` VARCHAR(32) NULL, `station_name` VARCHAR(80) NULL, PRIMARY KEY (`id`));
ALTER TABLE `feedback` ADD INDEX `tmp` (`round_id` ASC, `var_name` ASC);
INSERT INTO `round`
(`id`, `start_datetime`, `end_datetime`, `server_ip`, `server_port`, `commit_hash`, `game_mode`, `game_mode_result`, `end_state`, `shuttle_name`, `map_name`, `station_name`)
SELECT DISTINCT ri.round_id, IFNULL(STR_TO_DATE(st.details,'%a %b %e %H:%i:%s %Y'), TIMESTAMP(0)), STR_TO_DATE(et.details,'%a %b %e %H:%i:%s %Y'), IFNULL(INET_ATON(SUBSTRING_INDEX(IF(si.details = '', '0', IF(SUBSTRING_INDEX(si.details, ':', 1) LIKE '%_._%', si.details, '0')), ':', 1)), INET_ATON(0)), IFNULL(IF(si.details LIKE '%:_%', CAST(SUBSTRING_INDEX(si.details, ':', -1) AS UNSIGNED), '0'), '0'), ch.details, gm.details, mr.details, IFNULL(es.details, ep.details), ss.details, mn.details, sn.details
FROM `feedback`AS ri
LEFT JOIN `feedback` AS st ON ri.round_id = st.round_id AND st.var_name = "round_start" LEFT JOIN `feedback` AS et ON ri.round_id = et.round_id AND et.var_name = "round_end" LEFT JOIN `feedback` AS si ON ri.round_id = si.round_id AND si.var_name = "server_ip" LEFT JOIN `feedback` AS ch ON ri.round_id = ch.round_id AND ch.var_name = "revision" LEFT JOIN `feedback` AS gm ON ri.round_id = gm.round_id AND gm.var_name = "game_mode" LEFT JOIN `feedback` AS mr ON ri.round_id = mr.round_id AND mr.var_name = "round_end_result" LEFT JOIN `feedback` AS es ON ri.round_id = es.round_id AND es.var_name = "end_state" LEFT JOIN `feedback` AS ep ON ri.round_id = ep.round_id AND ep.var_name = "end_proper" LEFT JOIN `feedback` AS ss ON ri.round_id = ss.round_id AND ss.var_name = "emergency_shuttle" LEFT JOIN `feedback` AS mn ON ri.round_id = mn.round_id AND mn.var_name = "map_name" LEFT JOIN `feedback` AS sn ON ri.round_id = sn.round_id AND sn.var_name = "station_renames";
ALTER TABLE `feedback` DROP INDEX `tmp`;
COMMIT;

It's not necessary to delete the rows from the `feedback` table but henceforth these datapoints will be in the `round` table.

Remember to add a prefix to the table names if you use them

----------------------------------------------------

21 April 2017, by Jordie0608

Modified table 'player', adding the column 'accountjoindate', removing the column 'id' and making the column 'ckey' the primary key.

ALTER TABLE `player` DROP COLUMN `id`, ADD COLUMN `accountjoindate` DATE NULL AFTER `lastadminrank`, DROP PRIMARY KEY, ADD PRIMARY KEY (`ckey`), DROP INDEX `ckey`;

Remember to add a prefix to the table name if you use them.

----------------------------------------------------
10 March 2017, by Jordie0608

Modified table 'death', adding the columns 'toxloss', 'cloneloss', and 'staminaloss' and table 'legacy_population', adding the columns 'server_ip' and 'server_port'.

ALTER TABLE `death` ADD COLUMN `toxloss` SMALLINT(5) UNSIGNED NOT NULL AFTER `oxyloss`, ADD COLUMN `cloneloss` SMALLINT(5) UNSIGNED NOT NULL AFTER `toxloss`, ADD COLUMN `staminaloss` SMALLINT(5) UNSIGNED NOT NULL AFTER `cloneloss`;

ALTER TABLE `legacy_population` ADD COLUMN `server_ip` INT(10) UNSIGNED NOT NULL AFTER `time`, ADD COLUMN `server_port` SMALLINT(5) UNSIGNED NOT NULL AFTER `server_ip`;

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

19 February 2017, by Jordie0608

Optimised and indexed significant portions of the schema.

See the file 'optimisations_2017-02-19.sql' for instructions on how to apply these changes to your database.

Remember to add a prefix to the table name if you use them

----------------------------------------------------

30 January 2017, by Lzimann

Modified table 'death', adding the columns 'mapname' and 'server'.

ALTER TABLE `death` ADD COLUMN `mapname` TEXT NOT NULL AFTER `coord`, ADD COLUMN `server` TEXT NOT NULL AFTER `mapname`

Remember to add a prefix to the table name if you use them

----------------------------------------------------

25 January 2017, by Jordie0608

Created table 'messages' to supersede the 'notes', 'memos', and 'watchlist' tables; they must be collated into this new table

To create this new table run the following command:

CREATE  TABLE `messages` (`id` INT(11) NOT NULL AUTO_INCREMENT , `type` VARCHAR(32) NOT NULL , `targetckey` VARCHAR(32) NOT NULL , `adminckey` VARCHAR(32) NOT NULL , `text` TEXT NOT NULL , `timestamp` DATETIME NOT NULL , `server` VARCHAR(32) NULL , `secret` TINYINT(1) NULL DEFAULT 1 , `lasteditor` VARCHAR(32) NULL , `edits` TEXT NULL , PRIMARY KEY (`id`) )

To copy the contents of the 'notes', 'memos', and 'watchlist' tables to this new table run the following commands:

INSERT INTO `messages`
(`id`,`type`,`targetckey`,`adminckey`,`text`,`timestamp`,`server`,`secret`,`lasteditor`,`edits`) SELECT `id`, "note", `ckey`, `adminckey`, `notetext`, `timestamp`, `server`, `secret`, `last_editor`, `edits` FROM `notes`

INSERT INTO `messages`
(`type`,`targetckey`,`adminckey`,`text`,`timestamp`,`lasteditor`,`edits`) SELECT "memo", `ckey`, `ckey`, `memotext`, `timestamp`, `last_editor`, `edits` FROM `memo`

INSERT INTO `messages`
(`type`,`targetckey`,`adminckey`,`text`,`timestamp`,`lasteditor`,`edits`) SELECT "watchlist entry", `ckey`, `adminckey`, `reason`, `timestamp`, `last_editor`, `edits` FROM `watch`

It's not necessary to delete the 'notes', 'memos', and 'watchlist' tables but they will no longer be used.

Remember to add a prefix to the table names if you use them

----------------------------------------------------

1 September 2016, by Jordie0608

Modified table 'notes', adding column 'secret'.

ALTER TABLE `notes` ADD COLUMN `secret` TINYINT(1) NOT NULL DEFAULT '1'  AFTER `server`

Remember to add a prefix to the table name if you use them

----------------------------------------------------

19 August 2016, by Shadowlight213

Changed appearance bans to be jobbans.

UPDATE `ban` SET `job` = "appearance", `bantype` = "JOB_PERMABAN" WHERE `bantype` = "APPEARANCE_PERMABAN"

Remember to add a prefix to the table name if you use them

----------------------------------------------------

3 July 2016, by Jordie0608

Modified table 'poll_question', adding column 'dontshow' which was recently added to the server schema.

ALTER TABLE `poll_question` ADD COLUMN `dontshow` TINYINT(1) NOT NULL DEFAULT '0'  AFTER `for_trialmin`

Remember to add a prefix to the table name if you use them

----------------------------------------------------

16th April 2016

Added ipintel table, only required if ip intel is enabled in the config

CREATE TABLE `ipintel` (
`ip` INT UNSIGNED NOT NULL ,
`date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL ,
`intel` REAL NOT NULL DEFAULT  '0',
PRIMARY KEY (  `ip` )
) ENGINE = INNODB;

---------------------------------------------------

21 September 2015, by Jordie0608

Modified table 'poll_question', adding columns 'createdby_ckey', 'createdby_ip' and 'for_trialmin' to bring it inline with the schema used by the tg servers.

ALTER TABLE `poll_question` ADD COLUMN `createdby_ckey` VARCHAR(45) NULL DEFAULT NULL AFTER `multiplechoiceoptions`, ADD COLUMN `createdby_ip` VARCHAR(45) NULL DEFAULT NULL AFTER `createdby_ckey`, ADD COLUMN `for_trialmin` VARCHAR(45) NULL DEFAULT NULL AFTER `createdby_ip`

Remember to add a prefix to the table name if you use them

----------------------------------------------------

27 August 2015, by Jordie0608

Modified table 'watch', removing 'id' column, making 'ckey' primary and adding the columns 'timestamp', 'adminckey', 'last_editor' and 'edits'.

ALTER TABLE `watch` DROP COLUMN `id`, ADD COLUMN `timestamp` datetime NOT NULL AFTER `reason`, ADD COLUMN `adminckey` varchar(32) NOT NULL AFTER `timestamp`, ADD COLUMN `last_editor` varchar(32) NULL AFTER `adminckey`, ADD COLUMN `edits` text NULL AFTER `last_editor`, DROP PRIMARY KEY, ADD PRIMARY KEY (`ckey`)

Remember to add a prefix to the table name if you use them.

----------------------------------------------------

14 August 2015, by Jordie0608

Added new table 'notes' to replace BYOND's .sav note system.

To create this new table run the following command:

CREATE TABLE `notes` ( `id` int(11) NOT NULL AUTO_INCREMENT, `ckey` varchar(32) NOT NULL, `notetext` text NOT NULL, `timestamp` datetime NOT NULL, `adminckey` varchar(32) NOT NULL, `last_editor` varchar(32), `edits` text, `server` varchar(50) NOT NULL, PRIMARY KEY (`id`))

Remember to add prefix to the table name if you use them.

----------------------------------------------------

28 July 2015, by Jordie0608

Modified table 'memo', removing 'id' column and making 'ckey' primary.

ALTER TABLE `memo` DROP COLUMN `id`, DROP PRIMARY KEY, ADD PRIMARY KEY (`ckey`)

Remember to add prefix to the table name if you use them.

----------------------------------------------------

19 July 2015, by Jordie0608

Added new table 'memo' for use with admin memos.

To create this new table run the following command:

CREATE TABLE `memo` (`id` int(11) NOT NULL AUTO_INCREMENT, `ckey` varchar(32) NOT NULL, `memotext` text NOT NULL, `timestamp` datetime NOT NULL, `last_editor` varchar(32), `edits` text, PRIMARY KEY (`id`))

Remember to add prefix to the table name if you use them.

----------------------------------------------------

7 July 2015, by MrStonedOne

Removed the privacy poll and related table. Existing codebases may safely delete the privacy table after updating:

DROP TABLE `privacy`;

--------------------------------------------------

19 May 2015, by Jordie0608

Added new table 'watch' for use in flagging ckeys. It shouldn't ever exist, but also added command to de-erroize this new table just in case someone does make it like that.

To create this new table run the following command:

CREATE TABLE `watch` (`id` int(11) NOT NULL AUTO_INCREMENT, `ckey` varchar(32) NOT NULL, `reason` text NOT NULL, PRIMARY KEY (`id`))

Remember to add prefix to the table name if you use them.

----------------------------------------------------

19 September 2014, by MrStonedOne

Removed erro_ from table names. dbconfig.txt has a option allowing you to change the prefix used in code, defaults to "erro_" if left out for legacy reasons.

If you are creating a new database and want to change the prefix, simply find and replace SS13_ to what ever you want (including nothing) and set the prefix value

Two schema files are now included, one with prefixes and one without.

If you have an existing database, and you want to rid your database of erros, you will have to rename all of the tables. A bit sql is included to do just that in errofreedatabase.sql Feel free to find and replace the prefix to what ever you want (or nothing)

----------------------------------------------------

4 November 2013, by Errorage

The column 'deleted' was added to the erro_library table. If set to anything other than null, the book is interpreted as deleted.

To update your database, execute the following code in phpmyadmin, mysql workbench or whatever program you use:

ALTER TABLE erro_library ADD COLUMN deleted TINYINT(1) NULL DEFAULT NULL  AFTER datetime;

If you want to 'soft delete' a book (meaning it remains in the library, but isn't viewable by players), set the value in the 'deleted' column for the row to 1. To undelete, set it back to null. If you're making an admin tool to work with this, execute the following SQL statement to soft-delete the book with id someid:

UPDATE erro_library SET deleted = 1 WHERE id = someid

(Replace someid with the id of the book you want to soft delete.)

----------------------------------------------------
