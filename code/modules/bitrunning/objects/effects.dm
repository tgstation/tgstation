/obj/effect/bitrunning
	name = "Generic bitrunning effect"
	icon = 'icons/effects/bitrunning.dmi'
	icon_state = "bit_crate"
	invisibility = INVISIBILITY_ABSTRACT

/// In case you want to gate the crate behind a special condition.
/obj/effect/bitrunning/loot_signal
	name = "Mysterious aura"

	/// The amount required to spawn a crate
	var/points_goal = 10
	/// A special condition limits this from spawning a crate
	var/points_received = 0
	/// Finished the special condition
	var/revealed = FALSE

/obj/effect/bitrunning/loot_signal/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BITRUNNER_GOAL_POINT, PROC_REF(on_add_point))

/// Listens for points to be added which will eventually spawn a crate.
/obj/effect/bitrunning/loot_signal/proc/on_add_point(datum/source, points_to_add)
	SIGNAL_HANDLER

	if(revealed)
		return

	points_received += points_to_add

	if(points_received < points_goal)
		return

	reveal()

/// Spawns the crate with some effects
/obj/effect/bitrunning/loot_signal/proc/reveal()
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)
	var/turf/tile = get_turf(src)
	var/obj/structure/closet/crate/secure/bitrunner_loot/encrypted/loot = new(tile)
	var/datum/effect_system/spark_spread/quantum/sparks = new(tile)
	sparks.set_up(5, 1, get_turf(loot))
	sparks.start()
	qdel(src)

/// Place this so that the rewards spawn in the right place.
/obj/effect/bitrunning/reward_spawn
	name = "Bitrunning rewards spawn"

/// Place this where you want hololadders to spawn. These are retries
/obj/effect/bitrunning/exit_spawn
	name = "Bitrunning hololadder spawn"
	icon_state = "bit_exit"

/// Place this where you want the receive turf to be
/obj/effect/bitrunning/goal_turf
	name = "Bitrunning goal turf"
	icon_state = "bit_goal"
