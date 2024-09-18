// Realignment. It's like Fleshmend but solely for stamina damage and stuns. Sec meta
/datum/action/cooldown/spell/realignment
	name = "Realignment"
	desc = "Realign yourself, rapidly regenerating stamina and reducing any stuns or knockdowns. \
		You cannot attack while realigning. Can be casted multiple times in short succession, but each cast lengthens the cooldown."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "adrenal"
	// sound = 'sound/effects/magic/whistlereset.ogg' I have no idea why this was commented out

	school = SCHOOL_FORBIDDEN
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = -6 SECONDS // we're not a wizard spell but we use the levelling mechanic
	spell_max_level = 10 // we can get up to / over a minute duration cd time

	invocation = "R'S'T."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

/datum/action/cooldown/spell/realignment/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/realignment/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/realignment)
	to_chat(cast_on, span_notice("We begin to realign ourselves."))

/datum/action/cooldown/spell/realignment/after_cast(atom/cast_on)
	. = ..()
	// With every cast, our spell level increases for a short time, which goes back down after a period
	// and with every spell level, the cooldown duration of the spell goes up
	if(level_spell())
		var/reduction_timer = max(cooldown_time * spell_max_level * 0.5, 1.5 MINUTES)
		addtimer(CALLBACK(src, PROC_REF(delevel_spell)), reduction_timer)

/datum/action/cooldown/spell/realignment/get_spell_title()
	switch(spell_level)
		if(1, 2)
			return "Hasty " // Hasty Realignment
		if(3, 4)
			return "" // Realignment
		if(5, 6, 7)
			return "Slowed " // Slowed Realignment
		if(8, 9, 10)
			return "Laborious " // Laborious Realignment (don't reach here)

	return ""

/datum/status_effect/realignment
	id = "realigment"
	status_type = STATUS_EFFECT_REFRESH
	duration = 8 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	tick_interval = 0.2 SECONDS
	show_duration = TRUE

/datum/status_effect/realignment/get_examine_text()
	return span_notice("[owner.p_Theyre()] glowing a soft white.")

/datum/status_effect/realignment/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, id)
	owner.add_filter(id, 2, list("type" = "outline", "color" = "#d6e3e7", "size" = 2))
	var/filter = owner.get_filter(id)
	animate(filter, alpha = 127, time = 1 SECONDS, loop = -1)
	animate(alpha = 63, time = 2 SECONDS)
	return TRUE

/datum/status_effect/realignment/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, id)
	owner.remove_filter(id)

/datum/status_effect/realignment/tick(seconds_between_ticks)
	owner.adjustStaminaLoss(-5)
	owner.AdjustAllImmobility(-0.5 SECONDS)

/atom/movable/screen/alert/status_effect/realignment
	name = "Realignment"
	desc = "You're realignment yourself. You cannot attack, but are rapidly regenerating stamina."
	icon_state = "realignment"
