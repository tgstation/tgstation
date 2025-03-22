/// Lets us dive under the station from space
/datum/component/space_dive
	/// holder we use when we're in dive
	var/jaunt_type = /obj/effect/dummy/phased_mob/space_dive
	/// time it takes to enter the dive
	var/dive_time = 3 SECONDS
	/// the time it takes to exit our space dive
	var/surface_time = 1 SECONDS
	/// Traits added during phasing (and removed after)
	var/static/phase_traits = list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN, TRAIT_WEATHER_IMMUNE)

/datum/component/space_dive/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(bump))

/datum/component/space_dive/proc/bump(mob/living/parent, atom/bumped)
	SIGNAL_HANDLER

	if(!isspaceturf(get_turf(parent)))
		return

	if(ismovable(bumped))
		if(istype(bumped, /obj/machinery/door))//door check is kinda lame but it just plays better
			return

		var/atom/movable/mover = bumped
		if(!mover.anchored)
			return

	INVOKE_ASYNC(src, PROC_REF(attempt_dive), parent, bumped)

/datum/component/space_dive/proc/attempt_dive(mob/living/parent, atom/bumped)
	if(!do_after(parent, dive_time, bumped))
		return

	dive(bumped)

/datum/component/space_dive/proc/dive(atom/bumped)
	var/obj/effect/dummy/phased_mob/jaunt = new jaunt_type(get_turf(bumped), parent)

	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(surface))
	RegisterSignal(jaunt, COMSIG_MOB_PHASED_CHECK, PROC_REF(move_check))
	parent.add_traits(phase_traits, REF(src))

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(parent, COMSIG_MOB_ENTER_JAUNT, src, jaunt)

/datum/component/space_dive/proc/move_check(obj/effect/dummy/phased_mob/jaunt, mob/living/parent, turf/new_turf)
	SIGNAL_HANDLER

	if(!isspaceturf(new_turf))
		return

	INVOKE_ASYNC(src, PROC_REF(attempt_surface), parent, new_turf)
	return COMPONENT_BLOCK_PHASED_MOVE

/// try and surface by doing a do_after
/datum/component/space_dive/proc/attempt_surface(mob/living/parent, turf/new_turf)
	if(do_after(parent, surface_time, new_turf, extra_checks = CALLBACK(src, PROC_REF(check_if_moved), parent, get_turf(parent))))
		surface(null, parent, new_turf)

// we check if we moved for the do_after, since relayed movements arent caught that well by the do_after
/datum/component/space_dive/proc/check_if_moved(mob/living/parent, turf/do_after_turf)
	return get_turf(parent) == do_after_turf

/datum/component/space_dive/proc/surface(atom/holder, mob/living/parent, turf/target)
	SIGNAL_HANDLER

	var/obj/effect/dummy/phased_mob/jaunt = parent.loc
	if(!istype(jaunt))
		return FALSE

	parent.remove_traits(phase_traits, REF(src))

	parent.forceMove(target || get_turf(parent))
	qdel(jaunt)

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(parent, COMSIG_MOB_AFTER_EXIT_JAUNT, src)

/obj/effect/dummy/phased_mob/space_dive
	movespeed = 1
	phased_mob_icon_state = "solarflare"
