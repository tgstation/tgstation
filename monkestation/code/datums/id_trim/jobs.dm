/datum/id_trim/job/brig_physician
	assignment = "Brig Physician"
	trim_state = "trim_brigphysician"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_BRIG_PHYSICIAN
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		)
	extra_access = list(
		ACCESS_DETECTIVE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_SURGERY,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOS,
		)
	job = /datum/job/brig_physician
