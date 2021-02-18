/datum/id_trim/admin
	assignment = "Jannie"
	trim_state = "trim_ert_janitor"

/datum/id_trim/admin/New()
	. = ..()
	// Every single access in the game, all on one handy trim.
	access = SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL))

/datum/id_trim/highlander
	assignment = "Highlander"
	trim_state = "trim_ert_deathcommando"

/datum/id_trim/highlander/New()
	. = ..()
	access = SSid_access.get_region_access_list(list(REGION_ACCESS_CENTCOM, REGION_ALL_STATION))

/datum/id_trim/reaper_assassin
	assignment = "Reaper"
	trim_state = "trim_ert_deathcommando"

/datum/id_trim/highlander/New()
	. = ..()
	access = SSid_access.get_region_access_list(list(REGION_ALL_STATION))

/datum/id_trim/mobster
	assignment = "Mobster"
	trim_state = "trim_assistant"

/datum/id_trim/vr
	assignment = "VR Participant"

/datum/id_trim/vr/New()
	. = ..()
	access |= SSid_access.get_region_access_list(list(REGION_ALL_STATION))

/datum/id_trim/vr/operative
	assignment = "Syndicate VR Operative"

/datum/id_trim/vr/operative/New()
	. = ..()
	access |= list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)

/datum/id_trim/tunnel_clown
	assignment = "Tunnel Clown!"
	trim_state = "trim_clown"

/datum/id_trim/tunnel_clown/New()
	. = ..()
	access |= SSid_access.get_region_access_list(list(REGION_ALL_STATION))
