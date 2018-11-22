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
