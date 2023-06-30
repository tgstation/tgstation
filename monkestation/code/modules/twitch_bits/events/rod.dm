/datum/twitch_event/clang
	event_name = "Immovable Rod Ook"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_STREAMER
	id_tag = "rod-ook"
	announce = FALSE //takes a while to reach its target so dont announce it

/datum/twitch_event/clang/run_event(name)
	. = ..()

	for(var/target in targets) //send a rod at the turf of all targets, not making it target them directly because thats just death
		new /obj/effect/immovablerod(spaceDebrisStartLoc(pick(GLOB.cardinals), target_turf.z), target)
