/datum/traitor_objective_category/final_objective
	name = "Final Objective"
	objectives = list(
		/datum/traitor_objective/ultimate/romerol = 1,
		/datum/traitor_objective/ultimate/battlecruiser = 1,
		/datum/traitor_objective/ultimate/space_dragon = 1,
		/datum/traitor_objective/ultimate/supermatter_cascade = 1,
		/datum/traitor_objective/ultimate/infect_ai = 1,
	)
	weight = 100

/datum/traitor_objective/ultimate
	abstract_type = /datum/traitor_objective/ultimate
	progression_minimum = 140 MINUTES

	var/progression_points_in_objectives = 20 MINUTES

/// Determines if this final objective can be taken. Should be put into every final objective's generate function.
/datum/traitor_objective/ultimate/can_generate_objective(generating_for, list/possible_duplicates)
	if(handler.get_completion_progression(/datum/traitor_objective) < progression_points_in_objectives)
		return FALSE
	if(SStraitor.get_taken_count(type) > 0) // Prevents multiple people from ever getting the same final objective.
		return FALSE
	if(length(possible_duplicates) > 0)
		return FALSE
	return TRUE

/datum/traitor_objective/ultimate/on_objective_taken(mob/user)
	. = ..()
	handler.maximum_potential_objectives = 0
	for(var/datum/traitor_objective/objective as anything in handler.potential_objectives)
		objective.fail_objective()
	user.playsound_local(get_turf(user), 'sound/traitor/final_objective.ogg', vol = 100, vary = FALSE, channel = CHANNEL_TRAITOR)
	handler.final_objective = name

/datum/traitor_objective/ultimate/uplink_ui_data(mob/user)
	. = ..()
	.["final_objective"] = TRUE
