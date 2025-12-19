/// Status effect that modifies the critical health threshold of a mob.
/// This allows reagents and other effects to lower the threshold at which a mob enters critical state.
/datum/status_effect/crit_threshold_modifier
	id = "crit_threshold_modifier"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The original crit_threshold value before modification
	var/original_crit_threshold
	/// The amount to reduce crit_threshold by (positive value = lower threshold)
	var/reduction_amount

/datum/status_effect/crit_threshold_modifier/on_creation(mob/living/new_owner, reduction = BRAVE_BULL_CRIT_THRESHOLD_REDUCTION)
	reduction_amount = reduction
	. = ..()

/datum/status_effect/crit_threshold_modifier/on_apply()
	. = ..()
	if(!owner)
		return FALSE

	original_crit_threshold = owner.crit_threshold
	owner.crit_threshold -= reduction_amount
	return TRUE

/datum/status_effect/crit_threshold_modifier/on_remove()
	. = ..()
	if(owner && !isnull(original_crit_threshold))
		owner.crit_threshold = original_crit_threshold

/datum/status_effect/crit_threshold_modifier/refresh(effect, ...)
	. = ..()
	// args[1] = effect (typepath), args[2] = mob, args[3] = reduction amount (if provided)
	if(length(args) >= 3 && isnum(args[3]))
		var/new_reduction = args[3]
		// Use the maximum reduction amount (stronger effect wins)
		if(new_reduction > reduction_amount)
			// Update to the new, larger reduction
			if(owner && !isnull(original_crit_threshold))
				// Restore original, then apply new reduction
				owner.crit_threshold = original_crit_threshold
			reduction_amount = new_reduction

	// When refreshed, we need to reapply the reduction
	// Store the current original if we don't have one yet
	if(isnull(original_crit_threshold) && owner)
		original_crit_threshold = owner.crit_threshold
	// Reapply the reduction
	if(owner)
		owner.crit_threshold = original_crit_threshold - reduction_amount

