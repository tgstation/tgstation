/// A traitor objective. Traitor objectives should not be deleted after they have been created and established, only failed.
/// If a traitor objective needs to be removed from the failed/completed objective list of their handler, then you are doing something wrong
/// and you should reconsider. When an objective is failed/completed, that is final and the only way you can change that is by refactoring the code.
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
	/// TC penalty for failing an objective or cancelling it
	var/telecrystal_penalty = 1
	/// The time at which this objective was first created
	var/time_of_creation = 0
	/// The time at which this objective was completed
	var/time_of_completion = 0
	/// The current state of this objective
	var/objective_state = OBJECTIVE_STATE_INACTIVE
	/// Whether this objective was forced upon by an admin. Won't get autocleared by the traitor subsystem if progression surpasses an amount
	var/forced = FALSE
	/// Whether this objective was skipped by going from an inactive state to a failed state.
	var/skipped = FALSE

	/// Determines how influential global progression will affect this objective. Set to 0 to disable.
	var/global_progression_influence_intensity = 0.5
	/// Determines how great the deviance has to be before progression starts to get reduced.
	var/global_progression_deviance_required = 0.5
	/// Determines the minimum and maximum progression this objective can be worth as a result of being influenced by global progression
	/// Should only be smaller than or equal to 1
	var/global_progression_limit_coeff = 0.1
	/// The deviance coefficient used to determine the randomness of the progression rewards.
	var/progression_cost_coeff_deviance = 0.05
	/// This gets added onto the coeff when calculating the updated progression cost. Used for variability and a slight bit of randomness
	var/progression_cost_coeff = 0
	/// The percentage that this objective has been increased or decreased by as a result of progression. Used by the UI
	var/original_progression = 0
	/// Abstract type that won't be included as a possible objective
	var/abstract_type = /datum/traitor_objective

/// Returns a list of variables that can be changed by config, allows for balance through configuration.
/// It is not recommended to finetweak any values of objectives on your server.
/datum/traitor_objective/proc/supported_configuration_changes()
	return list(
		NAMEOF(src, global_progression_influence_intensity),
		NAMEOF(src, global_progression_deviance_required),
		NAMEOF(src, global_progression_limit_coeff)
	)

/// Replaces a word in the name of the proc. Also does it for the description
/datum/traitor_objective/proc/replace_in_name(replace, word)
	name = replacetext(name, replace, word)
	description = replacetext(description, replace, word)

/datum/traitor_objective/New(datum/uplink_handler/handler)
	. = ..()
	src.handler = handler
	src.time_of_creation = world.time
	apply_configuration()
	if(SStraitor.generate_objectives)
		if(islist(telecrystal_reward))
			telecrystal_reward = rand(telecrystal_reward[1], telecrystal_reward[2])
		if(islist(progression_reward))
			progression_reward = rand(progression_reward[1], progression_reward[2])
	else
		if(!islist(telecrystal_reward))
			telecrystal_reward = list(telecrystal_reward, telecrystal_reward)
		if(!islist(progression_reward))
			progression_reward = list(progression_reward, progression_reward)
	progression_cost_coeff = (rand()*2 - 1) * progression_cost_coeff_deviance

/datum/traitor_objective/proc/apply_configuration()
	if(!length(SStraitor.configuration_data))
		return
	var/datum/traitor_objective/current_type = type
	var/list/types = list()
	while(current_type != /datum/traitor_objective)
		types += current_type
		current_type = type2parent(current_type)
	types += /datum/traitor_objective
	// Reverse the list direction
	reverse_range(types)
	var/list/supported_configurations = supported_configuration_changes()
	for(var/typepath in types)
		if(!(typepath in SStraitor.configuration_data))
			continue
		var/list/changes = SStraitor.configuration_data[typepath]
		for(var/variable in changes)
			if(!(variable in supported_configurations))
				continue
			vars[variable] = changes[variable]


/// Updates the progression reward, scaling it depending on their current progression compared against the global progression
/datum/traitor_objective/proc/update_progression_reward()
	if(!SStraitor.generate_objectives)
		return
	progression_reward = original_progression
	if(global_progression_influence_intensity <= 0)
		return
	var/minimum_progression = progression_reward * global_progression_limit_coeff
	var/maximum_progression = global_progression_limit_coeff != 0? progression_reward / global_progression_limit_coeff : INFINITY
	var/deviance = (SStraitor.current_global_progression - handler.progression_points) / SStraitor.progression_scaling_deviance
	if(abs(deviance) < global_progression_deviance_required)
		return
	if(abs(deviance) == deviance) // If it is positive
		deviance = deviance - global_progression_deviance_required
	else
		deviance = deviance + global_progression_deviance_required
	var/coeff = NUM_E ** (global_progression_influence_intensity * deviance) - 1
	// This has less of an effect as the coeff gets nearer to 1. Is linear
	coeff += progression_cost_coeff * (1 - coeff)

	progression_reward = clamp(
		progression_reward + progression_reward * coeff,
		minimum_progression,
		maximum_progression
	)

/datum/traitor_objective/Destroy(force, ...)
	handler = null
	return ..()

/// Called when the objective should be generated. Should return if the objective has been successfully generated.
/// If false is returned, the objective will be removed as a potential objective for the traitor it is being generated for.
/// This is only temporary, it will run the proc again when objectives are generated for the traitor again.
/datum/traitor_objective/proc/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	return FALSE

/// Used to clean up signals and stop listening to states.
/datum/traitor_objective/proc/ungenerate_objective()
	return

/datum/traitor_objective/proc/get_log_data()
	return list(
		"type" = type,
		"owner" = handler.owner.key,
		"name" = name,
		"description" = description,
		"telecrystal_reward" = telecrystal_reward,
		"progression_reward" = progression_reward,
		"original_progression" = original_progression,
		"objective_state" = objective_state,
		"forced" = forced,
		"time_of_creation" = time_of_creation,
	)

/// Converts the type into a useful debug string to be used for logging and debug display.
/datum/traitor_objective/proc/to_debug_string()
	return "[type] (Name: [name], TC: [telecrystal_reward], Progression: [progression_reward], Time of creation: [time_of_creation])"

/datum/traitor_objective/proc/save_objective()
	SSblackbox.record_feedback("associative", "traitor_objective", 1, get_log_data())

/// Used to handle cleaning up the objective.
/datum/traitor_objective/proc/handle_cleanup()
	time_of_completion = world.time
	ungenerate_objective()
	if(objective_state == OBJECTIVE_STATE_INACTIVE)
		skipped = TRUE
		handler.complete_objective(src) // Remove this objective immediately, no reason to keep it around. It isn't even active

/// Used to fail objectives. Players can clear completed objectives in the UI
/datum/traitor_objective/proc/fail_objective(penalty_cost = 0, trigger_update = TRUE)
	// Don't let players succeed already succeeded/failed objectives
	if(objective_state != OBJECTIVE_STATE_INACTIVE && objective_state != OBJECTIVE_STATE_ACTIVE)
		return
	SEND_SIGNAL(src, COMSIG_TRAITOR_OBJECTIVE_FAILED)
	handle_cleanup()
	log_traitor("[key_name(handler.owner)] [objective_state == OBJECTIVE_STATE_INACTIVE? "missed" : "failed"] [to_debug_string()]")
	if(penalty_cost)
		handler.telecrystals -= penalty_cost
		objective_state = OBJECTIVE_STATE_FAILED
	else
		objective_state = OBJECTIVE_STATE_INVALID
	save_objective()
	if(trigger_update)
		handler.on_update() // Trigger an update to the UI

/// Used to succeed objectives. Allows the player to cash it out in the UI.
/datum/traitor_objective/proc/succeed_objective()
	// Don't let players succeed already succeeded/failed objectives
	if(objective_state != OBJECTIVE_STATE_INACTIVE && objective_state != OBJECTIVE_STATE_ACTIVE)
		return
	SEND_SIGNAL(src, COMSIG_TRAITOR_OBJECTIVE_COMPLETED)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED, src)
	handle_cleanup()
	log_traitor("[key_name(handler.owner)] [objective_state == OBJECTIVE_STATE_INACTIVE? "missed" : "completed"] [to_debug_string()]")
	objective_state = OBJECTIVE_STATE_COMPLETED
	save_objective()
	handler.on_update() // Trigger an update to the UI

/// Called by player input, do not call directly. Validates whether the objective is finished and pays out the handler if it is.
/datum/traitor_objective/proc/finish_objective(mob/user)
	switch(objective_state)
		if(OBJECTIVE_STATE_FAILED, OBJECTIVE_STATE_INVALID)
			user.playsound_local(get_turf(user), 'sound/traitor/objective_failed.ogg', vol = 100, vary = FALSE, channel = CHANNEL_TRAITOR)
			return TRUE
		if(OBJECTIVE_STATE_COMPLETED)
			user.playsound_local(get_turf(user), 'sound/traitor/objective_success.ogg', vol = 100, vary = FALSE, channel = CHANNEL_TRAITOR)
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
		"original_progression" = original_progression,
		"telecrystal_penalty" = telecrystal_penalty,
	)

/datum/traitor_objective/proc/on_objective_taken(mob/user)
	SStraitor.on_objective_taken(src)
	log_traitor("[key_name(handler.owner)] has taken an objective: [to_debug_string()]")

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
