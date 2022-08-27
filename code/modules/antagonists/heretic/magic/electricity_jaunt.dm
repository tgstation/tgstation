/datum/action/cooldown/spell/jaunt/electricity
	name = "Wire Walk"
	desc = "Allows you to traverse powered cables."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

	cooldown_time = 6 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/electricity
	spell_requirements = NONE

	/// A cache of all nearby cabes when we are casted
	var/list/nearby_cables_cached = list()

/datum/action/cooldown/spell/jaunt/electricity/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	find_nearby_cable(cast_on)

	if(!length(nearby_cables_cached))
		cast_on.balloon_alert(cast_on, "no nearby powered cables!")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/jaunt/electricity/cast(atom/cast_on)
	. = ..()

	var/obj/structure/cable/jaunting_into = pick(nearby_cables_cached)
	nearby_cables_cached.Cut()

	if(is_jaunting(cast_on))
		exit_jaunt(cast_on, get_turf(jaunting_into))
	else
		enter_jaunt(cast_on, get_turf(jaunting_into))


/datum/action/cooldown/spell/jaunt/electricity/proc/find_nearby_cable(atom/center)
	nearby_cables_cached.Cut()
	for(var/obj/structure/cable/cable in range(1, center))
		if(!cable.powernet || cable.powernet.avail <= 0)
			continue

		nearby_cables_cached += cable

/obj/effect/dummy/phased_mob/electricity
	name = "spark"

/obj/effect/dummy/phased_mob/electricity/Initialize(mapload, atom/movable/jaunter)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/electricity/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/electricity/process(delta_time)
	if(check_turf_for_cable(get_turf(src)))
		continue

	eject_jaunter()

/obj/effect/dummy/phased_mob/electricity/phased_check(mob/living/user, direction)
	var/turf/new_loc = ..()
	if(!new_loc)
		return

	if(!check_turf_for_cable(new_loc))
		return

	return new_loc

/obj/effect/dummy/phased_mob/electricity/proc/check_turf_for_cable(turf/to_check)
	var/obj/structure/cable/walking_in = locate() in new_loc
	if(!walking_in)
		to_check.balloon_alert(user, "no cable!")
		return FALSE

	if(!walking_in.powernet || walking_in.powernet.avail <= 0)
		new_loc.balloon_alert(user, "no cable!")
		return FALSE

	return TRUE
