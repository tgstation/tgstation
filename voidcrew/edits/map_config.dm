//For unit tests, as we don't have 'planets', we set all maps to not be planetary.
/datum/map_config/LoadConfig(filename, error_if_missing)
	. = ..()
	planetary = FALSE
