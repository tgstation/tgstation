/datum/traitor_objective
	/// The name of the traitor objective
	var/name = "traitor objective"
	/// The description of the traitor objective
	var/description = "this is a traitor objective"
	/// The minimum required progression points for this objective
	var/progression_minimum = 0 MINUTES

	/// The progression that is rewarded from completing this traitor objective
	var/progression_reward = 0 MINUTES
	/// The telecrystals that are rewarded from completing this traitor objective
	var/telecrystal_reward = 0


/// Used for sending data to the uplink UI
/datum/traitor_objective/proc/uplink_ui_data(mob/user)
	return list(
		"name" = name,
		"description" = description,
		"progression_minimum" = progression_minimum,
		"progression_reward" = progression_reward,
		"telecrystal_reward" = telecrystal_reward,
		"ui_buttons" = generate_ui_buttons()
	)

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
