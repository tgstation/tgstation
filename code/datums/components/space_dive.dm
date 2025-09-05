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
	/// Type of turf that is divable
	var/diveable_turf = /turf/open/space
	/// A decal we can dive from, and escape into (but only one enter)
	var/diveable_decal = /obj/effect/decal/cleanable/vomit/nebula

/datum/component/space_dive/Initialize(jaunt_type)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.jaunt_type = jaunt_type

	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(bump))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

/datum/component/space_dive/proc/bump(mob/living/parent, atom/bumped)
	SIGNAL_HANDLER

	if(!istype(get_turf(parent), diveable_turf))
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

	var/mob/living/diver = parent
	diver.drop_all_held_items()

	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(surface))
	RegisterSignal(jaunt, COMSIG_MOB_PHASED_CHECK, PROC_REF(move_check))
	parent.add_traits(phase_traits, REF(src))

	// This needs to happen at the end, after all the traits and stuff is handled
	SEND_SIGNAL(parent, COMSIG_MOB_ENTER_JAUNT, src, jaunt)

/datum/component/space_dive/proc/move_check(obj/effect/dummy/phased_mob/jaunt, mob/living/parent, turf/new_turf)
	SIGNAL_HANDLER

	if(!istype(new_turf, diveable_turf) && !(locate(diveable_decal) in new_turf))
		return

	INVOKE_ASYNC(src, PROC_REF(attempt_surface), parent, new_turf)
	return COMPONENT_BLOCK_PHASED_MOVE

/// try and surface by doing a do_after
/datum/component/space_dive/proc/attempt_surface(mob/living/parent, turf/new_turf)
	if(do_after(parent, surface_time, new_turf, extra_checks = CALLBACK(src, PROC_REF(check_if_moved), parent, get_turf(parent))))
		var/decal = locate(diveable_decal) in new_turf

		if(decal)
			var/obj/particles = new /obj/effect/abstract/particle_holder (decal, /particles/void_vomit)
			QDEL_IN(particles, 60 SECONDS)

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

/datum/component/space_dive/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(istype(target, diveable_decal))
		INVOKE_ASYNC(src, PROC_REF(try_enter), source, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/space_dive/proc/try_enter(mob/living/source, atom/movable/decal)
	if(!do_after(source, 1 SECONDS, decal))
		return

	dive(decal)
	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(decal))
	qdel(decal)

/obj/effect/dummy/phased_mob/space_dive
	movespeed = 1
	phased_mob_icon_state = "solarflare"

/obj/effect/dummy/phased_mob/space_dive/voidwalker
	phased_mob_icon = /mob/living/basic/voidwalker::icon
	phased_mob_icon_state = /mob/living/basic/voidwalker::icon_state + "_stealthed"

/obj/effect/dummy/phased_mob/space_dive/sunwalker
	phased_mob_icon = /mob/living/basic/voidwalker/sunwalker::icon
	phased_mob_icon_state = /mob/living/basic/voidwalker/sunwalker::icon_state + "_stealthed"
