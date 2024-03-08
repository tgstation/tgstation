/**
 * Attached to a mob with an AI controller, simply sets a flag on whether or not to run away based on current health values.
 */
/datum/element/ai_flee_while_injured
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Health value to end fleeing if at or above
	var/stop_fleeing_at
	/// Health value to start fleeing if at or below
	var/start_fleeing_below

/datum/element/ai_flee_while_injured/Attach(datum/target, stop_fleeing_at = 1, start_fleeing_below = 0.5)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/living_target = target
	if(!living_target.ai_controller)
		return ELEMENT_INCOMPATIBLE
	src.stop_fleeing_at = stop_fleeing_at
	src.start_fleeing_below = start_fleeing_below
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_changed))
	on_health_changed(target)

/datum/element/ai_flee_while_injured/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_HEALTH_UPDATE)

/// When the mob's health changes, check what the blackboard state should be
/datum/element/ai_flee_while_injured/proc/on_health_changed(mob/living/source)
	SIGNAL_HANDLER

	if (isnull(source.ai_controller))
		return

	var/current_health_percentage = source.health / source.maxHealth
	if (source.ai_controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		if (current_health_percentage > start_fleeing_below)
			return
		source.ai_controller.CancelActions()
		source.ai_controller.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, FALSE)
		return

	if (current_health_percentage < stop_fleeing_at)
		return
	source.ai_controller.CancelActions() // Stop fleeing go back to whatever you were doing
	source.ai_controller.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, TRUE)
