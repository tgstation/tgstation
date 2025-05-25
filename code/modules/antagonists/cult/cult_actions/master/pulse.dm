/datum/action/innate/cult/master/pulse
	name = "Eldritch Pulse"
	desc = "Seize upon a fellow cultist or cult structure and teleport it to a nearby location."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "arcane_barrage"
	click_action = TRUE
	enable_text = span_cult("You prepare to tear through the fabric of reality... <b>Click a target to sieze them!</b>")
	disable_text = span_cult("You cease your preparations.")
	/// Weakref to whoever we're currently about to toss
	var/datum/weakref/throwee_ref
	/// Cooldown of the ability
	var/pulse_cooldown_duration = 15 SECONDS
	/// The actual cooldown tracked of the action
	COOLDOWN_DECLARE(pulse_cooldown)

/datum/action/innate/cult/master/pulse/IsAvailable(feedback = FALSE)
	return ..() && COOLDOWN_FINISHED(src, pulse_cooldown)

/datum/action/innate/cult/master/pulse/InterceptClickOn(mob/living/clicker, params, atom/clicked_on)
	var/turf/clicker_turf = get_turf(clicker)
	if(!isturf(clicker_turf))
		return FALSE

	if(!(clicked_on in view(7, clicker_turf)))
		return FALSE

	if(clicked_on == clicker)
		return FALSE

	return ..()

/datum/action/innate/cult/master/pulse/do_ability(mob/living/clicker, atom/clicked_on)
	var/atom/throwee = throwee_ref?.resolve()
	if(throwee && QDELING(throwee))
		to_chat(clicker, span_cult("You lost your target!"))
		throwee = null
		throwee_ref = null
		return FALSE

	if(throwee)
		if(get_dist(throwee, clicked_on) >= 16)
			to_chat(clicker, span_cult("You can't teleport [clicked_on.p_them()] that far!"))
			return FALSE

		var/turf/throwee_turf = get_turf(throwee)

		playsound(throwee_turf, 'sound/effects/magic/exit_blood.ogg')
		new /obj/effect/temp_visual/cult/sparks(throwee_turf, clicker.dir)
		throwee.visible_message(
			span_warning("A pulse of magic whisks [throwee] away!"),
			span_cult("A pulse of blood magic whisks you away..."),
		)

		if(!do_teleport(throwee, clicked_on, channel = TELEPORT_CHANNEL_CULT))
			to_chat(clicker, span_cult("The teleport fails!"))
			throwee.visible_message(
				span_warning("...Except they don't go very far"),
				span_cult("...Except you don't appear to have moved very far."),
			)
			return FALSE

		throwee_turf.Beam(clicked_on, icon_state = "sendbeam", time = 0.4 SECONDS)
		new /obj/effect/temp_visual/cult/sparks(get_turf(clicked_on), clicker.dir)
		throwee.visible_message(
			span_warning("[throwee] appears suddenly in a pulse of magic!"),
			span_cult("...And you appear elsewhere."),
		)

		COOLDOWN_START(src, pulse_cooldown, pulse_cooldown_duration)
		to_chat(clicker, span_cult("A pulse of blood magic surges through you as you shift [throwee] through time and space."))
		clicker.click_intercept = null
		throwee_ref = null
		build_all_button_icons()
		addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), pulse_cooldown_duration + 1)

		return TRUE

	if(isliving(clicked_on))
		var/mob/living/living_clicked = clicked_on
		if(!IS_CULTIST(living_clicked))
			return FALSE
		SEND_SOUND(clicker, sound('sound/items/weapons/thudswoosh.ogg'))
		to_chat(clicker, span_cult_bold("You reach through the veil with your mind's eye and seize [clicked_on]! <b>Click anywhere nearby to teleport [clicked_on.p_them()]!</b>"))
		throwee_ref = WEAKREF(clicked_on)
		return TRUE

	if(istype(clicked_on, /obj/structure/destructible/cult))
		to_chat(clicker, span_cult_bold("You reach through the veil with your mind's eye and lift [clicked_on]! <b>Click anywhere nearby to teleport it!</b>"))
		throwee_ref = WEAKREF(clicked_on)
		return TRUE
	return FALSE
