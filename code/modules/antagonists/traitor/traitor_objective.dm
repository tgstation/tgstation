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
	/// The progression that is rewarded from completing this traitor objective. Can either be a list of list(min, max) or a direct value
	var/progression_reward = 0 MINUTES
	/// The telecrystals that are rewarded from completing this traitor objective. Can either be a list of list(min,max) or a direct value
	var/telecrystal_reward = 0
	/// The current state of this objective
	var/objective_state = OBJECTIVE_STATE_INACTIVE

	var/list/registered_objects = list()

/datum/traitor_objective/New(datum/uplink_handler/handler)
	. = ..()
	src.handler = handler
	if(islist(telecrystal_reward))
		telecrystal_reward = rand(telecrystal_reward[1], telecrystal_reward[2])

	if(islist(progression_reward))
		progression_reward = rand(progression_reward[1], progression_reward[2])

/datum/traitor_objective/Destroy(force, ...)
	handler = null
	return ..()

/// Called when the objective should be generated. Should return if the objective has been successfully generated.
/// If false is returned, the objective will be removed as a potential objective for the traitor it is being generated for.
/// This is only temporary, it will run the proc again when objectives are generated for the traitor again.
/datum/traitor_objective/proc/generate_objective(datum/mind/generating_for)
	return FALSE

/// Used to clean up signals and stop listening to states.
/datum/traitor_objective/proc/ungenerate_objective()
	return

/// Used to handle cleaning up the objective.
/datum/traitor_objective/proc/handle_cleanup()
	ungenerate_objective()
	if(objective_state == OBJECTIVE_STATE_INACTIVE)
		handler.complete_objective(src) // Remove this objective immediately, no reason to keep it around. It isn't even active
		return

/// Used to fail objectives. Players can clear completed objectives in the UI
/datum/traitor_objective/proc/fail_objective()
	SEND_SIGNAL(src, COMSIG_TRAITOR_OBJECTIVE_FAILED)
	handle_cleanup()
	objective_state = OBJECTIVE_STATE_FAILED

/// Used to succeed objectives. Allows the player to cash it out in the UI.
/datum/traitor_objective/proc/succeed_objective()
	SEND_SIGNAL(src, COMSIG_TRAITOR_OBJECTIVE_COMPLETED)
	handle_cleanup()
	objective_state = OBJECTIVE_STATE_COMPLETED

/// Called by player input, do not call directly. Validates whether the objective is finished and pays out the handler if it is.
/datum/traitor_objective/proc/finish_objective()
	switch(objective_state)
		if(OBJECTIVE_STATE_FAILED)
			return TRUE
		if(OBJECTIVE_STATE_COMPLETED)
			completion_payout()
			return TRUE
	return FALSE

/// Called when rewards should be given to the user.
/datum/traitor_objective/proc/completion_payout()
	handler.progression_points += progression_reward
	handler.telecrystals += telecrystal_reward

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
