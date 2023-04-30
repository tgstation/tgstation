-- Version 5.21, 15 December 2021, by Mothblocks
-- Adds `telemetry_connections` table for tracking tgui telemetry.

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
