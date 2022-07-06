/// Trim for the families space police. Has all access.
/datum/id_trim/space_police
	assignment = "Space Police"
	trim_state = "trim_securityofficer"
	department_color = "#134975"
	subdepartment_color = "#CB0000"

/datum/id_trim/space_police/New()
	. = ..()
	access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
