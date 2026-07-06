/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	ss_flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	dependencies = list(
		/datum/controller/subsystem/movement/ai_movement,
	)
	wait = 0.25 SECONDS //Plan every 1/4th second if required. In theory your AI should not be planning this much, but its useful because we want planning to be responsive when a previous plan ends.
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/currentrun = list()
	///type of status we are interested in running
	var/planning_status = AI_STATUS_ON
	/// CPU cost (in ms) accumulated by the in-progress pass, summed across fires.
	var/summing_cost
	/// world.time at which the in-progress pass started.
	var/pass_started
	/// How many controllers the in-progress pass started with.
	var/pass_size
	/// Average wall-clock duration for a full pass on controllers
	var/average_pass_time
	/// Longest gap any single controller went between two ticks.
	var/longest_tick_gap
	/// Running longest tick gap of the in-progress pass.
	var/summing_tick_gap
	/// List of all targeting_strategy singletons, key is the typepath while assigned value is a newly created instance of the typepath. See setup_targeting_strats()
	var/list/targeting_strategies
	/// List of all target_priority_strategy singletons, key is the typepath while assigned value is a newly created instance of the typepath. See setup_target_priority_strats()
	var/list/target_priority_strategies
	/// List of all target_source singletons, key is the typepath while assigned value is a newly created instance of the typepath. See setup_target_sources()
	var/list/target_sources
	///AI controllers, sorted by their status
	var/list/ai_controllers_by_status = list(
		AI_STATUS_ON = list(),
		AI_STATUS_OFF = list(),
	)
	///AI controllers, sorted by their z level
	var/list/ai_controllers_by_zlevel = list()

/datum/controller/subsystem/ai_controllers/Recover()
	if(islist(SSai_controllers.ai_controllers_by_status))
		ai_controllers_by_status = SSai_controllers.ai_controllers_by_status
	if(islist(SSai_controllers.ai_controllers_by_zlevel))
		ai_controllers_by_zlevel = SSai_controllers.ai_controllers_by_zlevel

/datum/controller/subsystem/ai_controllers/Initialize()
	setup_targeting_strats()
	setup_target_priority_strats()
	setup_target_sources()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/stat_entry(msg)
	msg = "\n  Active:[length(ai_controllers_by_status[planning_status])]|Off:[length(ai_controllers_by_status[AI_STATUS_OFF])]"
	msg += "\n  Pass:[pass_size - length(currentrun)]/[pass_size]|AvgPass:[round(average_pass_time * 0.1, 0.1)]s|WorstGap:[round(longest_tick_gap * 0.1, 0.1)]s"
	return ..()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	if(!resumed)
		var/list/planning_list = ai_controllers_by_status[planning_status]
		currentrun = planning_list.Copy()
		summing_cost = 0
		summing_tick_gap = 0
		pass_started = world.time
		pass_size = length(currentrun)

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.currentrun
	var/timer = TICK_USAGE_REAL
	while(length(current_run))
		var/datum/ai_controller/ai_controller = current_run[length(current_run)]
		current_run.len--
		// Pass the real time since this controller last ticked, so SPT_PROB rolls and
		// time accumulators stay time-correct even when a pass takes several seconds.
		var/seconds_per_tick = wait * 0.1
		if(ai_controller.last_bt_tick)
			var/tick_gap = world.time - ai_controller.last_bt_tick
			summing_tick_gap = max(summing_tick_gap, tick_gap)
			seconds_per_tick = tick_gap * 0.1
		ai_controller.last_bt_tick = world.time
		ai_controller.SelectBehaviors(seconds_per_tick)

		if(MC_TICK_CHECK)
			break

	summing_cost += TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer)
	if(MC_TICK_CHECK)
		return

	average_pass_time = MC_AVERAGE(average_pass_time, world.time - pass_started)
	longest_tick_gap = summing_tick_gap

///Called when the max Z level was changed, updating our coverage.
/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	if(!length(ai_controllers_by_zlevel))
		ai_controllers_by_zlevel = new /list(world.maxz,0)
	while (ai_controllers_by_zlevel.len < world.maxz)
		ai_controllers_by_zlevel.len++
		ai_controllers_by_zlevel[ai_controllers_by_zlevel.len] = list()

/datum/controller/subsystem/ai_controllers/proc/setup_targeting_strats()
	targeting_strategies = list()
	for(var/target_type in subtypesof(/datum/targeting_strategy))
		var/datum/targeting_strategy/target_start = new target_type
		targeting_strategies[target_type] = target_start

/datum/controller/subsystem/ai_controllers/proc/setup_target_priority_strats()
	target_priority_strategies = list()
	for(var/target_type in subtypesof(/datum/target_priority_strategy))
		var/datum/target_priority_strategy/target_start = new target_type
		target_priority_strategies[target_type] = target_start

/datum/controller/subsystem/ai_controllers/proc/setup_target_sources()
	target_sources = list()
	for(var/source_type in subtypesof(/datum/target_source))
		var/datum/target_source/source = new source_type
		target_sources[source_type] = source
