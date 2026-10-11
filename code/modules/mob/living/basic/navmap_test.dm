/// A small, inert mob used to exercise navmap movement from the admin debug tools.
/mob/living/basic/navmap_test
	abstract_type = /mob/living/basic/navmap_test
	name = "navmap test chair"
	desc = "A chair used to test navmap pathfinding."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	icon_living = "chair"
	icon_dead = "chair"
	health = 100
	maxHealth = 100
	habitable_atmos = null
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	movement_type = GROUND

/// Starts or replaces this mob's navmap movement loop toward a target.
/mob/living/basic/navmap_test/proc/path_to(atom/target)
	if(!target || QDELETED(target) || !loc || stat == DEAD)
		return FALSE

	GLOB.move_manager.stop_looping(src, SSmovement)
	if(get_turf(src) == get_turf(target))
		return TRUE

	var/datum/move_loop/has_target/navmap_astar/loop = GLOB.move_manager.navmap_astar_move(src,
		target,
		delay = 0.5 SECONDS,
		repath_delay = 1 SECONDS,
		max_path_length = 200,
		minimum_distance = 0,
		access = get_access(),
		// The flying variant is intentionally allowed to search non-simulated space.
		simulated_only = !(movement_type & MOVETYPES_NOT_TOUCHING_GROUND),
		skip_first = TRUE,
		diagonal_handling = DIAGONAL_REMOVE_CLUNKY,
		subsystem = SSmovement,
		allow_multiz = TRUE,
		max_path_cost = 2000,
	)
	return !!loop

/mob/living/basic/navmap_test/ground
	name = "ground navmap test chair"
	movement_type = GROUND

/mob/living/basic/navmap_test/flying
	name = "flying navmap test chair"
	movement_type = FLYING
