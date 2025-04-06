/// Trim for Syndicate mobs, outfits and corpses.
/datum/id_trim/syndicom
	assignment = "Syndicate Overlord"
	trim_state = "trim_syndicate"
	department_color = COLOR_SYNDIE_RED
	subdepartment_color = COLOR_SYNDIE_RED
	sechud_icon_state = SECHUD_SYNDICATE
	access = list(ACCESS_SYNDICATE)
	threat_modifier = 5 // Bad guy on deck
	big_pointer = TRUE
	pointer_color = COLOR_SYNDIE_RED

/// Trim for Syndicate mobs, outfits and corpses.
/datum/id_trim/syndicom/crew
	assignment = "Syndicate Operative"
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)
	big_pointer = FALSE

/// Interdyne medical Staff
/datum/id_trim/syndicom/Interdyne
	honorifics = list(", PhD.")
	honorific_positions = HONORIFIC_POSITION_LAST_FULL | HONORIFIC_POSITION_NONE

/datum/id_trim/syndicom/Interdyne/pharmacist
	assignment = "Interdyne Pharmacist"
	trim_state = "trim_medicaldoctor"
	sechud_icon_state = SECHUD_SYNDICATE_INTERDYNE
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS, ACCESS_SURGERY)
	big_pointer = FALSE
	pointer_color = null

/// Interdyne head medical Staff
/datum/id_trim/syndicom/Interdyne/pharmacist_director
	assignment = "Interdyne Pharmacist Director"
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_SYNDIE_RED_HEAD
	subdepartment_color = COLOR_SYNDIE_RED_HEAD
	sechud_icon_state = SECHUD_SYNDICATE_INTERDYNE_HEAD
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS, ACCESS_SURGERY)
	big_pointer = TRUE
	pointer_color = COLOR_SYNDIE_RED_HEAD

/// Trim for the space IRS agents (why are they syndie access? I wouldn't worry about it.)
/datum/id_trim/syndicom/irs
	assignment = "Internal Revenue Service Agent"
	trim_state = "trim_securityofficer"
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = COLOR_COMMAND_BLUE
	sechud_icon_state = SECHUD_DEATH_COMMANDO
	access = list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)
	big_pointer = FALSE
	pointer_color = null
	honorifics = list("Auditor")
	honorific_positions = HONORIFIC_POSITION_FIRST | HONORIFIC_POSITION_LAST | HONORIFIC_POSITION_FIRST_FULL | HONORIFIC_POSITION_NONE


/datum/id_trim/syndicom/irs/auditor
	assignment = "Internal Revenue Service Head Auditor"
	trim_state = "trim_quartermaster"
	sechud_icon_state = SECHUD_QUARTERMASTER
	big_pointer = TRUE

/// Trim for Syndicate mobs, outfits and corpses.
/datum/id_trim/syndicom/captain
	assignment = "Syndicate Ship Captain"
	trim_state = "trim_captain"
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_ROBOTICS)

/// Trim for Syndicate mobs, outfits and corpses.
/datum/id_trim/battlecruiser
	assignment = "Syndicate Battlecruiser Crew"
	trim_state = "trim_syndicate"
	access = list(ACCESS_SYNDICATE)
	threat_modifier = 10

/// Trim for Syndicate mobs, outfits and corpses.
/datum/id_trim/battlecruiser/captain
	assignment = "Syndicate Battlecruiser Captain"
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
	big_pointer = TRUE
	pointer_color = COLOR_SYNDIE_RED

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon
	assignment = "Unknown"
	access = list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)
	threat_modifier = -5 // This guy seems legit

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon/operative
	assignment = "Syndicate Operative"
	trim_state = "trim_syndicate"
	department_color = COLOR_SYNDIE_RED
	subdepartment_color = COLOR_SYNDIE_RED
	sechud_icon_state = SECHUD_SYNDICATE

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon/operative/nuke_leader
	assignment = "Syndicate Operative Leader"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
	big_pointer = TRUE
	pointer_color = COLOR_SYNDIE_RED

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon/operative/clown
	assignment = "Syndicate Entertainment Operative"
	trim_state = "trim_clown"

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon/operative/clown_leader
	assignment = "Syndicate Entertainment Operative Leader"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
	big_pointer = TRUE
	pointer_color = COLOR_SYNDIE_RED
