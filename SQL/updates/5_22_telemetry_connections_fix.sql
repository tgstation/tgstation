-- Version 5.22, 22 December 2021, by Mothblocks
-- Fixes a bug in `telemetry_connections` that limited the range of IPs.

ALTER TABLE `telemetry_connections` MODIFY COLUMN `address` INT(10) UNSIGNED NOT NULL;
