/// An invisible effect which chases a target, spawning spikes every so often.
/obj/effect/temp_visual/effect_trail
	name = "effect trail"
	desc = "An invisible effect, how did you examine this?"
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "marker"
	duration = 15 SECONDS
	invisibility = INVISIBILITY_ABSTRACT
	/// Typepath of our spawned effect
	var/spawned_effect
	/// How often do we spawn our other effect?
	var/spawn_interval = 0.5 SECONDS
	/// Speed at which we chase target
	var/move_speed = 3
	/// What are we chasing?
	var/atom/target
	/// Stop spawning if we have this many effects already
	var/max_spawned = 20
	/// Do we home in after we started moving?
	var/homing = TRUE
	/// Handles chasing the target
	var/datum/move_loop/movement

/obj/effect/temp_visual/effect_trail/Initialize(mapload, atom/target)
	. = ..()
	if (!target)
		return INITIALIZE_HINT_QDEL

	AddElement(/datum/element/floor_loving)
	AddComponent(/datum/component/spawner, spawn_types = list(spawned_effect), max_spawned = max_spawned, spawn_time = spawn_interval)
	src.target = target
	movement = GLOB.move_manager.move_towards(src, chasing = target, delay = move_speed, home = homing, timeout = duration, flags = MOVEMENT_LOOP_START_FAST)

	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_invalid))
	if (isliving(target))
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_invalid))

/// Destroy ourselves if the target is no longer valid
/obj/effect/temp_visual/effect_trail/proc/on_target_invalid()
	SIGNAL_HANDLER
	target = null
	qdel(src)

/obj/effect/temp_visual/effect_trail/Destroy()
	QDEL_NULL(movement)
	return ..()
