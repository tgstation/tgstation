

/**
 * ## smart objectives
 *
 * Smart objectives are objectives for traitors that signal into their targets to confirm when the target dies
 * This means they know when they are complete before roundend, and let an attached antag datum know
 * (antag datums that care for smart objectives need to listen into them!)
 */
/datum/objective/smart
	///the payout for completing this objective
	var/black_telecrystal_reward = 0


/**
 * ## Smart destroy AI
 *
 * It achieves when the AI is sent into deep space, or killed.
 * It unachieved when the AI is back into local space, or revived.
 */
/datum/objective/smart/destroy_ai
	name = "destroy AI"
	martyr_compatible = TRUE
	black_telecrystal_reward = 8

/datum/objective/smart/destroy_ai/find_target(dupe_search_range)
	var/list/possible_targets = active_ais(check_mind = TRUE)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/smart/destroy_ai/post_find_target()
	RegisterSignal(target, COMSIG_LIVING_DEATH, .proc/on_death)
	RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/on_z_level_changed)

/datum/objective/smart/destroy_ai/Destroy(force)
	. = ..()
	UnregisterSignal(target, list(COMSIG_LIVING_DEATH))

/datum/objective/smart/destroy_ai/proc/on_death(datum/target, gibbed)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_SMART_OBJECTIVE_ACHIEVED)

/datum/objective/smart/destroy_ai/proc/on_z_level_changed(datum/target, old_z, new_z)
	SIGNAL_HANDLER

	if(new_z > 6)
		SEND_SIGNAL(src, COMSIG_SMART_OBJECTIVE_ACHIEVED)
	else
		SEND_SIGNAL(src, COMSIG_SMART_OBJECTIVE_UNACHIEVED)
