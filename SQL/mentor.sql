CREATE TABLE `mentor_memo` (
  `ckey` varchar(32) NOT NULL,
  `memotext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mentor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;