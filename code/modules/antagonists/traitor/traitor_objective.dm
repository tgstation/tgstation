/datum/traitor_objective
	/// The name of the traitor objective
	var/name = "traitor objective"
	/// The description of the traitor objective
	var/description = "this is a traitor objective"
	/// The uplink handler holder to give the progression and telecrystals to.
	var/datum/uplink_handler/handler
	/// The minimum required progression points for this objective
	var/progression_minimum = 0 MINUTES
	/// The maximum progression before this objective cannot appear anymore
	var/progression_maximum = INFINITY
	/// The progression that is rewarded from completing this traitor objective
	var/progression_reward = 0 MINUTES
	/// The telecrystals that are rewarded from completing this traitor objective
	var/telecrystal_reward = 0
	/// The current state of this objective
	var/objective_state = OBJECTIVE_STATE_INACTIVE

/datum/traitor_objective/New(datum/uplink_handler/handler)
	. = ..()
	src.handler = handler


/datum/traitor_objective/Destroy(force, ...)
	handler = null
	return ..()

/// Called when the objective should be generated. Should return if the objective has been successfully generated.
/// If false is returned, the objective will be removed as a potential objective for the traitor it is being generated for.
/// This is only temporary, it will run the proc again when objectives are generated for the traitor again.
/datum/traitor_objective/proc/generate_objective(datum/mind/generating_for)
	return TRUE

/// Determines whether this objective is valid or not anymore.
/datum/traitor_objective/proc/fail_objective()
	objective_state = OBJECTIVE_STATE_FAILED

/// Determines whether this objective is a duplicate. objective_to_compare is always of the type it is being called on.
/datum/traitor_objective/proc/is_duplicate(datum/traitor_objective/objective_to_compare)
	return TRUE

/// Used for sending data to the uplink UI
/datum/traitor_objective/proc/uplink_ui_data(mob/user)
	return list(
		"name" = name,
		"description" = description,
		"progression_minimum" = progression_minimum,
		"progression_reward" = progression_reward,
		"telecrystal_reward" = telecrystal_reward,
		"ui_buttons" = generate_ui_buttons(user),
		"objective_state" = objective_state,
	)

/// Used for generating the UI buttons for the UI. Use ui_perform_action to respond to clicks.
/datum/traitor_objective/proc/generate_ui_buttons(mob/user)
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
