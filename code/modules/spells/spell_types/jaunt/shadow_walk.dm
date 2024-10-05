/datum/action/cooldown/spell/jaunt/shadow_walk
	name = "Shadow Walk"
	desc = "Allows you to hide in the shades, ready to strike at any time. Only allows entry in uninterrupted darkness."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

	spell_requirements = NONE
	jaunt_type = /obj/effect/dummy/phased_mob/shadow

	/// The max amount of lumens on a turf allowed before we can no longer enter jaunt with this
	var/light_threshold = SHADOW_SPECIES_LIGHT_THRESHOLD
	/// time it takes to enter the shade and jaunt.
	var/shadow_delay = 2.5 SECONDS

/datum/action/cooldown/spell/jaunt/shadow_walk/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/spell/jaunt/shadow_walk/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/jaunt/shadow_walk/enter_jaunt(mob/living/jaunter, turf/loc_override)
	var/obj/effect/dummy/phased_mob/shadow/shadow = ..()
	return shadow

/datum/action/cooldown/spell/jaunt/shadow_walk/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/turf/cast_turf = get_turf(owner)
	if(cast_turf.get_lumcount() >= light_threshold)
		if(feedback)
			to_chat(owner, span_warning("It isn't dark enough here!"))
		return FALSE

	if(is_jaunting(owner))
		return TRUE

	return TRUE

/datum/action/cooldown/spell/jaunt/shadow_walk/cast(mob/living/cast_on)
	. = ..()
	if(is_jaunting(cast_on))
		exit_jaunt(cast_on)
		return

	to_chat(owner, span_warning("You begin entering the shadows..."))
	animate(owner, alpha = 0, time = shadow_delay)
	if(!do_after(owner, shadow_delay, owner))
		to_chat(owner, span_warning("You were interrupted!"))
		animate(owner, alpha = 255, time = 0.5 SECONDS)
		return
	else
		owner.alpha = 255 // no need for 0 alpha anymore since we're shunting
		// check again after the windup
		if(!can_cast_spell())
			return FALSE

	playsound(get_turf(owner), 'sound/effects/nightmare_poof.ogg', 50, TRUE, -1, ignore_walls = FALSE)
	cast_on.visible_message(span_boldwarning("[cast_on] melts into the shadows!"))
	cast_on.SetAllImmobility(0)
	cast_on.setStaminaLoss(0, FALSE)
	enter_jaunt(cast_on)

/obj/effect/dummy/phased_mob/shadow
	name = "shadows"
	/// The amount that shadow heals us per SSobj tick (times seconds_per_tick)
	var/healing_rate = 1.5

/obj/effect/dummy/phased_mob/shadow/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/shadow/process(seconds_per_tick)
	if(!jaunter || jaunter.loc != src)
		qdel(src)
		return

	if(!QDELETED(jaunter) && isliving(jaunter)) //heal in the dark
		var/mob/living/living_jaunter = jaunter
		living_jaunter.heal_overall_damage(brute = (healing_rate * seconds_per_tick), burn = (healing_rate * seconds_per_tick), required_bodytype = BODYTYPE_ORGANIC)

/obj/effect/dummy/phased_mob/shadow/phased_check(mob/living/user, direction)
	. = ..()
	if(. && isspaceturf(.))
		to_chat(user, span_warning("It really would not be wise to go into space."))
		return FALSE

/obj/effect/dummy/phased_mob/shadow/eject_jaunter(forced_out = FALSE)
	var/turf/reveal_turf = get_turf(src)

	if(!reveal_turf)
		return

	reveal_turf.visible_message(span_boldwarning("[jaunter] emerges from the darkness!"))
	playsound(reveal_turf, 'sound/effects/nightmare_reappear.ogg', 50, TRUE, -1, ignore_walls = FALSE)

	return ..()

