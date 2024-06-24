/// Trim for basic Centcom cards.
/datum/id_trim/centcom
	access = list(ACCESS_CENT_GENERAL)
	assignment = JOB_CENTCOM
	trim_state = "trim_centcom"
	sechud_icon_state = SECHUD_CENTCOM
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = COLOR_CENTCOM_BLUE
	threat_modifier = -10 // Centcom are legally allowed to do whatever they want

/// Trim for Centcom VIPs
/datum/id_trim/centcom/vip
	access = list(ACCESS_CENT_GENERAL)
	assignment = JOB_CENTCOM_VIP

/// Trim for Centcom Custodians.
/datum/id_trim/centcom/custodian
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	assignment = JOB_CENTCOM_CUSTODIAN
	trim_state = "trim_janitor"
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = COLOR_SERVICE_LIME

/// Trim for Centcom Thunderdome Overseers.
/datum/id_trim/centcom/thunderdome_overseer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
	assignment = JOB_CENTCOM_THUNDERDOME_OVERSEER

/// Trim for Centcom Officials.
/datum/id_trim/centcom/official
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = JOB_CENTCOM_OFFICIAL

/// Trim for Centcom Interns.
/datum/id_trim/centcom/intern
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = "CentCom Intern"

/// Trim for Centcom Head Interns. Different assignment, common station access added on.
/datum/id_trim/centcom/intern/head
	assignment = "CentCom Head Intern"

/datum/id_trim/centcom/intern/head/New()
	. = ..()

	access |= SSid_access.get_flag_access_list(ACCESS_FLAG_COMMON)

/// Trim for Bounty Hunters hired by centcom.
/datum/id_trim/centcom/bounty_hunter
	access = list(ACCESS_CENT_GENERAL)
	assignment = "Bounty Hunter"

/// Trim for Centcom Bartenders.
/datum/id_trim/centcom/bartender
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_BAR)
	assignment = JOB_CENTCOM_BARTENDER

/// Trim for Centcom Medical Officers.
/datum/id_trim/centcom/medical_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
	assignment = JOB_CENTCOM_MEDICAL_DOCTOR

/// Trim for Centcom Research Officers.
/datum/id_trim/centcom/research_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
	assignment = JOB_CENTCOM_RESEARCH_OFFICER

/// Trim for Centcom Specops Officers. All Centcom and Station Access.
/datum/id_trim/centcom/specops_officer
	assignment = JOB_CENTCOM_SPECIAL_OFFICER

/datum/id_trim/centcom/specops_officer/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for Centcom (Soviet) Admirals. All Centcom and Station Access.
/datum/id_trim/centcom/admiral
	assignment = JOB_CENTCOM_ADMIRAL

/datum/id_trim/centcom/admiral/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for Centcom Commanders. All Centcom and Station Access.
/datum/id_trim/centcom/commander
	assignment = JOB_CENTCOM_COMMANDER

/datum/id_trim/centcom/commander/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for Deathsquad officers. All Centcom and Station Access.
/datum/id_trim/centcom/deathsquad
	assignment = JOB_ERT_DEATHSQUAD
	trim_state = "trim_deathcommando"
	sechud_icon_state = SECHUD_DEATH_COMMANDO

/datum/id_trim/centcom/deathsquad/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for generic ERT interns. No universal ID card changing access.
/datum/id_trim/centcom/ert
	assignment = "Emergency Response Team Intern"

/datum/id_trim/centcom/ert/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for ERT Commanders. All station and centcom access.
/datum/id_trim/centcom/ert/commander
	assignment = JOB_ERT_COMMANDER
	trim_state = "trim_ert_commander"
	sechud_icon_state = SECHUD_EMERGENCY_RESPONSE_TEAM_COMMANDER

/datum/id_trim/centcom/ert/commander/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for generic ERT seccies. No universal ID card changing access.
/datum/id_trim/centcom/ert/security
	assignment = JOB_ERT_OFFICER
	trim_state = "trim_securityofficer"
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_SECURITY_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/security/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT engineers. No universal ID card changing access.
/datum/id_trim/centcom/ert/engineer
	assignment = JOB_ERT_ENGINEER
	trim_state = "trim_stationengineer"
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_ENGINEERING_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/engineer/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT medics. No universal ID card changing access.
/datum/id_trim/centcom/ert/medical
	assignment = JOB_ERT_MEDICAL_DOCTOR
	trim_state = "trim_medicaldoctor"
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_MEDICAL_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/medical/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT chaplains. No universal ID card changing access.
/datum/id_trim/centcom/ert/chaplain
	assignment = JOB_ERT_CHAPLAIN
	trim_state = "trim_chaplain"
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_RELIGIOUS_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/chaplain/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT janitors. No universal ID card changing access.
/datum/id_trim/centcom/ert/janitor
	assignment = JOB_ERT_JANITOR
	trim_state = "trim_ert_janitor"
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_JANITORIAL_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/janitor/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT clowns. No universal ID card changing access.
/datum/id_trim/centcom/ert/clown
	assignment = JOB_ERT_CLOWN
	trim_state = "trim_clown"
	subdepartment_color = COLOR_MAGENTA
	sechud_icon_state = SECHUD_ENTERTAINMENT_RESPONSE_OFFICER

/datum/id_trim/centcom/ert/clown/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/datum/id_trim/centcom/ert/militia
	assignment = "Frontier Militia"

/datum/id_trim/centcom/ert/militia/general
	assignment = "Frontier Militia General"
