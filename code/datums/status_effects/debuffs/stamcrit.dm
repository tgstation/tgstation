/datum/status_effect/incapacitating/stamcrit
	status_type = STATUS_EFFECT_UNIQUE
	// Lasts until we go back to 0 stamina, which is handled by the mob
	duration = -1
	tick_interval = -1
	/// Cooldown between displaying warning messages that we hit diminishing returns
	COOLDOWN_DECLARE(warn_cd)
	/// A counter that tracks every time we've taken enough damage to trigger diminishing returns
	var/diminishing_return_counter = 0

/datum/status_effect/incapacitating/stamcrit/on_creation(mob/living/new_owner, set_duration)
	. = ..()
	if(!.)
		return .

	// This should be in on apply but we need it to happen AFTER being added to the mob
	// (Because we need to wait until the status effect is in their status effect list, or we'll add two)
	if(owner.getStaminaLoss() < 120)
		// Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		owner.adjustStaminaLoss(30, FALSE)

	// Same
	RegisterSignal(owner, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, PROC_REF(update_diminishing_return))
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(check_remove))

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
	return ..()

/datum/status_effect/incapacitating/stamcrit/proc/update_diminishing_return(datum/source, type, amount, forced)
	SIGNAL_HANDLER
	if(amount <= 0 || forced)
		return NONE
	// Here we fake the effect of having diminishing returns
	// We don't actually decrease incoming stamina damage because that would be pointless, the mob is at stam damage cap anyways
	// Instead we just "ignore" the damage if we have a sufficiently high diminishing return counter
	var/mod_amount = ceil(sqrt(amount) / 2) - diminishing_return_counter
	// We check base amount not mod_amount because we still want to up tick it even if we've already got a high counter
	// We also only uptick it after calculating damage so we start ticking up after the damage and not before
	switch(amount)
		if(5 to INFINITY)
			diminishing_return_counter += 1
		if(2 to 5) // Prevent chems from skyrockting DR
			diminishing_return_counter += 0.05
	if(mod_amount > 0)
		return NONE

	if(COOLDOWN_FINISHED(src, warn_cd) && owner.stat == CONSCIOUS)
		to_chat(owner, span_notice("You start to recover from the exhaustion!"))
		owner.visible_message(span_warning("[owner] starts to recover from the exhaustion!"), ignored_mobs = owner)
		COOLDOWN_START(src, warn_cd, 2.5 SECONDS)

	return COMPONENT_IGNORE_CHANGE

/datum/status_effect/incapacitating/stamcrit/proc/check_remove(datum/source, ...)
	SIGNAL_HANDLER
	if(owner.maxHealth - owner.getStaminaLoss() > owner.crit_threshold)
		qdel(src)
