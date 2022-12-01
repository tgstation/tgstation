/datum/ai_controller/basic_controller/bot/floorbot
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/floorbot(),
		BB_FLOOR_BOT_TARGET = null,
		BB_IGNORE_LIST = list(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/bot_clear_ignore_list,
		/datum/ai_planning_subtree/bot_summoning,
		/datum/ai_planning_subtree/fix_tiles,
		/datum/ai_planning_subtree/watch_for_tiles,
		/datum/ai_planning_subtree/bot_patrolling,
	)


///Handles doing other repair work. This is generally positive unless emagged.
/datum/ai_planning_subtree/fix_tiles/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/mob/living/basic/bot/floorbot/floorbot = controller.pawn

	///If we're in line mode, check if there's a valid tile on the right
	if(floorbot.targetdirection && !(floorbot.bot_cover_flags & BOT_COVER_EMAGGED))
		var/turf/stepped_turf = get_step(floorbot, floorbot.targetdirection)
		if(isspaceturf(stepped_turf) || isfloorturf(stepped_turf)) //Check for space or floor
			controller.blackboard[BB_FLOOR_BOT_TARGET] = stepped_turf
		//add else statement here that complains about being stuck!

	if(controller.blackboard[BB_FLOOR_BOT_TARGET])
		controller.set_movement_target(controller.blackboard[BB_FLOOR_BOT_TARGET])
		controller.queue_behavior(/datum/ai_behavior/repair_floor, BB_FLOOR_BOT_TARGET, BB_TARGETTING_DATUM)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/watch_for_tiles/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/scan, BB_FLOOR_BOT_TARGET, BB_TARGETTING_DATUM)
