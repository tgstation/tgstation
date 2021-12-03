SUBSYSTEM_DEF(traitor)
	name = "Traitor"
	flags = SS_KEEP_TIMING
	wait = 1 MINUTES
	/// The current progression that all traitors should be at in the round
	var/current_global_progression = 0
	/// The current uplink handlers being managed
	var/list/datum/uplink_handler/uplink_handlers
	/// The current scaling per minute of progression. Has a maximum value of 1 MINUTES.
	var/current_progression_scaling = 1 MINUTES

/datum/controller/subsystem/traitor/fire(resumed)
	var/player_count = GLOB.alive_player_list
	if(player_count < )
	current_progression_scaling = min(current_progression_scaling, 1 MINUTES)

	current_global_progression += current_progression_scaling
	for(var/datum/uplink_handler/handler in uplink_handlers)
		if(!handler.has_progression || QDELETED(handler))
			uplink_handlers -= handler
		uplink_handlers.progression_points += current_progression_scaling

/datum/controller/subsystem/traitor/proc/register_uplink_handler(datum/uplink_handler/uplink_handler)
	if(!uplink_handler.has_progression)
		return
	uplink_handlers += uplink_handler
	RegisterSignal(uplink_handler, COMSIG_PARENT_QDELETING, .proc/uplink_handler_deleted)
