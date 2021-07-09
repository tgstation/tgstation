/// Trim for the families space police. Has all access.
/datum/id_trim/space_police
	trim_state = "trim_ert_security"
	assignment = "Space Police"

/datum/id_trim/space_police/New()
	. = ..()
	access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
