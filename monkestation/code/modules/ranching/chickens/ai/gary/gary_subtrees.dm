/datum/ai_planning_subtree/gary/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()

	///we refuse to do anything until this is done
	if(controller.blackboard[BB_GARY_HIDEOUT_SETTING_UP])
		if(controller.blackboard[BB_GARY_COME_HOME])
			return
		else
			controller.queue_behavior(/datum/ai_behavior/setup_hideout)

	///we prioritize getting a hideout setup asap
	if(!controller.blackboard[BB_GARY_HIDEOUT])
		///gary will pick a random maint turf to set as its home
		var/list/turfs = get_area_turfs(pick(subtypesof(/area/station/maintenance)))
		var/turf/open/target_turf = null
		var/sanity = 0
		while(!target_turf && sanity < 100)
			sanity++
			var/turf/turf = pick(turfs)
			if(!turf.density)
				target_turf = turf
		controller.blackboard[BB_GARY_HIDEOUT] = WEAKREF(target_turf)
		controller.blackboard[BB_GARY_HIDEOUT_SETTING_UP] = TRUE
		controller.blackboard[BB_GARY_COME_HOME] = TRUE

		controller.queue_behavior(/datum/ai_behavior/head_to_hideout)

	if(controller.blackboard[BB_GARY_COME_HOME])
		if(controller.blackboard[BB_GARY_HAS_SHINY])
			controller.queue_behavior(/datum/ai_behavior/head_to_hideout/drop)
		else
			controller.queue_behavior(/datum/ai_behavior/head_to_hideout)

