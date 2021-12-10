SUBSYSTEM_DEF(traitor)
	name = "Traitor"
	flags = SS_KEEP_TIMING
	wait = 1 MINUTES
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// The coefficient multiplied by the current_global_progression for new joining traitors to calculate their progression
	var/newjoin_progression_coeff = 0.6
	/// The current progression that all traitors should be at in the round
	var/current_global_progression = 0
	/// The amount of deviance from the current global progression before you start getting 2x then current scaling or no scaling at all
	var/progression_scaling_deviance = 10 MINUTES
	/// The current uplink handlers being managed
	var/list/datum/uplink_handler/uplink_handlers = list()
	/// The current scaling per minute of progression. Has a maximum value of 1 MINUTES.
	var/current_progression_scaling = 1 MINUTES

/datum/controller/subsystem/traitor/fire(resumed)
	var/player_count = length(GLOB.alive_player_list)
	// Has a maximum of 1 minute, however the value can be lower if there are lower players than the ideal
	// player count for a traitor to be threatening. Rounds to the nearest 10% of a minute to prevent weird
	// values from appearing in the UI.
	current_progression_scaling = min(
		round(player_count / (CONFIG_GET(number/traitor_ideal_player_count) * 1 MINUTES), 0.1 MINUTES),
		1 MINUTES
	)

	current_global_progression += current_progression_scaling
	for(var/datum/uplink_handler/handler in uplink_handlers)
		if(!handler.has_progression || QDELETED(handler))
			uplink_handlers -= handler
		var/deviance = (current_global_progression - handler.progression_points) / progression_scaling_deviance
		var/amount_to_give = round(current_progression_scaling + (current_progression_scaling * deviance), 0.1 MINUTES)
		amount_to_give = clamp(amount_to_give, 0, current_progression_scaling * 2)
		handler.progression_points += current_progression_scaling
		handler.on_update()

/datum/controller/subsystem/traitor/proc/get_possible_objectives(progression_points)
	var/list/possible_objectives = list()
	for(var/datum/traitor_objective/objective_path as anything in subtypesof(/datum/traitor_objective))
		if(progression_points < initial(objective_path.progression_minimum))
			continue
		if(progression_points > initial(objective_path.progression_maximum))
			continue
		possible_objectives += objective_path
	return possible_objectives

/datum/controller/subsystem/traitor/proc/register_uplink_handler(datum/uplink_handler/uplink_handler)
	if(!uplink_handler.has_progression)
		return
	uplink_handlers |= uplink_handler
	RegisterSignal(uplink_handler, COMSIG_PARENT_QDELETING, .proc/uplink_handler_deleted, TRUE)

/datum/controller/subsystem/traitor/proc/uplink_handler_deleted(datum/uplink_handler/uplink_handler)
	SIGNAL_HANDLER
	uplink_handlers -= uplink_handler
