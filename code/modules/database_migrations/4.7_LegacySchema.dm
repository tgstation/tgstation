/datum/database_migration/LegacySchema
	schema_version_major = 4
	schema_version_minor = 7

/datum/database_migration/LegacySchema/Up()
	//original v4.7 schema creation scripts here: https://github.com/tgstation/tgstation/tree/f28cd100991f4a35c8028b63aa1b40f3c2393cff/SQL
	M("{
		CREATE TABLE `[format_table_name("admin")]` (
			`ckey` varchar(32) NOT NULL,
			`rank` varchar(32) NOT NULL,
			PRIMARY KEY (`ckey`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	")
	M({"
		CREATE TABLE `[format_table_name("admin_log")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`datetime` datetime NOT NULL,
			`round_id` int(11) unsigned NOT NULL,
			`adminckey` varchar(32) NOT NULL,
			`adminip` int(10) unsigned NOT NULL,
			`operation` enum('add admin','remove admin','change admin rank','add rank','remove rank','change rank flags') NOT NULL,
			`target` varchar(32) NOT NULL,
			`log` varchar(1000) NOT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1"
	"})
	M({"
		CREATE TABLE `[format_table_name("admin_ranks")]` (
			`rank` varchar(32) NOT NULL,
			`flags` smallint(5) unsigned NOT NULL,
			`exclude_flags` smallint(5) unsigned NOT NULL,
			`can_edit_flags` smallint(5) unsigned NOT NULL,
			PRIMARY KEY (`rank`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("ban")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`bantime` datetime NOT NULL,
			`server_ip` int(10) unsigned NOT NULL,
			`server_port` smallint(5) unsigned NOT NULL,
			`round_id` int(11) NOT NULL,
			`bantype` enum('PERMABAN','TEMPBAN','JOB_PERMABAN','JOB_TEMPBAN','ADMIN_PERMABAN','ADMIN_TEMPBAN') NOT NULL,
			`reason` varchar(2048) NOT NULL,
			`job` varchar(32) DEFAULT NULL,
			`duration` int(11) NOT NULL,
			`expiration_time` datetime NOT NULL,
			`ckey` varchar(32) NOT NULL,
			`computerid` varchar(32) NOT NULL,
			`ip` int(10) unsigned NOT NULL,
			`a_ckey` varchar(32) NOT NULL,
			`a_computerid` varchar(32) NOT NULL,
			`a_ip` int(10) unsigned NOT NULL,
			`who` varchar(2048) NOT NULL,
			`adminwho` varchar(2048) NOT NULL,
			`edits` text,
			`unbanned` tinyint(3) unsigned DEFAULT NULL,
			`unbanned_datetime` datetime DEFAULT NULL,
			`unbanned_ckey` varchar(32) DEFAULT NULL,
			`unbanned_computerid` varchar(32) DEFAULT NULL,
			`unbanned_ip` int(10) unsigned DEFAULT NULL,
			PRIMARY KEY (`id`),
			KEY `idx_ban_checkban` (`ckey`,`bantype`,`expiration_time`,`unbanned`,`job`),
			KEY `idx_ban_isbanned` (`ckey`,`ip`,`computerid`,`bantype`,`expiration_time`,`unbanned`),
			KEY `idx_ban_count` (`id`,`a_ckey`,`bantype`,`expiration_time`,`unbanned`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("connection_log")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`datetime` datetime DEFAULT NULL,
			`server_ip` int(10) unsigned NOT NULL,
			`server_port` smallint(5) unsigned NOT NULL,
			`round_id` int(11) unsigned NOT NULL,
			`ckey` varchar(45) DEFAULT NULL,
			`ip` int(10) unsigned NOT NULL,
			`computerid` varchar(45) DEFAULT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("death")]` (
  			`id` int(11) NOT NULL AUTO_INCREMENT,
			`pod` varchar(50) NOT NULL,
			`x_coord` smallint(5) unsigned NOT NULL,
			`y_coord` smallint(5) unsigned NOT NULL,
			`z_coord` smallint(5) unsigned NOT NULL,
			`mapname` varchar(32) NOT NULL,
			`server_ip` int(10) unsigned NOT NULL,
			`server_port` smallint(5) unsigned NOT NULL,
			`round_id` int(11) NOT NULL,
			`tod` datetime NOT NULL COMMENT 'Time of death',
			`job` varchar(32) NOT NULL,
			`special` varchar(32) DEFAULT NULL,
			`name` varchar(96) NOT NULL,
			`byondkey` varchar(32) NOT NULL,
			`laname` varchar(96) DEFAULT NULL,
			`lakey` varchar(32) DEFAULT NULL,
			`bruteloss` smallint(5) unsigned NOT NULL,
			`brainloss` smallint(5) unsigned NOT NULL,
			`fireloss` smallint(5) unsigned NOT NULL,
			`oxyloss` smallint(5) unsigned NOT NULL,
			`toxloss` smallint(5) unsigned NOT NULL,
			`cloneloss` smallint(5) unsigned NOT NULL,
			`staminaloss` smallint(5) unsigned NOT NULL,
			`last_words` varchar(255) DEFAULT NULL,
			`suicide` tinyint(1) NOT NULL DEFAULT '0',
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("feedback")]` (
			`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
			`datetime` datetime NOT NULL,
			`round_id` int(11) unsigned NOT NULL,
			`key_name` varchar(32) NOT NULL,
			`key_type` enum('text', 'amount', 'tally', 'nested tally', 'associative') NOT NULL,
			`version` tinyint(3) unsigned NOT NULL,
			`json` json NOT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=MyISAM DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("ipintel")]` (
			`ip` int(10) unsigned NOT NULL,
			`date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			`intel` double NOT NULL DEFAULT '0',
			PRIMARY KEY (`ip`),
			KEY `idx_ipintel` (`ip`,`intel`,`date`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("legacy_population")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`playercount` int(11) DEFAULT NULL,
			`admincount` int(11) DEFAULT NULL,
			`time` datetime NOT NULL,
			`server_ip` int(10) unsigned NOT NULL,
			`server_port` smallint(5) unsigned NOT NULL,
			`round_id` int(11) unsigned NOT NULL,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("library")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`author` varchar(45) NOT NULL,
			`title` varchar(45) NOT NULL,
			`content` text NOT NULL,
			`category` enum('Any','Fiction','Non-Fiction','Adult','Reference','Religion') NOT NULL,
			`ckey` varchar(32) NOT NULL DEFAULT 'LEGACY',
			`datetime` datetime NOT NULL,
			`deleted` tinyint(1) unsigned DEFAULT NULL,
			`round_id_created` int(11) unsigned NOT NULL,
			PRIMARY KEY (`id`),
			KEY `deleted_idx` (`deleted`),
			KEY `idx_lib_id_del` (`id`,`deleted`),
			KEY `idx_lib_del_title` (`deleted`,`title`),
			KEY `idx_lib_search` (`deleted`,`author`,`title`,`category`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("messages")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`type` enum('memo','message','message sent','note','watchlist entry') NOT NULL,
			`targetckey` varchar(32) NOT NULL,
			`adminckey` varchar(32) NOT NULL,
			`text` varchar(2048) NOT NULL,
			`timestamp` datetime NOT NULL,
			`server` varchar(32) DEFAULT NULL,
			`server_ip` int(10) unsigned NOT NULL,
			`server_port` smallint(5) unsigned NOT NULL,
			`round_id` int(11) unsigned NOT NULL,
			`secret` tinyint(1) unsigned NOT NULL,
			`expire_timestamp` datetime DEFAULT NULL,
			`severity` enum('high','medium','minor','none') DEFAULT NULL,
			`lasteditor` varchar(32) DEFAULT NULL,
			`edits` text,
			`deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
			PRIMARY KEY (`id`),
			KEY `idx_msg_ckey_time` (`targetckey`,`timestamp`, `deleted`),
			KEY `idx_msg_type_ckeys_time` (`type`,`targetckey`,`adminckey`,`timestamp`, `deleted`),
			KEY `idx_msg_type_ckey_time_odr` (`type`,`targetckey`,`timestamp`, `deleted`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("role_time")]` (
			`ckey` VARCHAR(32) NOT NULL ,
			`job` VARCHAR(32) NOT NULL ,
			`minutes` INT UNSIGNED NOT NULL,
			PRIMARY KEY (`ckey`, `job`)
		) ENGINE = InnoDB
	"})
	M({"
		CREATE TABLE `[format_table_name("role_time_log")]` (
			`id` bigint(20) NOT NULL AUTO_INCREMENT,
			`ckey` varchar(32) NOT NULL,
			`job` varchar(128) NOT NULL,
			`delta` int(11) NOT NULL,
			`datetime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
			PRIMARY KEY (`id`),
			KEY `ckey` (`ckey`),
			KEY `job` (`job`),
			KEY `datetime` (`datetime`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("player")]` (
			`ckey` varchar(32) NOT NULL,
			`byond_key` varchar(32) DEFAULT NULL,
			`firstseen` datetime NOT NULL,
			`firstseen_round_id` int(11) unsigned NOT NULL,
			`lastseen` datetime NOT NULL,
			`lastseen_round_id` int(11) unsigned NOT NULL,
			`ip` int(10) unsigned NOT NULL,
			`computerid` varchar(32) NOT NULL,
			`lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
			`accountjoindate` DATE DEFAULT NULL,
			`flags` smallint(5) unsigned DEFAULT '0' NOT NULL,
			PRIMARY KEY (`ckey`),
			KEY `idx_player_cid_ckey` (`computerid`,`ckey`),
			KEY `idx_player_ip_ckey` (`ip`,`ckey`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("poll_option")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`pollid` int(11) NOT NULL,
			`text` varchar(255) NOT NULL,
			`minval` int(3) DEFAULT NULL,
			`maxval` int(3) DEFAULT NULL,
			`descmin` varchar(32) DEFAULT NULL,
			`descmid` varchar(32) DEFAULT NULL,
			`descmax` varchar(32) DEFAULT NULL,
			`default_percentage_calc` tinyint(1) unsigned NOT NULL DEFAULT '1',
			PRIMARY KEY (`id`),
			KEY `idx_pop_pollid` (`pollid`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("poll_question")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`polltype` enum('OPTION','TEXT','NUMVAL','MULTICHOICE','IRV') NOT NULL,
			`starttime` datetime NOT NULL,
			`endtime` datetime NOT NULL,
			`question` varchar(255) NOT NULL,
			`adminonly` tinyint(1) unsigned NOT NULL,
			`multiplechoiceoptions` int(2) DEFAULT NULL,
			`createdby_ckey` varchar(32) DEFAULT NULL,
			`createdby_ip` int(10) unsigned NOT NULL,
			`dontshow` tinyint(1) unsigned NOT NULL,
			PRIMARY KEY (`id`),
			KEY `idx_pquest_question_time_ckey` (`question`,`starttime`,`endtime`,`createdby_ckey`,`createdby_ip`),
			KEY `idx_pquest_time_admin` (`starttime`,`endtime`,`adminonly`),
			KEY `idx_pquest_id_time_type_admin` (`id`,`starttime`,`endtime`,`polltype`,`adminonly`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("poll_textreply")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`datetime` datetime NOT NULL,
			`pollid` int(11) NOT NULL,
			`ckey` varchar(32) NOT NULL,
			`ip` int(10) unsigned NOT NULL,
			`replytext` varchar(2048) NOT NULL,
			`adminrank` varchar(32) NOT NULL DEFAULT 'Player',
			PRIMARY KEY (`id`),
			KEY `idx_ptext_pollid_ckey` (`pollid`,`ckey`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("poll_vote")]` (
			`id` int(11) NOT NULL AUTO_INCREMENT,
			`datetime` datetime NOT NULL,
			`pollid` int(11) NOT NULL,
			`optionid` int(11) NOT NULL,
			`ckey` varchar(32) NOT NULL,
			`ip` int(10) unsigned NOT NULL,
			`adminrank` varchar(32) NOT NULL,
			`rating` int(2) DEFAULT NULL,
			PRIMARY KEY (`id`),
			KEY `idx_pvote_pollid_ckey` (`pollid`,`ckey`),
			KEY `idx_pvote_optionid_ckey` (`optionid`,`ckey`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("round")]` (
			`id` INT(11) NOT NULL AUTO_INCREMENT,
			`initialize_datetime` DATETIME NOT NULL,
			`start_datetime` DATETIME NULL,
			`shutdown_datetime` DATETIME NULL,
			`end_datetime` DATETIME NULL,
			`server_ip` INT(10) UNSIGNED NOT NULL,
			`server_port` SMALLINT(5) UNSIGNED NOT NULL,
			`commit_hash` CHAR(40) NULL,
			`game_mode` VARCHAR(32) NULL,
			`game_mode_result` VARCHAR(64) NULL,
			`end_state` VARCHAR(64) NULL,
			`shuttle_name` VARCHAR(64) NULL,
			`map_name` VARCHAR(32) NULL,
			`station_name` VARCHAR(80) NULL,
			PRIMARY KEY (`id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M({"
		CREATE TABLE `[format_table_name("schema_revision")]` (
			`major` TINYINT(3) unsigned NOT NULL,
			`minor` TINYINT(3) unsigned NOT NULL,
			`date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			PRIMARY KEY (`major`, `minor`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1
	"})
	M("CREATE TRIGGER `role_timeTlogupdate` AFTER UPDATE ON `role_time` FOR EACH ROW BEGIN INSERT into role_time_log (ckey, job, delta) VALUES (NEW.CKEY, NEW.job, NEW.minutes-OLD.minutes);END")
	M("CREATE TRIGGER `role_timeTloginsert` AFTER INSERT ON `role_time` FOR EACH ROW BEGIN INSERT into role_time_log (ckey, job, delta) VALUES (NEW.ckey, NEW.job, NEW.minutes);END")
	M("CREATE TRIGGER `role_timeTlogdelete` AFTER DELETE ON `role_time` FOR EACH ROW BEGIN INSERT into role_time_log (ckey, job, delta) VALUES (OLD.ckey, OLD.job, 0-OLD.minutes);END")

/datum/database_migration/LegacySchema/Down()
	M("DROP TRIGGER IF EXISTS role_timeTlogupdate")
	M("DROP TRIGGER IF EXISTS role_timeTloginsert")
	M("DROP TRIGGER IF EXISTS role_timeTlogdelete")
	M("DROP TABLE IF EXISTS `[format_table_name("admin")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("admin_log")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("admin_ranks")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("ban")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("connection_log")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("death")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("feedback")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("ipintel")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("legacy_population")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("library")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("messages")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("role_time")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("role_time_log")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("player")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("poll_option")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("poll_question")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("poll_textreply")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("poll_vote")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("round")]`")
	M("DROP TABLE IF EXISTS `[format_table_name("schema_revision")]`")
