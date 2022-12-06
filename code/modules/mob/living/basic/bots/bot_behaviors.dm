///Find the closest patrol point in the area!
/datum/ai_behavior/find_closest_patrol_point
	action_cooldown = 0

/datum/ai_behavior/find_closest_patrol_point/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/obj/machinery/navbeacon/nearest_beacon = null
	var/turf/nearest_beacon_turf

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


/datum/ai_behavior/move_to_next_patrol_point/setup(datum/ai_controller/controller, ...)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	bot_pawn.set_current_mode(BOT_PATROL)

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
			controller.set_movement_target(get_turf(NB), /datum/ai_movement/jps)
			break //We found it, no need to keep searching!


	var/mob/living/basic/bot/bot_pawn = controller.pawn
	bot_pawn.set_current_mode()

	controller.CancelActions() //This is important because we are often performing permanent actions (e.g. looking for targets) while patrolling. Maybe we can think of a better solution for this in the future?

///Move to summon location and then finish!
/datum/ai_behavior/move_to_summon_location
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 0
	required_distance = 0

/datum/ai_behavior/move_to_summon_location/setup(datum/ai_controller/controller, ...)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	bot_pawn.set_current_mode(BOT_SUMMON)

/datum/ai_behavior/move_to_summon_location/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, TRUE) //We don't actually need to do anything besides move there.

/datum/ai_behavior/move_to_summon_location/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	bot_pawn.set_current_mode()
	controller.blackboard[BB_BOT_CURRENT_SUMMONER] = null
	controller.blackboard[BB_BOT_SUMMON_WAYPOINT] = null

///Looks for targets based on the specified targetting datum, and sets the target if something is found.
/datum/ai_behavior/scan
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 1 SECONDS
	var/scan_range = DEFAULT_SCAN_RANGE
	var/turfs_only = FALSE

/datum/ai_behavior/scan/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	var/mob/living/living_pawn = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	var/turf/current_turf = get_turf(living_pawn)

	if(controller.blackboard["testing_key"])
		return

	if(!current_turf)
		return

	var/list/adjacent = current_turf.get_atmos_adjacent_turfs(1)

	controller.blackboard["testing_key"] = TRUE

	var/found_target

	for(var/turf/scanned_turf as anything in adjacent) //Let's see if there's something right next to us first!
		found_target = targetting_datum.can_attack(living_pawn, scanned_turf, TRUE)

		if(found_target)
			on_find_target(controller, target_key, scanned_turf)
			return

		if(turfs_only)
			continue

		for(var/atom/scan in scanned_turf)
			found_target = targetting_datum.can_attack(living_pawn, scan, TRUE)
			if(found_target)
				on_find_target(controller, target_key, scan)
				return

	if(turfs_only)
		for(var/turf/scanned_turf in view(scan_range, living_pawn) - adjacent)
			found_target = targetting_datum.can_attack(living_pawn, scanned_turf, TRUE)
			if(found_target)
				on_find_target(controller, target_key, scanned_turf)
				return
		controller.blackboard["testing_key"] = FALSE
		return

	for(var/atom/scanned_atom as anything in view(scan_range, living_pawn) - adjacent) //Search for something in range, minus what we already checked.
		found_target = targetting_datum.can_attack(living_pawn, scanned_atom)
		if(found_target)
			on_find_target(controller, target_key, scanned_atom)
			return

	controller.blackboard["testing_key"] = FALSE



///Ran once bot has found a target during scanning
/datum/ai_behavior/scan/proc/on_find_target(datum/ai_controller/controller, target_key, target)
	controller.blackboard[target_key] = target
	controller.blackboard["testing_key"] = FALSE
	controller.CancelActions() //Found a target, time to replan!

/datum/ai_behavior/scan/turfs_only
	turfs_only = TRUE

/datum/ai_behavior/force_bot_salute

/datum/ai_behavior/force_bot_salute/perform(delta_time, datum/ai_controller/controller, ...)
	. = ..()
	for(var/mob/living/simple_animal/bot/B in view(5, src))
		if(!B.commissioned && B.bot_mode_flags & BOT_MODE_ON)
			B.visible_message("<b>[B]</b> performs an elaborate salute for [controller.pawn]!")
			break
