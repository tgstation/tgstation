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

/datum/traitor_objective/final/is_duplicate(datum/traitor_objective/objective_to_compare)
	return TRUE

/datum/traitor_objective/final/uplink_ui_data(mob/user)
	. = ..()
	.["final_objective"] = TRUE
