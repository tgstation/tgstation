/datum/twitch_event/chucklenuts
	event_name = "Think Fast Ook"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_STREAMER | CLEAR_TARGETS_AFTER_EFFECTS
	id_tag = T_EVENT_CHUCKLENUTS_OOK
	token_cost = 800

/datum/twitch_event/chucklenuts/random
	event_name = "Think Fast"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_RANDOM | CLEAR_TARGETS_AFTER_EFFECTS
	id_tag = T_EVENT_CHUCKLENUTS_RANDOM
	token_cost = null

/datum/twitch_event/chucklenuts/apply_effects()
	for(var/target in targets)
		var/mob/living/ook = target
		var/obj/item/grenade/flashbang/primed_and_ready = new(get_turf(ook))
		ook.put_in_active_hand(primed_and_ready, forced = TRUE)
		primed_and_ready.arm_grenade(ook)
