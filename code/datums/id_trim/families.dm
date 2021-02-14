/datum/id_trim/space_police
	trim_state = "trim_ert_security"
	assignment = "Space Police"

/datum/id_trim/space_police/New()
	. = ..()
	access = REGION_ACCESS_ALL_STATION
