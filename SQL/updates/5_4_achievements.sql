-- Version 5.4, 5 October 2019 by Anturke
-- Added achievements table.
-- See hub migration verb in _achievement_data.dm for details on migrating.

CREATE TABLE `achievements` (
	`ckey` VARCHAR(32) NOT NULL,
	`achievement_key` VARCHAR(32) NOT NULL,
	`value` INT NULL,
	`last_updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`ckey`,`achievement_key`)
) ENGINE=InnoDB;
