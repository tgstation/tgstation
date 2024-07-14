/datum/status_effect/slime_regen_cooldown
	id = "slime_regen_cooldown"
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = -1
	alert_type = null
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN
	/// The multiplier applied to the effect of a regen extract while this cooldown is active.
	/// As multiple cooldowns can be active at the same time, these multipliers stack, resulting in exponentially diminishing returns.
	var/multiplier = 1

/datum/status_effect/slime_regen_cooldown/on_creation(mob/living/new_owner, multiplier = 1, duration = 45 SECONDS)
	src.multiplier = multiplier
	src.duration = duration
	return ..()

/datum/status_effect/slime_regen_cooldown/on_apply()
	RegisterSignal(owner, COMSIG_SLIME_REGEN_CALC, PROC_REF(apply_multiplier))
	return TRUE

/datum/status_effect/slime_regen_cooldown/on_remove()
	UnregisterSignal(owner, COMSIG_SLIME_REGEN_CALC)

/datum/status_effect/slime_regen_cooldown/proc/apply_multiplier(datum/source, multiplier_ptr)
	SIGNAL_HANDLER
	*multiplier_ptr *= multiplier
