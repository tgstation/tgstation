/// Trim for Syndicate mobs, outfits and corpses.
/datum/id_trim/syndicom
	assignment = "Syndicate Overlord"
	trim_state = "trim_syndicate"
	department_color = null
	subdepartment_color = null
	sechud_icon_state = SECHUD_SYNDICATE
	access = list(ACCESS_SYNDICATE)

// Enlisted
/datum/id_trim/syndicom/private
	assignment = "Private // P-01"
	trim_state = "trim_gorlex_private"

/datum/id_trim/syndicom/specialist
	assignment = "Private // P-02"
	trim_state = "trim_gorlex_specialist"

/datum/id_trim/syndicom/sergeant
	assignment = "Sergeant // P-03"
	trim_state = "trim_gorlex_sergeant"

/datum/id_trim/syndicom/lieutenant
	assignment = "Lieutenant // P-04"
	trim_state = "trim_gorlex_sergeant"

// Officer
/datum/id_trim/syndicom/officer
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_ROBOTICS)

/datum/id_trim/syndicom/officer/colonel
	assignment = "Colonel // E-01"
	trim_state = "trim_gorlex_colonel"

/datum/id_trim/syndicom/officer/captain
	assignment = "Captain // E-01"
	trim_state = "trim_gorlex_captain"

/datum/id_trim/syndicom/officer/brig_general
	assignment = "Brigadier General // E-02"
	trim_state = "trim_gorlex_brig_general"

/datum/id_trim/syndicom/officer/maj_general
	assignment = "Major General // E-03"
	trim_state = "trim_gorlex_maj_general"

/datum/id_trim/syndicom/officer/general
	assignment = "General // E-04"
	trim_state = "trim_gorlex_general"

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon
	assignment = "Unknown"
	access = list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)

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

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon/operative/clown
	assignment = "Syndicate Entertainment Operative"
	trim_state = "trim_clown"

/// Trim for Chameleon ID cards. Many outfits, nuke ops and some corpses hold Chameleon ID cards.
/datum/id_trim/chameleon/operative/clown_leader
	assignment = "Syndicate Entertainment Operative Leader"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
