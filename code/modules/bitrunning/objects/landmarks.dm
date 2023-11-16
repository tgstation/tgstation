/obj/effect/landmark/bitrunning
	name = "Generic bitrunning effect"
	icon = 'icons/effects/bitrunning.dmi'
	icon_state = "crate"

/// In case you want to gate the crate behind a special condition.
/obj/effect/landmark/bitrunning/loot_signal
	name = "Mysterious aura"
	/// The amount required to spawn a crate
	var/points_goal = 10
	/// A special condition limits this from spawning a crate
	var/points_received = 0
	/// Finished the special condition
	var/revealed = FALSE

/obj/effect/landmark/bitrunning/loot_signal/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_BITRUNNER_GOAL_POINT, PROC_REF(on_add_point))

/// Listens for points to be added which will eventually spawn a crate.
/obj/effect/landmark/bitrunning/loot_signal/proc/on_add_point(datum/source, points_to_add)
	SIGNAL_HANDLER

	if(revealed)
		return

	points_received += points_to_add

	if(points_received < points_goal)
		return

	reveal()

/// Spawns the crate with some effects
/obj/effect/landmark/bitrunning/loot_signal/proc/reveal()
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)

	var/turf/tile = get_turf(src)
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/loot = new(tile)
	var/datum/effect_system/spark_spread/quantum/sparks = new(tile)
	sparks.set_up(5, 1, get_turf(loot))
	sparks.start()

	qdel(src)

/// Where the exit hololadder spawns
/obj/effect/landmark/bitrunning/hololadder_spawn
	name = "Bitrunning hololadder spawn"
	icon_state = "hololadder"

/// Where the crates need to be taken
/obj/effect/landmark/bitrunning/cache_goal_turf
	name = "Bitrunning goal turf"
	icon_state = "goal"

/// Where you want the crate to spawn
/obj/effect/landmark/bitrunning/cache_spawn
	name = "Bitrunning crate spawn"
	icon_state = "spawn"

/// Where the safehouse will spawn
/obj/effect/landmark/bitrunning/safehouse_spawn
	name = "Bitrunning safehouse spawn"
	icon_state = "safehouse"

///Swaps the locations of an encrypted crate in the area with another randomly selected crate.
///Randomizes names, so you have to inspect crates manually.
/obj/effect/landmark/bitrunning/crate_replacer
	name = "Bitrunning Goal Crate Randomizer"
	icon_state = "crate"

/obj/effect/landmark/bitrunning/crate_replacer/Initialize(mapload)
	. = ..()

	#ifndef UNIT_TESTS
	var/list/crate_list = list()
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/encrypted_crate
	var/area/my_area = get_area(src)

	for(var/turf/area_turf as anything in my_area.get_contained_turfs())
		for(var/obj/structure/closet/crate/crate_to_check in area_turf)
			if(istype(crate_to_check, /obj/structure/closet/crate/secure/bitrunning/encrypted))
				encrypted_crate = crate_to_check
				crate_to_check.desc += span_hypnophrase(" This feels like the crate we're looking for!")
			else
				crate_list += crate_to_check
			crate_to_check.name = "Unidentified Crate"

	if(!encrypted_crate)
		stack_trace("Bitrunning Goal Crate Randomizer failed to find an encrypted crate to swap positions for.")
		return
	if(!length(crate_list))
		stack_trace("Bitrunning Goal Crate Randomizer failed to find any NORMAL crates to swap positions for.")
		return

	var/original_location = encrypted_crate.loc
	var/obj/structure/closet/crate/selected_crate = pick(crate_list)

	encrypted_crate.abstract_move(selected_crate.loc)
	selected_crate.abstract_move(original_location)

	#endif
