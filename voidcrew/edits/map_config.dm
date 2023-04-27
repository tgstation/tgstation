/**
 * LoadConfig
 * 
 * We're setting planetary to FALSE for unit testing, as we don't have a map.
 * We're alo clearing all job changes, as job changes are per TG map, not ship/planet/whatnot, making this unwanted by us.
 */
/datum/map_config/LoadConfig(filename, error_if_missing)
	. = ..()
	planetary = FALSE
	job_changes = list()
