/datum/traitor_objective_category/final_objective
	name = "Final Objective"
	objectives = list(
		/datum/traitor_objective/final/battlecruiser = 1
	)
	weight = 100

/datum/traitor_objective/final
	abstract_type = /datum/traitor_objective/final
	progression_minimum = 140 MINUTES

	var/progression_points_in_objectives = 20 MINUTES

/// Determines if this final objective can be taken. Should be put into every final objective's generate function.
/datum/traitor_objective/final/proc/can_take_final_objective()
	if(handler.get_completion_progression(/datum/traitor_objective) < progression_points_in_objectives)
		return FALSE
	if(SStraitor.get_taken_count(type) > 0) // Prevents multiple people from ever getting the same final objective.
		return FALSE
	return TRUE

/datum/traitor_objective/final/on_objective_taken(mob/user)
	. = ..()
	handler.maximum_potential_objectives = 0
	for(var/datum/traitor_objective/objective as anything in handler.potential_objectives)
		objective.fail_objective()
	user.playsound_local(get_turf(user), 'sound/traitor/final_objective.ogg', vol = 100, vary = FALSE, channel = CHANNEL_TRAITOR)

/datum/traitor_objective/final/is_duplicate(datum/traitor_objective/objective_to_compare)
	return TRUE

/datum/traitor_objective/final/uplink_ui_data(mob/user)
	. = ..()
	.["final_objective"] = TRUE
