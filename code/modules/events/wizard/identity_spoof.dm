/datum/round_event_control/wizard/identity_spoof //now EVERYONE is the wizard!
	name = "Mass Identity Spoof"
	weight = 5
	typepath = /datum/round_event/wizard/identity_spoof
	max_occurrences = 1
	description = "Makes everyone dressed up like a wizard."

/datum/round_event_control/wizard/identity_spoof/can_spawn_event(players_amt)
	. = ..()
	if(!.)
		return .

	if(GLOB.current_anonymous_theme) //already anonymous, ABORT ABORT
		return FALSE
	return TRUE

/datum/round_event/wizard/identity_spoof/start()
	if(GLOB.current_anonymous_theme)
		QDEL_NULL(GLOB.current_anonymous_theme)
	GLOB.current_anonymous_theme = new /datum/anonymous_theme/wizards(extras_enabled = TRUE, alert_players = TRUE)
