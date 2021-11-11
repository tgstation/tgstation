/datum/traitor_objective
	/// The name of the traitor objective
	var/name = "traitor objective"
	/// The minimum required progression points for this objective
	var/progression_minimum

/// Used for generating the UI buttons for the UI. Use ui_perform_action to respond to clicks.
/datum/traitor_objective/proc/generate_ui_buttons()
	return

/datum/traitor_objective/proc/add_ui_button(name, tooltip, icon, action)
	return list(list(
		"name" = name,
		"tooltip" = tooltip,
		"icon" = icon,
		"action" = action,
	))

/// Return TRUE to trigger a UI update
/datum/traitor_objective/proc/ui_perform_action(mob/user, action)
	return TRUE
