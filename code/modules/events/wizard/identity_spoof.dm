/datum/round_event_control/wizard/identity_spoof //now EVERYONE is the wizard!
	name = "Mass Identity Spoof"
	weight = 5
	typepath = /datum/round_event/wizard/identity_spoof
	max_occurrences = 1

/datum/round_event_control/wizard/identity_spoof/canSpawnEvent(players_amt)
	. = ..()
	if(.)
		return FALSE
	if(SSticker.anonymousnames) //already anonymous, ABORT ABORT
		return FALSE

/datum/round_event/wizard/identity_spoof/start()
	if(SSticker.anonymousnames)
		QDEL_NULL(SSticker.anonymousnames)
	SSticker.anonymousnames = new /datum/anonymous_theme/wizards()
	anonymous_all_players()
