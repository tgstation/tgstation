-- Version 5.17, 8 October 2021, by MrStonedOne + Mothblocks
-- Changes any table that requrired a NOT NULL round ID to now accept NULL. In the BSQL past, these were handled as 0, but in the move to rust-g this behavior was lost.

ALTER TABLE `admin_log` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `ban` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `citation` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `connection_log` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `death` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `feedback` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `legacy_population` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `library` CHANGE `round_id_created` `round_id_created` INT(11) UNSIGNED NULL;
ALTER TABLE `messages` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `player` CHANGE `firstseen_round_id` `firstseen_round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `player` CHANGE `lastseen_round_id` `lastseen_round_id` INT(11) UNSIGNED NULL;
ALTER TABLE `ticket` CHANGE `round_id` `round_id` INT(11) UNSIGNED NULL;
