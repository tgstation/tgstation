/datum/action/cooldown/spell/jaunt/shadow_walk
	name = "Shadow Walk"
	desc = "Grants unlimited movement in darkness."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

	spell_requirements = NONE
	jaunt_type = /obj/effect/dummy/phased_mob/shadow

	/// The max amount of lumens on a turf allowed before we can no longer enter jaunt with this
	var/light_threshold = SHADOW_SPECIES_LIGHT_THRESHOLD

/datum/action/cooldown/spell/jaunt/shadow_walk/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/spell/jaunt/shadow_walk/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/jaunt/shadow_walk/enter_jaunt(mob/living/jaunter, turf/loc_override)
	var/obj/effect/dummy/phased_mob/shadow/shadow = ..()
	if(istype(shadow))
		shadow.light_max = light_threshold
	return shadow

/datum/action/cooldown/spell/jaunt/shadow_walk/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(is_jaunting(owner))
		return TRUE
	var/turf/cast_turf = get_turf(owner)
	if(cast_turf.get_lumcount() >= light_threshold)
		if(feedback)
			to_chat(owner, span_warning("It isn't dark enough here!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/jaunt/shadow_walk/cast(mob/living/cast_on)
	. = ..()
	if(is_jaunting(cast_on))
		exit_jaunt(cast_on)
		return

	playsound(get_turf(owner), 'sound/effects/nightmare_poof.ogg', 50, TRUE, -1, ignore_walls = FALSE)
	cast_on.visible_message(span_boldwarning("[cast_on] melts into the shadows!"))
	cast_on.SetAllImmobility(0)
	cast_on.setStaminaLoss(0, FALSE)
	enter_jaunt(cast_on)

/obj/effect/dummy/phased_mob/shadow
	name = "shadows"
	phased_mob_icon_state = "purple_laser"
	/// Max amount of light permitted before being kicked out
	var/light_max = SHADOW_SPECIES_LIGHT_THRESHOLD
	/// The amount that shadow heals us per SSobj tick (times seconds_per_tick)
	var/healing_rate = 1.5
	/// When cooldown is active, you are prevented from moving into tiles that would eject you from your jaunt
	COOLDOWN_DECLARE(light_step_cooldown)
	/// Has the jaunter recently received a warning about light?
	var/light_alert_given = FALSE

/obj/effect/dummy/phased_mob/shadow/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/shadow/process(seconds_per_tick)
	var/turf/T = get_turf(src)
	if(!jaunter || jaunter.loc != src)
		qdel(src)
		return

	if(check_light_level(T))
		eject_jaunter(TRUE)

	if(!QDELETED(jaunter) && isliving(jaunter)) //heal in the dark
		var/mob/living/living_jaunter = jaunter
		living_jaunter.heal_overall_damage(brute = (healing_rate * seconds_per_tick), burn = (healing_rate * seconds_per_tick), required_bodytype = BODYTYPE_ORGANIC)

/obj/effect/dummy/phased_mob/shadow/relaymove(mob/living/user, direction)
	var/turf/oldloc = loc
	. = ..()
	if(loc != oldloc)
		if(check_light_level(loc))
			eject_jaunter(TRUE)

/obj/effect/dummy/phased_mob/shadow/phased_check(mob/living/user, direction)
	. = ..()
	if(. && isspaceturf(.))
		to_chat(user, span_warning("It really would not be wise to go into space."))
		return FALSE
	if(check_light_level(.))
		if(!light_step_warning())
			return FALSE

/obj/effect/dummy/phased_mob/shadow/eject_jaunter(forced_out = FALSE)
	var/turf/reveal_turf = get_turf(src)

	if(istype(reveal_turf))
		if(forced_out)
			reveal_turf.visible_message(span_boldwarning("[jaunter] is revealed by the light!"))
		else
			reveal_turf.visible_message(span_boldwarning("[jaunter] emerges from the darkness!"))
		playsound(reveal_turf, 'sound/effects/nightmare_reappear.ogg', 50, TRUE, -1, ignore_walls = FALSE)

	return ..()

/**
 * Checks the light level. If above the minimum acceptable amount (0.2), returns TRUE.
 *
 * Checks the light level of a given location to see if it is too bright to
 * continue a jaunt in. Returns FALSE if it's acceptably dark, and TRUE if it is too bright.
 *
 * * location_to_check - The location to have its light level checked.
 */

/obj/effect/dummy/phased_mob/shadow/proc/check_light_level(atom/location_to_check)
	var/turf/light_turf = get_turf(location_to_check)
	return light_turf.get_lumcount() > light_max // jaunt ends on TRUE

/**
 * Checks if the user should receive a warning that they're moving into light.
 *
 * Checks the cooldown for the warning message on moving into the light.
 * If the message has been displayed, and the cooldown (delay period) is complete, returns TRUE.
 */

/obj/effect/dummy/phased_mob/shadow/proc/light_step_warning()
	if(!light_alert_given) //Give the user a warning that they're leaving the darkness
		balloon_alert(jaunter, "leaving the shadows...")
		light_alert_given = TRUE
		COOLDOWN_START(src, light_step_cooldown, 0.75 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(reactivate_light_alert)), 1 SECONDS) //You get a .5 second window to bypass the warning before it comes back
		return FALSE

	if(!COOLDOWN_FINISHED(src, light_step_cooldown))
		return FALSE

	light_alert_given = FALSE
	return TRUE //Our jaunter is ignoring the warning, so we proceed

/**
 * Sets light_alert_given to false.
 *
 * Sets light_alert_given to false, making the light alert pop up and intercept movement once again.
 * Added in its own proc to reset the alert without having to call light_step_warning().
 */

/obj/effect/dummy/phased_mob/shadow/proc/reactivate_light_alert()
	light_alert_given = FALSE
