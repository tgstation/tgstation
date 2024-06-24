/datum/objective
	/// The default opt in level of this objective. Only targets with opt in above or at this will be considered for this objective.
	var/default_opt_in_level = OPT_IN_YES_KILL

/// Simple getter for [default_opt_in_level]. Use for custom behavior.
/datum/objective/proc/get_opt_in_level(datum/mind/target_mind)
	return default_opt_in_level

/// Returns whether or not our opt in levels/variables are correct for the target. If true, they can be picked as a target.
/datum/objective/proc/opt_in_valid(datum/mind/target_mind)
	return (get_opt_in_level(target_mind) <= target_mind.get_effective_opt_in_level())

// ROUND REMOVE
/datum/objective/maroon
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE

/datum/objective/assassinate/paradox_clone
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE

/datum/objective/capture
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE

/datum/objective/absorb
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE

/datum/objective/absorb_changeling
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE

/datum/objective/sacrifice
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE

/datum/objective/debrain
	default_opt_in_level = OPT_IN_YES_ROUND_REMOVE

// KILL

/datum/objective/assassinate
	default_opt_in_level = OPT_IN_YES_KILL

/datum/objective/destroy
	default_opt_in_level = OPT_IN_YES_KILL

/datum/objective/mutiny
	default_opt_in_level = OPT_IN_YES_KILL

// TEMP

/datum/objective/protect
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/protect/nonhuman
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/steal_n_of_type
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/steal
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/escape/escape_with_identity
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/jailbreak
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/contract
	default_opt_in_level = OPT_IN_YES_TEMP

/datum/objective/contract/opt_in_valid(datum/mind/target_mind)
	var/datum/job/target_job = target_mind.assigned_role
	if (!target_job?.contractable)
		return FALSE

	return ..()
