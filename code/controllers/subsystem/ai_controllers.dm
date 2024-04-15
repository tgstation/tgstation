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
	var/list/list/ai_controllers_by_status = list(
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
	/// The tick cost of idling active AI, calculated on fire.
	var/cost_to_idle
	/// caching for sanic speed
	var/list/currentrun
	var/current_part


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
	if(!resumed)
		current_part = SSAI_CONTROLLERS_ACTIVE
		src.currentrun = ai_controllers_by_status[AI_STATUS_ON].Copy()
	
	if(current_part == SSAI_CONTROLLERS_ACTIVE)
		var/timer = TICK_USAGE_REAL
		var/list/currentrun = src.currentrun
		while(currentrun.len)
			var/datum/ai_controller/ai_controller = currentrun[currentrun.len]
			currentrun.len--
			if(!QDELETED(ai_controller))
				if(!COOLDOWN_FINISHED(ai_controller, failed_planning_cooldown))
					continue

				if(!ai_controller.able_to_plan())
					continue
				ai_controller.SelectBehaviors(wait * 0.1)
				if(!LAZYLEN(ai_controller.current_behaviors)) //Still no plan
					COOLDOWN_START(ai_controller, failed_planning_cooldown, AI_FAILED_PLANNING_COOLDOWN)
			if(MC_TICK_CHECK)
				return
		current_part = SSAI_CONTROLLERS_IDLE
		src.currentrun = ai_controllers_by_status[AI_STATUS_ON].Copy()
		cost_on = MC_AVERAGE(cost_on, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	if(current_part == SSAI_CONTROLLERS_IDLE)
		var/timer = TICK_USAGE_REAL
		var/list/currentrun = src.currentrun
		while(currentrun.len)
			var/datum/ai_controller/ai_controller = currentrun[currentrun.len]
			currentrun.len--
			if(!QDELETED(ai_controller))
				if(ai_controller.can_idle)
					var/found_interesting = FALSE
					for(var/mob/client_found as anything in SSspatial_grid.orthogonal_range_search(ai_controller.pawn, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, ai_controller.interesting_dist))
						if(get_dist(get_turf(client_found), get_turf(ai_controller.pawn)) <= ai_controller.interesting_dist)
							found_interesting = TRUE
							break
					if(!found_interesting)
						ai_controller.set_ai_status(AI_STATUS_IDLE)
			if(MC_TICK_CHECK)
				return
		current_part = SSAI_CONTROLLERS_DEIDLE
		src.currentrun = ai_controllers_by_status[AI_STATUS_IDLE].Copy()
		cost_to_idle = MC_AVERAGE(cost_to_idle, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		
	if(current_part == SSAI_CONTROLLERS_DEIDLE)
		var/timer = TICK_USAGE_REAL
		var/list/currentrun = src.currentrun
		while(currentrun.len)
			var/datum/ai_controller/ai_controller = currentrun[currentrun.len]
			currentrun.len--
			if(!QDELETED(ai_controller))
				for(var/mob/client_found as anything in SSspatial_grid.orthogonal_range_search(ai_controller.pawn, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, ai_controller.interesting_dist))
					if(get_dist(get_turf(client_found), get_turf(ai_controller.pawn)) <= ai_controller.interesting_dist)
						ai_controller.set_ai_status(AI_STATUS_ON)
						break
			if(MC_TICK_CHECK)
				return
		current_part = SSAI_CONTROLLERS_ACTIVE
		src.currentrun = ai_controllers_by_status[AI_STATUS_ON].Copy()
		cost_idle = MC_AVERAGE(cost_idle, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

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
