/datum/twitch_event/chucklenuts
	event_name = "Think Fast Ook"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_STREAMER
	id_tag = "chucklenuts-ook"


/datum/twitch_event/chucklenuts
	event_name = "Think Fast"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_RANDOM
	id_tag = "chucklenuts-random"

/datum/twitch_event/chucklenuts/run_event()
	. = ..()
	for(var/target in targets)
		var/mob/living/ook = target
		var/obj/item/grenade/flashbang/primed_and_ready = new(get_turf(ook))
		ook.put_in_active_hand(primed_and_ready, forced = TRUE)
		primed_and_ready.arm_grenade(ook)
