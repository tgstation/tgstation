/datum/action/cooldown/spell/jaunt/shadow_walk
	name = "Shadow Walk"
	desc = "Grants unlimited movement in darkness."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"

	spell_requirements = NONE
	jaunt_type = /obj/effect/dummy/phased_mob/shadow

/datum/action/cooldown/spell/jaunt/shadow_walk/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))

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
	/// When cooldown is active, you are prevented from moving into tiles that would eject you from your jaunt
	COOLDOWN_DECLARE(light_step_cooldown)
	/// Has the jaunter recently recieved a warning about light?
	var/light_alert_given = FALSE

/obj/effect/dummy/phased_mob/shadow/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/shadow/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/dummy/phased_mob/shadow/process(delta_time)
	var/turf/T = get_turf(src)
	if(!jaunter || jaunter.loc != src)
		qdel(src)
		return

	if(check_light_level(T))
		eject_jaunter(TRUE)

	if(!QDELETED(jaunter) && isliving(jaunter)) //heal in the dark
		var/mob/living/living_jaunter = jaunter
		living_jaunter.heal_overall_damage((healing_rate * delta_time), (healing_rate * delta_time), BODYTYPE_ORGANIC)

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
		playsound(reveal_turf, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)

	return ..()

/**
 * Checks the light level. If above the minimum acceptable amount (0.2), returns TRUE.
 *
 * Checks the light level of a given location to see if it is too bright to
 * continue a jaunt in. Returns FALSE if it's acceptably dark, and TRUE if it is too bright.
 *
 * * location_to_check - The location to have its light level checked.
 */

/obj/effect/dummy/phased_mob/shadow/proc/check_light_level(location_to_check)
	var/turf/T = get_turf(location_to_check)
	var/light_amount = T.get_lumcount()
	if(light_amount > 0.2) // jaunt ends
		return TRUE

/**
 * Checks if the user should recieve a warning that they're moving into light.
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
