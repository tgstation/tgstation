-- Version 5.18, 1 November 2021, by Mothblocks
-- Added `known_alts` table for tracking who not to create suspicious logins for.

CREATE TABLE `known_alts` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `ckey1` VARCHAR(32) NOT NULL,
    `ckey2` VARCHAR(32) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `unique_contraints` (`ckey1` , `ckey2`)
);
