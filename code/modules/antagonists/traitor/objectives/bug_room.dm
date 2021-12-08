/datum/traitor_objective/bug_room
	name = "Bug \[DEPARTMENT HEAD]'s office"
	description = "This is an empty objective slot. Taking this objective will replace it with an available objective if possible."

/datum/traitor_objective/bug_room/generate_objective(datum/mind/generating_for)
	message_admins("Based")
	return TRUE

/datum/traitor_objective/bug_room/is_duplicate(datum/traitor_objective/bug_room/objective_to_compare)
	return FALSE
