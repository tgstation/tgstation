CREATE TABLE IF NOT EXISTS `erro_admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL DEFAULT 'Administrator',
  `flags` int(16) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` varchar(18) NOT NULL,
  `log` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_admin_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rank` varchar(40) NOT NULL,
  `flags` int(16) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) NOT NULL,
  `bantype` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `rounds` int(11) DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `who` text NOT NULL,
  `adminwho` text NOT NULL,
  `edits` text,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `a_ckey` (`a_ckey`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `round_id` int(8) NOT NULL,
  `var_name` varchar(32) NOT NULL,
  `var_value` int(16) DEFAULT NULL,
  `details` text,
  PRIMARY KEY (`id`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(45) NOT NULL,
  `title` varchar(45) NOT NULL,
  `content` text NOT NULL,
  `category` varchar(45) NOT NULL,
  `ckey` varchar(45) DEFAULT 'LEGACY',
  `datetime` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_memo` (
  `ckey` varchar(32) NOT NULL,
  `memotext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=Aria DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `notetext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  `server` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=Aria  DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `erro_watch` (
  `ckey` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=Aria DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `medals` (
  `ckey` varchar(255) NOT NULL,
  `medal` text NOT NULL,
  `medaldesc` text NOT NULL,
  `medaldiff` text NOT NULL,
  UNIQUE KEY `NODUPES` (`ckey`,`medal`(8))
) ENGINE=Aria DEFAULT CHARSET=utf8;