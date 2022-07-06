/**
 * This file contains all the trims associated with outfits.
 */

/// Trim for the assassin outfit.
/datum/id_trim/reaper_assassin
	assignment = "Reaper"
	trim_state = "trim_ert_deathcommando"
	department_color = "#4D4D4D"
	subdepartment_color = "#FF0000" // I AM THE VIOLENCE

/datum/id_trim/highlander/New()
	. = ..()
	access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))

/// Trim for the mobster outfit.
/datum/id_trim/mobster
	assignment = "Mobster"
	trim_state = "trim_assistant"
	department_color = "#6E6E6E"
	subdepartment_color = "#828163"

/// Trim for VR outfits.
/datum/id_trim/vr
	assignment = "VR Participant"
	department_color = "#6E6E6E" // We removed VR why is this still here in 2022
	subdepartment_color = "#828163"

/datum/id_trim/vr/New()
	. = ..()
	access |= SSid_access.get_region_access_list(list(REGION_ALL_STATION))

/// Trim for VR outfits.
/datum/id_trim/vr/operative
	assignment = "Syndicate VR Operative"
	department_color = "#FF0000"
	subdepartment_color = "#FF0000"

/datum/id_trim/vr/operative/New()
	. = ..()
	access |= list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)

/// Trim for the Tunnel Clown! outfit. Has all access.
/datum/id_trim/tunnel_clown
	assignment = "Tunnel Clown!"
	trim_state = "trim_clown"
	department_color = "#FF00FF"
	subdepartment_color = "#FF00FF"

/datum/id_trim/tunnel_clown/New()
	. = ..()
	access |= SSid_access.get_region_access_list(list(REGION_ALL_STATION))

/// Trim for Bounty Hunters NOT hired by centcom. (?)
/datum/id_trim/bounty_hunter
	assignment = "Bounty Hunter"
	department_color = "#A54900"
	subdepartment_color = "#292929"
