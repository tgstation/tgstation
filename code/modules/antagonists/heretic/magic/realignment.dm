// Realignment. It's like Fleshmend but solely for stamina damage and stuns. Sec meta
/datum/action/cooldown/spell/realignment
	name = "Realignment"
	desc = "Realign yourself, rapidly regenerating stamina and reducing any stuns or knockdowns. \
		You cannot attack while realigning."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/obj/implants.dmi'
	button_icon_state = "adrenal"
	// sound = 'sound/magic/whistlereset.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 60 SECONDS

	invocation = "R'S'T."
	invocation_type = INVOCATION_SHOUT

/datum/action/cooldown/spell/realignment/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/realignment/cast(mob/living/cast_on)
	cast_on.apply_status_effect(/datum/status_effect/realignment)
	to_chat(cast_on, span_notice("We begin to realign ourselves."))

/datum/status_effect/realignment
	id = "realigment"
	status_type = STATUS_EFFECT_REFRESH
	duration = 6 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	tick_interval = 0.2 SECONDS

/datum/status_effect/realignment/get_examine_text()
	return span_notice("[owner.p_they(TRUE)] [owner.p_are()] glowing a bright white!")

/datum/status_effect/realignment/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, id)
	owner.add_filter(id, 2, list("type" = "outline", "color" = glow_color, "size" = 1))
	var/filter = owner.get_filter(id)
	animate(filter, alpha = 127, time = 1 SECONDS, loop = -1)
	animate(alpha = 63, time = 2 SECONDS)
	return TRUE

/datum/status_effect/realignment/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM)
	owner.remove_filter(id)

/datum/status_effect/realignment/tick(delta_time, times_fired)
	owner.adjustStaminaLoss(-5)
	owner.AdjustAllImmobility(-0.5 SECONDS)

/atom/movable/screen/alert/status_effect/realignment
	name = "Realignment"
	desc = "You're realignment yourself. You cannot attack, but are rapidly regenerating stamina."
	icon_state = "realignment"
