/datum/ai_controller/basic_controller/bot
	blackboard = list(
		BB_BOT_WAS_SUMMONED = FALSE,
		BB_BOT_CURRENT_PATROL_POINT = null,
		BB_BOT_CURRENT_PATROL_POINT = null,
	)
	ai_movement = /datum/ai_movement/jps
	max_target_distance = 200 //It can go far to patrol.

	planning_subtrees = list(
		/datum/ai_planning_subtree/core_bot_behaviors
	)

/datum/ai_controller/basic_controller/bot/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/basic/bot))
		return AI_CONTROLLER_INCOMPATIBLE
	return ..() //Run parent at end

/datum/ai_controller/basic_controller/bot/able_to_run()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/bot/bot_pawn = pawn
	return bot_pawn.bot_mode_flags & BOT_MODE_ON

/datum/ai_controller/basic_controller/bot/get_access()
	. = ..()
	var/mob/living/basic/bot/bot_pawn = pawn
	return bot_pawn.access_card

/datum/ai_planning_subtree/core_bot_behaviors

/datum/ai_planning_subtree/core_bot_behaviors/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/basic/bot/bot_pawn = controller.pawn

	if(bot_pawn.bot_mode_flags & BOT_MODE_AUTOPATROL)
		if(!controller.blackboard[BB_BOT_CURRENT_PATROL_POINT])
			controller.queue_behavior(/datum/ai_behavior/find_closest_patrol_point)
		PatrolBehavior(controller, delta_time)

		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/core_bot_behaviors/proc/PatrolBehavior(datum/ai_controller/controller, delta_time)
	controller.queue_behavior(/datum/ai_behavior/move_to_next_patrol_point)


///Find the closest patrol point in the area!
/datum/ai_behavior/find_closest_patrol_point
	action_cooldown = 0

/datum/ai_behavior/find_closest_patrol_point/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/obj/machinery/navbeacon/nearest_beacon = null
	var/turf/nearest_beacon_turf

	bot_pawn.current_status_description = "Patrolling"

	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[bot_pawn.z]"])
		var/dist = get_dist(src, NB)
		if(nearest_beacon) //Loop though the beacon net to find the true closest beacon.
			//Ignore the beacon if were are located on it.
			if(dist>1 && dist<get_dist(src,nearest_beacon_turf))
				nearest_beacon = NB
				nearest_beacon_turf = get_turf(NB)

		else if(dist > 1) //Begin the search, save this one for comparison on the next loop.
			nearest_beacon = NB
			nearest_beacon_turf = get_turf(NB)

	if(nearest_beacon)
		controller.blackboard[BB_BOT_CURRENT_PATROL_POINT] = nearest_beacon
		controller.current_movement_target = get_turf(nearest_beacon)
		finish_action(controller, TRUE)
	else
		bot_pawn.bot_mode_flags &= ~BOT_MODE_AUTOPATROL
		bot_pawn.speak("Disengaging patrol mode.")
		finish_action(controller, FALSE)


///Move to the next beacon in our area then finish
/datum/ai_behavior/move_to_next_patrol_point
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 0
	required_distance = 0

/datum/ai_behavior/move_to_next_patrol_point/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, TRUE) //We don't actually need to do anything besides move there.

/datum/ai_behavior/move_to_next_patrol_point/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()

	var/obj/machinery/navbeacon/previous_beacon = controller.blackboard[BB_BOT_CURRENT_PATROL_POINT]
	controller.blackboard[BB_BOT_CURRENT_PATROL_POINT] = null

	//This code kind of sucks. We should replace it once everything has been moved over to basic bots!
	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[controller.pawn.z]"])
		if(NB.location == previous_beacon.codes["next_patrol"]) //Is this beacon the next one?
			controller.blackboard[BB_BOT_CURRENT_PATROL_POINT] = NB
			controller.current_movement_target = get_turf(NB)
			break //We found it, no need to keep searching!

	controller.CancelActions() //This is important because we are often performing permanent actions (e.g. looking for targets) while patrolling. Maybe we can think of a better solution for this in the future?


