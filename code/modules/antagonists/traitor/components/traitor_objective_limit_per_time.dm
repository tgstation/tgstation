/// Helper component to track events on
/datum/component/traitor_objective_limit_per_time
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

	/// The maximum time that an objective will be considered for. Set to -1 to accept any time.
	var/time_period = 0
	/// The maximum amount of objectives that can be active or recently active at one time
	var/maximum_objectives = 0
	/// The typepath which we check for
	var/typepath

/datum/component/traitor_objective_limit_per_time/Initialize(typepath, time_period, maximum_objectives)
	. = ..()
	if(!istype(parent, /datum/traitor_objective))
		return COMPONENT_INCOMPATIBLE
	src.time_period = time_period
	src.maximum_objectives = maximum_objectives
	src.typepath = typepath
	if(!typepath)
		src.typepath = parent.type

/datum/component/traitor_objective_limit_per_time/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TRAITOR_OBJECTIVE_PRE_GENERATE, PROC_REF(handle_generate))

/datum/component/traitor_objective_limit_per_time/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_TRAITOR_OBJECTIVE_PRE_GENERATE)


/datum/component/traitor_objective_limit_per_time/proc/handle_generate(datum/traitor_objective/source, datum/mind/owner, list/potential_duplicates)
	SIGNAL_HANDLER
	var/datum/uplink_handler/handler = source.handler
	if(!handler)
		return
	var/count = 0
	for(var/datum/traitor_objective/objective as anything in handler.potential_duplicate_objectives[typepath])
		if(time_period != -1 && objective.objective_state != OBJECTIVE_STATE_INACTIVE && (world.time - objective.time_of_completion) > time_period)
			continue
		count++

	if(count >= maximum_objectives)
		return COMPONENT_TRAITOR_OBJECTIVE_ABORT_GENERATION
