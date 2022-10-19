/datum/action/cooldown/spell/jaunt/shadow_walk
	name = "Shadow Walk"
	desc = "Grants unlimited movement in darkness."
	background_icon_state = "bg_alien"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

	spell_requirements = NONE
	jaunt_type = /obj/effect/dummy/phased_mob/shadow

/datum/action/cooldown/spell/jaunt/shadow_walk/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, .proc/update_icon_on_signal)

/datum/action/cooldown/spell/jaunt/shadow_walk/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/jaunt/shadow_walk/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(is_jaunting(owner))
		return TRUE
	var/turf/cast_turf = get_turf(owner)
	if(cast_turf.get_lumcount() >= SHADOW_SPECIES_LIGHT_THRESHOLD)
		if(feedback)
			to_chat(owner, span_warning("It isn't dark enough here!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/jaunt/shadow_walk/cast(mob/living/cast_on)
	. = ..()
	if(is_jaunting(cast_on))
		exit_jaunt(cast_on)
		return

	playsound(get_turf(owner), 'sound/magic/ethereal_enter.ogg', 50, TRUE, -1)
	cast_on.visible_message(span_boldwarning("[cast_on] melts into the shadows!"))
	cast_on.SetAllImmobility(0)
	cast_on.setStaminaLoss(0, FALSE)
	enter_jaunt(cast_on)

/obj/effect/dummy/phased_mob/shadow
	name = "shadows"
	/// The amount that shadow heals us per SSobj tick (times delta_time)
	var/healing_rate = 1.5

/obj/effect/dummy/phased_mob/shadow/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/shadow/process(delta_time)
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(!jaunter || jaunter.loc != src)
		qdel(src)
		return

	if(light_amount < 0.2 && !QDELETED(jaunter) && isliving(jaunter)) //heal in the dark
		var/mob/living/living_jaunter = jaunter
		living_jaunter.heal_overall_damage((healing_rate * delta_time), (healing_rate * delta_time), 0, BODYTYPE_ORGANIC)

	check_light_level()

/obj/effect/dummy/phased_mob/shadow/relaymove(mob/living/user, direction)
	var/turf/oldloc = loc
	. = ..()
	if(loc != oldloc)
		check_light_level()

/obj/effect/dummy/phased_mob/shadow/phased_check(mob/living/user, direction)
	. = ..()
	if(. && isspaceturf(.))
		to_chat(user, span_warning("It really would not be wise to go into space."))
		return FALSE

/obj/effect/dummy/phased_mob/shadow/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.2) // jaunt ends
		eject_jaunter(TRUE)

/obj/effect/dummy/phased_mob/shadow/eject_jaunter(forced_out = FALSE)
	var/turf/reveal_turf = get_turf(src)

	if(istype(reveal_turf))
		if(forced_out)
			reveal_turf.visible_message(span_boldwarning("[jaunter] is revealed by the light!"))
		else
			reveal_turf.visible_message(span_boldwarning("[jaunter] emerges from the darkness!"))
		playsound(reveal_turf, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)

	return ..()
