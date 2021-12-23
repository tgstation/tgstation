/datum/traitor_objective_category/final_objective
	name = "Final Objective"
	objectives = list(
		/datum/traitor_objective/final/romerol = 1,
		///datum/traitor_objective/final/battlecruiser = 1, - when ready, untick battlecruiser.dm and uncomment this
	)
	weight = 100

/datum/traitor_objective/final
	abstract_type = /datum/traitor_objective/final
	progression_minimum = 140 MINUTES

	var/progression_points_in_objectives = 20 MINUTES

/// Determines if this final objective can be taken. Should be put into every final objective's generate function.
/datum/traitor_objective/final/proc/can_take_final_objective()
	var/total_progression = 0
	for(var/datum/traitor_objective/objective as anything in handler.completed_objectives)
		total_progression += objective.progression_reward
	if(total_progression < progression_points_in_objectives)
		return FALSE
	return TRUE

/datum/traitor_objective/final/on_objective_taken(mob/user)
	handler.maximum_potential_objectives = 0
	for(var/datum/traitor_objective/objective as anything in handler.potential_objectives)
		objective.fail_objective(FALSE)

/datum/traitor_objective/final/is_duplicate(datum/traitor_objective/objective_to_compare)
	return TRUE

/datum/traitor_objective/final/uplink_ui_data(mob/user)
	. = ..()
	.["final_objective"] = TRUE
