/datum/ai_planning_subtree/gary/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()

	///we prioritize getting a hideout setup asap
	if(!controller.blackboard[BB_GARY_HIDEOUT])
		///gary will pick a random maint turf to set as its home
		var/list/turfs = get_area_turfs(/area/station/maintenance, subtypes = TRUE)
		var/turf/open/target_turf = null
		var/sanity = 0
		var/list/excluded_areas = list(/area/station/maintenance/department/science/xenobiology)// i hate isolated maints
		while(!target_turf && sanity < 100)
			sanity++
			var/turf/turf = pick(turfs)
			var/area/turf_area = get_area(turf)
			if(turf_area.type in excluded_areas)
				continue

			if(is_safe_turf(turf))
				target_turf = turf
		controller.blackboard[BB_GARY_HIDEOUT] = list(target_turf.x, target_turf.y, target_turf.z)
		controller.blackboard[BB_GARY_HIDEOUT_SETTING_UP] = TRUE
		controller.blackboard[BB_GARY_COME_HOME] = TRUE

		controller.queue_behavior(/datum/ai_behavior/travel_towards/head_to_hideout, BB_TRAVEL_DESTINATION)
		return

	///we refuse to do anything until this is done
	if(controller.blackboard[BB_GARY_HIDEOUT_SETTING_UP])
		if(controller.blackboard[BB_GARY_COME_HOME])
			controller.queue_behavior(/datum/ai_behavior/travel_towards/head_to_hideout, BB_TRAVEL_DESTINATION)
			return
		else
			controller.queue_behavior(/datum/ai_behavior/setup_hideout)
			return

	if(controller.blackboard[BB_GARY_COME_HOME])
		if(controller.blackboard[BB_GARY_HAS_SHINY])
			controller.queue_behavior(/datum/ai_behavior/travel_towards/head_to_hideout/drop, BB_TRAVEL_DESTINATION)
			return
		else
			controller.queue_behavior(/datum/ai_behavior/travel_towards/head_to_hideout, BB_TRAVEL_DESTINATION)
			return

	if(controller.blackboard[BB_GARY_BARTERING])
		switch(controller.blackboard[BB_GARY_BARTER_STEP])
			if(1)
				controller.queue_behavior(/datum/ai_behavior/gary_retrieve_item)
				return
			if(2)
				controller.queue_behavior(/datum/ai_behavior/gary_give_item)
				return
