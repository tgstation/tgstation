/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.5 SECONDS //Plan every half second if required, not great not terrible.
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	///List of all ai_subtree singletons, key is the typepath while assigned value is a newly created instance of the typepath. See setup_subtrees()
	var/list/datum/ai_planning_subtree/ai_subtrees = list()
	///Assoc List of all AI statuses and all AI controllers with that status.
	var/list/ai_controllers_by_status = list(
		AI_STATUS_ON = list(),
		AI_STATUS_OFF = list(),
		AI_STATUS_IDLE = list(),
	)
	///Assoc List of all AI controllers and the Z level they are on, which we check when someone enters/leaves a Z level to turn them on/off.
	var/list/ai_controllers_by_zlevel = list()
	/// The tick cost of all active AI, calculated on fire.
	var/cost_on
	/// The tick cost of all idle AI, calculated on fire.
	var/cost_idle


/datum/controller/subsystem/ai_controllers/Initialize()
	setup_subtrees()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/stat_entry(msg)
	var/list/active_list = ai_controllers_by_status[AI_STATUS_ON]
	var/list/inactive_list = ai_controllers_by_status[AI_STATUS_OFF]
	var/list/idle_list = ai_controllers_by_status[AI_STATUS_IDLE]
	msg = "Active AIs:[length(active_list)]/[round(cost_on,1)]%|Inactive:[length(inactive_list)]|Idle:[length(idle_list)]/[round(cost_idle,1)]%"
	return ..()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	var/timer = TICK_USAGE_REAL
	cost_idle = MC_AVERAGE(cost_idle, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	timer = TICK_USAGE_REAL
	for(var/datum/ai_controller/ai_controller as anything in ai_controllers_by_status[AI_STATUS_ON])
		if(!COOLDOWN_FINISHED(ai_controller, failed_planning_cooldown))
			continue

		if(!ai_controller.able_to_plan())
			continue
		ai_controller.SelectBehaviors(wait * 0.1)
		if(!LAZYLEN(ai_controller.current_behaviors)) //Still no plan
			COOLDOWN_START(ai_controller, failed_planning_cooldown, AI_FAILED_PLANNING_COOLDOWN)

	cost_on = MC_AVERAGE(cost_on, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

///Creates all instances of ai_subtrees and assigns them to the ai_subtrees list.
/datum/controller/subsystem/ai_controllers/proc/setup_subtrees()
	for(var/subtree_type in subtypesof(/datum/ai_planning_subtree))
		var/datum/ai_planning_subtree/subtree = new subtree_type
		ai_subtrees[subtree_type] = subtree

///Called when the max Z level was changed, updating our coverage.
/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	if (!islist(ai_controllers_by_zlevel))
		ai_controllers_by_zlevel = new /list(world.maxz,0)
	while (SSai_controllers.ai_controllers_by_zlevel.len < world.maxz)
		SSai_controllers.ai_controllers_by_zlevel.len++
		SSai_controllers.ai_controllers_by_zlevel[ai_controllers_by_zlevel.len] = list()
