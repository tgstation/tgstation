/// Trim for basic Centcom cards.
/datum/id_trim/centcom
	access = list(ACCESS_CENT_GENERAL)
	assignment = "Central Command"
	trim_state = "trim_centcom"

/// Trim for Centcom VIPs
/datum/id_trim/centcom/vip
	access = list(ACCESS_CENT_GENERAL)
	assignment = "VIP Guest"

/// Trim for Centcom Custodians.
/datum/id_trim/centcom/custodian
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	assignment = "Custodian"

/// Trim for Centcom Thunderdome Overseers.
/datum/id_trim/centcom/thunderdome_overseer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
	assignment = "Thunderdome Overseer"

/// Trim for Centcom Officials.
/datum/id_trim/centcom/official
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = "CentCom Official"

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
	assignment = "CentCom Bartender"

/// Trim for Centcom Medical Officers.
/datum/id_trim/centcom/medical_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
	assignment = "Medical Officer"

/// Trim for Centcom Research Officers.
/datum/id_trim/centcom/research_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
	assignment = "Research Officer"

/// Trim for Centcom Specops Officers. All Centcom and Station Access.
/datum/id_trim/centcom/specops_officer
	assignment = "Special Ops Officer"

/datum/id_trim/centcom/specops_officer/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for Centcom (Soviet) Admirals. All Centcom and Station Access.
/datum/id_trim/centcom/admiral
	assignment = "Admiral"

/datum/id_trim/centcom/admiral/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for Centcom Commanders. All Centcom and Station Access.
/datum/id_trim/centcom/commander
	assignment = "CentCom Commander"

/datum/id_trim/centcom/commander/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for Deathsquad officers. All Centcom and Station Access.
/datum/id_trim/centcom/deathsquad
	assignment = "Death Commando"
	trim_state = "trim_ert_commander"

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
	assignment = "Emergency Response Team Commander"
	trim_state = "trim_ert_commander"

/datum/id_trim/centcom/ert/commander/New()
	. = ..()

	access = SSid_access.get_region_access_list(list(REGION_CENTCOM, REGION_ALL_STATION))

/// Trim for generic ERT seccies. No universal ID card changing access.
/datum/id_trim/centcom/ert/security
	assignment = "Security Response Officer"
	trim_state = "trim_ert_security"

/datum/id_trim/centcom/ert/security/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT engineers. No universal ID card changing access.
/datum/id_trim/centcom/ert/engineer
	assignment = "Engineering Response Officer"
	trim_state = "trim_ert_engineering"

/datum/id_trim/centcom/ert/engineer/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT medics. No universal ID card changing access.
/datum/id_trim/centcom/ert/medical
	assignment = "Medical Response Officer"
	trim_state = "trim_ert_medical"

/datum/id_trim/centcom/ert/medical/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT chaplains. No universal ID card changing access.
/datum/id_trim/centcom/ert/chaplain
	assignment = "Religious Response Officer"
	trim_state = "trim_ert_religious"

/datum/id_trim/centcom/ert/chaplain/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT janitors. No universal ID card changing access.
/datum/id_trim/centcom/ert/janitor
	assignment = "Janitorial Response Officer"
	trim_state = "trim_ert_janitor"

/datum/id_trim/centcom/ert/janitor/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT clowns. No universal ID card changing access.
/datum/id_trim/centcom/ert/clown
	assignment = "Entertainment Response Officer"
	trim_state = "trim_ert_entertainment"

/datum/id_trim/centcom/ert/clown/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING) | (SSid_access.get_region_access_list(list(REGION_ALL_STATION)) - ACCESS_CHANGE_IDS)
