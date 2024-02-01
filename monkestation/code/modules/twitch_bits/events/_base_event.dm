/datum/twitch_event
	/// name of event
	var/event_name = ""
	/// duration of the event
	var/event_duration = 10 MINUTES
	/// event flags
	var/event_flags = TWITCH_AFFECTS_STREAMER | CLEAR_TARGETS_AFTER_EFFECTS
	///amount of people we affect if its random
	var/random_count = 0
	///list of targets
	var/list/targets = list()
	///the tag tied to this event
	var/id_tag
	///should we announce this event
	var/announce = TRUE
	///how many event tokens does this cost to trigger
	var/token_cost = 0

/datum/twitch_event/proc/run_event(name)
	get_targets()

	apply_effects()

	if(event_flags & CLEAR_TARGETS_AFTER_EFFECTS)
		targets = list()
	if(announce)
		minor_announce("[event_name] has just been triggered by [name].", "The Observers")

/datum/twitch_event/proc/get_targets()
	if(event_flags & TWITCH_AFFECTS_STREAMER)
		event_flags & TWITCH_ALLOW_DUPLICATE_TARGETS ? (targets += get_mob_by_ckey("taocat")) : (targets |= get_mob_by_ckey("taocat"))

	if(event_flags & TWITCH_AFFECTS_ALL)
		event_flags & TWITCH_ALLOW_DUPLICATE_TARGETS ? (targets += GLOB.alive_player_list) : (targets |= GLOB.alive_player_list)

	if(event_flags & TWITCH_AFFECTS_RANDOM)
		var/list/living_players = GLOB.alive_player_list
		var/allow_duplicates = event_flags & TWITCH_ALLOW_DUPLICATE_TARGETS
		for(var/num in 1 to random_count)
			allow_duplicates ? (targets += pick_n_take(living_players)) : (targets |= pick_n_take(living_players))

/datum/twitch_event/proc/apply_effects()
	return

/datum/twitch_event/proc/end_event()
	if(event_flags & CLEAR_TARGETS_ON_END_EVENT)
		targets = list()
