-- Version 5.15, 2 June 2021, by Mothblocks
-- Added verified admin connection log used for 2FA

DROP TABLE IF EXISTS `admin_connections`;
CREATE TABLE `admin_connections` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ckey` VARCHAR(32) NOT NULL,
  `ip` INT(11) UNSIGNED NOT NULL,
  `cid` VARCHAR(32) NOT NULL,
  `verification_time` DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `unique_constraints` (`ckey`, `ip`, `cid`));
