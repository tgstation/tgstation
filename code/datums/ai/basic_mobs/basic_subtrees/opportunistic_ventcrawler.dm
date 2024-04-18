/// Opportunistically searches for and hides/scurries through vents.
/datum/ai_planning_subtree/opportunistic_ventcrawler

/datum/ai_planning_subtree/opportunistic_ventcrawler/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(HAS_TRAIT(controller.pawn, TRAIT_MOVE_VENTCRAWLING))
		return SUBTREE_RETURN_FINISH_PLANNING // hold on let me cook

	var/obj/machinery/atmospherics/components/unary/vent_pump/target = controller.blackboard[BB_ENTRY_VENT_TARGET]

	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_ENTRY_VENT_TARGET, /obj/machinery/atmospherics/components/unary/vent_pump) // keep looking otherwise they KILL US AND WE DIE
		return

	if(get_turf(controller.pawn) != get_turf(target))
		controller.queue_behavior(/datum/ai_behavior/travel_towards, BB_ENTRY_VENT_TARGET)
		return

	controller.set_blackboard_key(BB_CURRENTLY_TARGETING_VENT, TRUE)
	controller.queue_behavior(/datum/ai_behavior/crawl_through_vents, BB_ENTRY_VENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING // we are going into this vent... no distractions
