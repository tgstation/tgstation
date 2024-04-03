/datum/status_effect/incapacitating/stamcrit
	status_type = STATUS_EFFECT_REFRESH
	duration = STAMINA_REGEN_BLOCK_TIME

	var/diminishing_return_counter = 0

/datum/status_effect/incapacitating/stamcrit/on_creation(mob/living/new_owner, set_duration)
	. = ..()
	if(!.)
		return .

	// This should be in on apply but we need it to happen AFTER being added to the mob

	if(owner.getStaminaLoss() < 120)
		// Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		owner.adjustStaminaLoss(30, FALSE)

	// Same

	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(check_remove))
	RegisterSignal(owner, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(update_diminishing_return))

/datum/status_effect/incapacitating/stamcrit/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	if(owner.check_stun_immunity(CANKNOCKDOWN))
		return FALSE

	. = ..()
	if(!.)
		return .

	if(owner.stat == CONSCIOUS)
		to_chat(owner, span_notice("You're too exhausted to keep going..."))
	owner.add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED), STAMINA)
	return .

/datum/status_effect/incapacitating/stamcrit/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE)
	UnregisterSignal(owner, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE)
	owner.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED), STAMINA)
	owner.adjustStaminaLoss(-INFINITY)
	return ..()

/datum/status_effect/incapacitating/stamcrit/proc/check_remove(datum/source, ...)
	SIGNAL_HANDLER
	if(owner.maxHealth - owner.getStaminaLoss() > owner.crit_threshold)
		qdel(src)

/datum/status_effect/incapacitating/stamcrit/proc/update_diminishing_return(datum/source, type, amount, forced)
	SIGNAL_HANDLER
	if(amount <= 0 || forced)
		return NONE
	var/mod_amount = ceil(sqrt(amount) / 2) - diminishing_return_counter
	if(amount > 5)
		diminishing_return_counter++
	return mod_amount <= 0 ? COMPONENT_IGNORE_CHANGE : NONE
