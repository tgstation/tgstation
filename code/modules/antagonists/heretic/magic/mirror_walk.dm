/// Macro to check if the passed mob is currently in jaunting "in the mirror".
#define IS_MIRROR_PHASED(mob) istype(user.loc, /obj/effect/dummy/phased_mob/mirror_walk)

/obj/effect/proc_holder/spell/targeted/mirror_walk
	name = "Mirror Walk"
	desc = "Allows you to traverse invisibly and freely across the station within the realm of the mirror. \
		You can only enter and exit the realm of mirrors when nearby reflective surfaces and items, \
		such as windows, mirrors, and reflective walls or equipment."
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"
	action_background_icon_state = "bg_ecult"
	charge_max = 6 SECONDS
	cooldown_min = 0
	clothes_req = FALSE
	antimagic_flags = NONE
	phase_allowed = TRUE
	range = -1
	include_user = TRUE
	overlay = null

	/// The time it takes to enter the mirror / phase out / enter jaunt.
	var/phase_out_time = 1.5 SECONDS
	/// The time it takes to exit a mirror / phase in / exit jaunt.
	var/phase_in_time = 2 SECONDS
	/// Static typecache of types that are counted as reflective.
	var/static/list/special_reflective_surfaces = typecacheof(list(
		/obj/structure/window,
		/obj/structure/mirror,
	))

/obj/effect/proc_holder/spell/targeted/mirror_walk/on_lose(mob/living/user)
	if(IS_MIRROR_PHASED(user))
		var/obj/effect/dummy/phased_mob/mirror_walk/phase = user.loc
		phase.eject_user()
		qdel(phase)

/obj/effect/proc_holder/spell/targeted/mirror_walk/cast_check(skipcharge = FALSE, mob/user = usr)
	. = ..()
	if(!.)
		return FALSE

	var/we_are_phasing = IS_MIRROR_PHASED(user)
	var/turf/user_turf = get_turf(user)
	var/area/user_area = get_area(user)
	if(!user_turf || !user_area)
		return FALSE // nullspaced?

	if(user_area.area_flags & NOTELEPORT)
		to_chat(user, span_warning("An otherwordly force is preventing you from [we_are_phasing ? "exiting":"entering"] the mirror's realm here!"))
		return FALSE

	if(user_turf.turf_flags & NOJAUNT)
		to_chat(user, span_warning("An otherwordly force is preventing you from [we_are_phasing ? "exiting":"entering"] the mirror's realm here!"))
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/targeted/mirror_walk/cast(list/targets, mob/living/user = usr)
	var/we_are_phasing = IS_MIRROR_PHASED(user)
	var/turf/user_turf = get_turf(user)

	if(!is_reflection_nearby(user_turf))
		to_chat(user, span_warning("There are no reflective surfaces nearby to [we_are_phasing ? "exit":"enter"] the mirror's realm here!"))
		return FALSE

	if(user_turf.is_blocked_turf(exclude_mobs = TRUE))
		to_chat(user, span_warning("Something is blocking you from [we_are_phasing ? "exiting":"entering"] the mirror's realm here!"))
		return FALSE

	// If our loc is a phased mob, we're currently jaunting so we should exit
	if(we_are_phasing)
		try_exit_phase(user)
		return

	// Otherwise try to enter like normal
	try_enter_phase(user)

/obj/effect/proc_holder/spell/targeted/mirror_walk/proc/try_exit_phase(mob/living/user)
	var/obj/effect/dummy/phased_mob/mirror_walk/phase = user.loc
	var/atom/nearby_reflection = is_reflection_nearby(phase)
	if(!nearby_reflection)
		to_chat(user, span_warning("There are no reflective surfaces nearby to exit from the mirror's realm!"))
		return FALSE

	var/turf/phase_turf = get_turf(phase)

	// It would likely be a bad idea to teleport into an ai monitored area (ai sat)
	var/area/phase_area = get_area(phase_turf)
	if(istype(phase_area, /area/station/ai_monitored))
		to_chat(user, span_warning("It's probably not a very wise idea to exit the mirror's realm here."))
		return FALSE

	nearby_reflection.Beam(phase_turf, icon_state = "light_beam", time = phase_in_time)
	nearby_reflection.visible_message(span_warning("[nearby_reflection] begins to shimmer and shake slightly!"))
	if(!do_after(user, phase_in_time, nearby_reflection))
		return

	playsound(get_turf(user), 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	user.visible_message(
		span_boldwarning("[user] phases into reality before your very eyes!"),
		span_notice("You jump out of the reflection coming off of [nearby_reflection], exiting the mirror's realm."),
	)

	// We can move around while phasing in,
	// but we'll always end up where we started it.
	phase.forceMove(phase_turf)
	phase.eject_user()
	qdel(phase)

	// Chilly!
	phase_turf.TakeTemperature(-20)

/obj/effect/proc_holder/spell/targeted/mirror_walk/proc/try_enter_phase(mob/living/user)
	var/atom/nearby_reflection = is_reflection_nearby(user)
	if(!nearby_reflection)
		to_chat(user, span_warning("There are no reflective surfaces nearby to enter the mirror's realm!"))
		return

	user.Beam(nearby_reflection, icon_state = "light_beam", time = phase_out_time)
	nearby_reflection.visible_message(span_warning("[nearby_reflection] begins to shimmer and shake slightly!"))
	if(!do_after(user, phase_out_time, nearby_reflection, IGNORE_USER_LOC_CHANGE|IGNORE_INCAPACITATED))
		return

	playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, TRUE, -1)
	user.visible_message(
		span_boldwarning("[user] phases out of reality, vanishing before your very eyes!"),
		span_notice("You jump into the reflection coming off of [nearby_reflection], entering the mirror's realm."),
	)

	user.SetAllImmobility(0)
	user.setStaminaLoss(0)

	var/obj/effect/dummy/phased_mob/mirror_walk/phase = new(get_turf(nearby_reflection))
	user.forceMove(phase)

/**
 * Goes through all nearby atoms in sight of the
 * passed caster and determines if they are "reflective"
 * for the purpose of us being able to utilize it to enter or exit.
 *
 * Returns an object reference to a "reflective" object in view if one was found,
 * or null if no object was found that was determined to be "reflective".
 */
/obj/effect/proc_holder/spell/targeted/mirror_walk/proc/is_reflection_nearby(atom/caster)
	for(var/atom/thing as anything in view(2, caster))
		if(isitem(thing))
			var/obj/item/item_thing = thing
			if(item_thing.IsReflect())
				return thing

		if(ishuman(thing))
			var/mob/living/carbon/human/human_thing = thing
			if(human_thing.check_reflect())
				return thing

		if(isturf(thing))
			var/turf/turf_thing = thing
			if(turf_thing.turf_flags & NOJAUNT)
				continue
			if(turf_thing.flags_ricochet & RICOCHET_SHINY)
				return thing

		if(is_type_in_typecache(thing, special_reflective_surfaces))
			return thing

	return null

/obj/effect/dummy/phased_mob/mirror_walk
	name = "reflection"

/obj/effect/dummy/phased_mob/mirror_walk/proc/eject_user()
	var/mob/living/jaunter = locate() in contents
	if(QDELETED(jaunter))
		CRASH("[type] called eject_user() without a mob/living within its contents.")

	jaunter.forceMove(drop_location())
