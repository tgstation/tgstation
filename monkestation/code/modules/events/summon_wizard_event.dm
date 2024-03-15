/datum/round_event_control/summon_wizard_event
	name = "Summon Wizard Event"
	typepath = /datum/round_event/summon_wizard_event
	weight = 0
	category = EVENT_CATEGORY_WIZARD
	description = "Trigger a random wizard event that meets its normal conditions."
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_SPOOKY, TAG_MAGICAL)
	allowed_storytellers = /datum/storyteller/mystic

/datum/round_event/summon_wizard_event
	///the event we have actually chosen to run
	var/datum/round_event_control/triggered_event

/datum/round_event/summon_wizard_event/setup()
	var/list/possible_events = list()
	var/player_count = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	for(var/datum/round_event_control/possible_event as anything in SSevents.control)
		if(!possible_event.wizardevent || !possible_event.can_spawn_event(player_count, allow_magic = TRUE))
			continue
		possible_events[possible_event] = possible_event.weight

	if(!length(possible_events))
		kill()
		return

	triggered_event = pick_weight(possible_events)
	setup = TRUE

/datum/round_event/summon_wizard_event/start()
	triggered_event.run_event()
