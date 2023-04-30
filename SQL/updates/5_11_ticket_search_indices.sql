-- Version 5.11, 7 September 2020, by bobbahbrown, MrStonedOne, and Jordie0608 (Updated 26 March 2021 by bobbahbrown)
-- Adds indices to support search operations on the adminhelp ticket tables. This is to support improved performance on Atlanta Ned's Statbus.

ALTER TABLE `ticket`
	ADD INDEX `idx_ticket_act_recip` (`action`, `recipient`),
	ADD INDEX `idx_ticket_act_send` (`action`, `sender`),
	ADD INDEX `idx_ticket_tic_rid` (`ticket`, `round_id`),
	ADD INDEX `idx_ticket_act_time_rid` (`action`, `timestamp`, `round_id`);
