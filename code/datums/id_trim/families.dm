/// Trim for the families space police. Has all access.
/datum/id_trim/space_police
	assignment = "Space Police"
	trim_state = "trim_securityofficer"
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = COLOR_SECURITY_RED

/datum/id_trim/space_police/New()
	. = ..()
	access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
