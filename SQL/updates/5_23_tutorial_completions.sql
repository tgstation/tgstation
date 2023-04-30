-- Version 5.23, 28 December 2022, by Mothblocks
-- Added `tutorial_completions` to mark what ckeys have completed contextual tutorials.

CREATE TABLE `tutorial_completions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ckey` VARCHAR(32) NOT NULL,
  `tutorial_key` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `ckey_tutorial_unique` (`ckey`, `tutorial_key`));
