GLOBAL_VAR_INIT(event_vote_enabled, TRUE)

/datum/vote/run_event
	name = "Vote Event"
	message = "Vote to summon an event."
	contains_vote_in_name = TRUE
	count_method = VOTE_COUNT_METHOD_SINGLE
	var/datum/round_event_control/event_to_run

	var/list/players_voted = list()
	var/triggerer

/datum/vote/run_event/toggle_votable(mob/toggler)
	if(!toggler)
		CRASH("[type] wasn't passed a \"toggler\" mob to toggle_votable.")
	if(!check_rights_for(toggler.client, R_ADMIN))
		return FALSE

	GLOB.event_vote_enabled = !GLOB.event_vote_enabled
	return TRUE

/datum/vote/run_event/is_config_enabled()
	return GLOB.event_vote_enabled

/datum/vote/run_event/is_accessible_vote()
	return TRUE

/datum/vote/run_event/can_be_initiated(mob/by_who, forced)
	. = ..()
	if(!.)
		return FALSE

	if(!forced && !GLOB.event_vote_enabled)
		message = "Run event voting is disabled by the admins."
		return FALSE

	if(SSticker.current_state != GAME_STATE_PLAYING)
		message = "You can only run this vote when the game is playing!"
		return FALSE

	if(!forced)
		if(by_who.stat == DEAD)
			message = "You must be alive to make a vote for an event!"
			return FALSE

		if(players_voted[by_who.ckey])
			message = "You've already made a successful event vote! Please try again next round."
			return FALSE

	message = initial(message)
	return TRUE

/datum/vote/run_event/create_vote(mob/vote_creator)
	var/list/events = list()
	for(var/datum/round_event_control/event in SSevents.control)
		events[event.name] = event
	var/selected_event = tgui_input_list(vote_creator, "Select an event to vote for", "Select Event", sort_list(events))
	if(!selected_event)
		return FALSE
	event_to_run = events[selected_event]
	triggerer = vote_creator.ckey
	message_admins("EVENT: [vote_creator.client] initiated an event vote for '[event_to_run]'")
	override_question = "Run [selected_event]?"
	default_choices = list(
		"Yes, run [selected_event]",
		"No",
	)
	return ..()

/datum/vote/run_event/finalize_vote(winning_option)
	if(winning_option == "No")
		return

	if(!event_to_run)
		return

	event_to_run.runEvent(announce_chance_override = 100, admin_forced = TRUE)
	players_voted[triggerer] = TRUE
	triggerer = null
	event_to_run = null
