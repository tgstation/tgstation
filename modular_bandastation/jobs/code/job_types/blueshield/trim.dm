/datum/id_trim/job/blueshield
	assignment = JOB_BLUESHIELD
	trim_icon = 'modular_bandastation/jobs/icons/obj/card.dmi'
	trim_state = "trim_blueshield"
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = "#FFD700"
	sechud_icon_state = SECHUD_BLUESHIELD
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_CARGO,
		ACCESS_COURT,
		ACCESS_GATEWAY,
		ACCESS_SECURITY,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_BLUESHIELD,
		ACCESS_COMMAND,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_EVA,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SCIENCE,
		ACCESS_TELEPORTER,
		ACCESS_WEAPONS,
	)
	template_access = null
	job = /datum/job/blueshield
