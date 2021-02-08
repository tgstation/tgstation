/datum/id_trim/admin
	assignment = "Jannie"
	trim_state = "trim_ert_janitor"

/datum/id_trim/admin/New()
	. = ..()
	access = ALL_ACCESS_STATION + CENTCOM_ACCESS + SYNDICATE_ACCESS + AWAY_ACCESS + CULT_ACCESS

/datum/id_trim/highlander
	assignment = "Highlander"
	trim_state = "trim_ert_deathcommando"

/datum/id_trim/highlander/New()
	. = ..()
	access = ALL_ACCESS_STATION + CENTCOM_ACCESS

/datum/id_trim/reaper_assassin
	assignment = "Reaper"
	trim_state = "trim_ert_deathcommando"

/datum/id_trim/highlander/New()
	. = ..()
	access = ALL_ACCESS_STATION

/datum/id_trim/mobster
	assignment = "Mobster"
	trim_state = "trim_assistant"

/datum/id_trim/vr
	assignment = "VR Participant"

/datum/id_trim/vr/New()
	. = ..()
	access |= ALL_ACCESS_STATION

/datum/id_trim/vr/operative
	assignment = "Syndicate VR Operative"

/datum/id_trim/vr/operative/New()
	. = ..()
	access |= list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)
