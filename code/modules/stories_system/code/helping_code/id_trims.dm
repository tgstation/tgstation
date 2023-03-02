/datum/id_trim/centcom/centcom_inspector
	assignment = JOB_CENTCOM_INSPECTOR

/datum/id_trim/centcom/centcom_inspector/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION)) // torn on if they should have AA, or need to ask to get it

/datum/id_trim/job/assistant/tourist
	assignment = "Tourist"

/datum/id_trim/job/assistant/government_official
	assignment = "Government Official"

/datum/id_trim/job/assistant/inspector
	assignment = "Inspector"

/datum/id_trim/centcom/centcom_inspector/middle_management
	assignment = JOB_CENTCOM_MIDDLE_MANAGEMENT

/datum/id_trim/centcom/centcom_inspector/middle_management/cargo/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(
		REGION_CENTCOM,
		REGION_ACCESS_COMMAND,
		REGION_ACCESS_SUPPLY,

	))

/datum/id_trim/centcom/centcom_inspector/middle_management/security/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(
		REGION_CENTCOM,
		REGION_ACCESS_COMMAND,
		REGION_ACCESS_SECURITY,
	))

/datum/id_trim/centcom/centcom_inspector/middle_management/science/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(
		REGION_CENTCOM,
		REGION_ACCESS_COMMAND,
		REGION_ACCESS_RESEARCH,
	))

/datum/id_trim/centcom/centcom_inspector/middle_management/medbay/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(
		REGION_CENTCOM,
		REGION_ACCESS_COMMAND,
		REGION_ACCESS_MEDBAY,
	))

/datum/id_trim/centcom/centcom_inspector/middle_management/service/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(
		REGION_CENTCOM,
		REGION_ACCESS_COMMAND,
		REGION_ACCESS_GENERAL,
	))

/datum/id_trim/centcom/centcom_inspector/middle_management/engineering/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(
		REGION_CENTCOM,
		REGION_ACCESS_COMMAND,
		REGION_ACCESS_ENGINEERING,
	))

/datum/id_trim/job/assistant/med_student
	assignment = "Medical Student"

/datum/id_trim/job/assistant/author
	assignment = "Best-Selling Author"

/datum/id_trim/job/assistant/agent
	assignment = "Agent"

/datum/id_trim/real_guard
	assignment = "Unemployed"

/datum/id_trim/real_guard/New()
	. = ..()

	access = SSid_access.get_access_flag(ACCESS_MAINT_TUNNELS)
