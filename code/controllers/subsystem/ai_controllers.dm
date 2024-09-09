/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.5 SECONDS //Plan every half second if required, not great not terrible.
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	///type of status we are interested in running
	var/planning_status = AI_STATUS_ON
	/// The tick cost of all active AI, calculated on fire.
	var/our_cost

/datum/controller/subsystem/ai_controllers/Initialize()
	setup_subtrees()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/stat_entry(msg)
	var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
	msg = "Planning AIs:[length(planning_list)]/[round(our_cost,1)]%"
	return ..()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	var/timer = TICK_USAGE_REAL
	for(var/datum/ai_controller/ai_controller as anything in GLOB.ai_controllers_by_status[planning_status])
		if(!COOLDOWN_FINISHED(ai_controller, failed_planning_cooldown))
			continue

		if(!ai_controller.able_to_plan())
			continue
		ai_controller.SelectBehaviors(wait * 0.1)
		if(!LAZYLEN(ai_controller.current_behaviors)) //Still no plan
			COOLDOWN_START(ai_controller, failed_planning_cooldown, AI_FAILED_PLANNING_COOLDOWN)

	our_cost = MC_AVERAGE(our_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

///Creates all instances of ai_subtrees and assigns them to the ai_subtrees list.
/datum/controller/subsystem/ai_controllers/proc/setup_subtrees()
	if(length(GLOB.ai_subtrees))
		return
	for(var/subtree_type in subtypesof(/datum/ai_planning_subtree))
		var/datum/ai_planning_subtree/subtree = new subtree_type
		GLOB.ai_subtrees[subtree_type] = subtree

///Called when the max Z level was changed, updating our coverage.
/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	if(!length(GLOB.ai_controllers_by_zlevel))
		GLOB.ai_controllers_by_zlevel = new /list(world.maxz,0)
	while (GLOB.ai_controllers_by_zlevel.len < world.maxz)
		GLOB.ai_controllers_by_zlevel.len++
		GLOB.ai_controllers_by_zlevel[GLOB.ai_controllers_by_zlevel.len] = list()
