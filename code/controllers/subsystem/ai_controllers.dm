/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	ss_flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	dependencies = list(
		/datum/controller/subsystem/movement/ai_movement,
	)
	wait = 0.1 SECONDS //Plan every 1/10th second if required. In theory your AI should not be planning this much, but its useful because we want planning to be responsive when a previous plan ends.
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/currentrun = list()
	///type of status we are interested in running
	var/planning_status = AI_STATUS_ON
	/// The average tick cost of all active AI, calculated on fire.
	var/our_cost
	/// The tick cost of all currently processed AI, being summed together
	var/summing_cost



/datum/controller/subsystem/ai_controllers/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/stat_entry(msg)
	var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
	msg = "\n  Planning AIs:[length(planning_list)]/[round(our_cost,1)]%"
	return ..()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	if(!resumed)
		var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
		currentrun = planning_list.Copy()
		summing_cost = 0

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.currentrun
	var/timer = TICK_USAGE_REAL
	while(length(current_run))
		var/datum/ai_controller/ai_controller = current_run[length(current_run)]
		current_run.len--
		ai_controller.SelectBehaviors(wait * 0.1)

		if(MC_TICK_CHECK)
			break

	summing_cost += TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer)
	if(MC_TICK_CHECK)
		return

	our_cost = MC_AVERAGE(our_cost, summing_cost)

///Called when the max Z level was changed, updating our coverage.
/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	if(!length(GLOB.ai_controllers_by_zlevel))
		GLOB.ai_controllers_by_zlevel = new /list(world.maxz,0)
	while (GLOB.ai_controllers_by_zlevel.len < world.maxz)
		GLOB.ai_controllers_by_zlevel.len++
		GLOB.ai_controllers_by_zlevel[GLOB.ai_controllers_by_zlevel.len] = list()
