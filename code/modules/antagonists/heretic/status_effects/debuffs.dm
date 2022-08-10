// VOID CHILL
/datum/status_effect/void_chill
	id = "void_chill"
	alert_type = /atom/movable/screen/alert/status_effect/void_chill
	duration = 8 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 0.5 SECONDS
	/// The amount the victim's body temperature changes each tick() in kelvin. Multiplied by TEMPERATURE_DAMAGE_COEFFICIENT.
	var/cooling_per_tick = -14

/atom/movable/screen/alert/status_effect/void_chill
	name = "Void Chill"
	desc = "There's something freezing you from within and without. You've never felt cold this oppressive before..."
	icon_state = "void_chill"

/datum/status_effect/void_chill/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/void_chill, update = TRUE)
	return TRUE

/datum/status_effect/void_chill/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/void_chill, update = TRUE)

/datum/status_effect/void_chill/tick()
	owner.adjust_bodytemperature(cooling_per_tick * TEMPERATURE_DAMAGE_COEFFICIENT)

/datum/status_effect/void_chill/major
	duration = 10 SECONDS
	cooling_per_tick = -20

/datum/movespeed_modifier/void_chill
	multiplicative_slowdown = 0.3

// AMOK
/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	. = ..()
	to_chat(owner, span_boldwarning("You feel filled with a rage that is not your own!"))

/datum/status_effect/amok/tick()
	. = ..()
	var/prev_combat_mode = owner.combat_mode
	owner.set_combat_mode(TRUE)

	var/list/mob/living/targets = list()
	for(var/mob/living/potential_target in oview(owner, 1))
		if(IS_HERETIC_OR_MONSTER(potential_target))
			continue
		targets += potential_target
	if(LAZYLEN(targets))
		owner.log_message(" attacked someone due to the amok debuff.", LOG_ATTACK) //the following attack will log itself
		owner.ClickOn(pick(targets))
	owner.set_combat_mode(prev_combat_mode)
