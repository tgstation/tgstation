/datum/ai_controller/basic_controller/bot
	blackboard = list(
		BB_BOT_CURRENT_SUMMONER = null,
		BB_BOT_CURRENT_PATROL_POINT = null,
	)
	ai_movement = /datum/ai_movement/jps
	max_target_distance = 200 //It can go far to patrol.

	planning_subtrees = list(
		/datum/ai_planning_subtree/core_bot_behaviors
	)

	var/reset_access_timer_id

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

/datum/ai_controller/basic_controller/bot/proc/call_bot(caller, turf/waypoint, message = TRUE)

	var/mob/living/basic/bot/bot_pawn = pawn

	blackboard[BB_BOT_CURRENT_SUMMONER] = caller //Link the AI to the bot!
	blackboard[BB_BOT_SUMMON_WAYPOINT] = waypoint

	var/end_area = get_area_name(waypoint)
	if(!(bot_pawn.bot_mode_flags & BOT_MODE_ON))
		bot_pawn.turn_on() //Saves the AI the hassle of having to activate a bot manually.

	bot_pawn.access_card.set_access(REGION_ACCESS_ALL_STATION) //Give the bot all-access while under the AI's command.

	if(bot_pawn.client)
		reset_access_timer_id = addtimer(CALLBACK (src, .proc/reset_bot), 60 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE) //if the bot is player controlled, they get the extra access for a limited time
		to_chat(src, span_notice("[span_big("Priority waypoint set by [icon2html(caller, src)] <b>[caller]</b>. Proceed to <b>[end_area]</b>.")] You have been granted additional door access for 60 seconds."))

	if(message)
		to_chat(caller, span_notice("[icon2html(src, caller)] [bot_pawn.name] called to [end_area]."))

/datum/ai_controller/basic_controller/bot/proc/reset_bot()
	var/mob/living/basic/bot/bot_pawn = pawn
	var/atom/caller = blackboard[BB_BOT_CURRENT_SUMMONER]

	if(isAI(caller)) //Simple notification to the AI if it called a bot. It will not know the cause or identity of the bot.
		to_chat(caller, span_danger("Call command to a bot has been reset."))
		blackboard[BB_BOT_CURRENT_SUMMONER] = null
	if(reset_access_timer_id)
		deltimer(reset_access_timer_id)
		reset_access_timer_id = null
	blackboard[BB_BOT_SUMMON_WAYPOINT] = null

	CancelActions()

	bot_pawn.reset_bot_access()
	bot_pawn.diag_hud_set_botstat()
	bot_pawn.diag_hud_set_botmode()


///Handles basic behavior for a bot (Primarily patrolling)
/datum/ai_planning_subtree/core_bot_behaviors

/datum/ai_planning_subtree/core_bot_behaviors/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/basic/bot/bot_pawn = controller.pawn

	if(controller.blackboard[BB_BOT_SUMMON_WAYPOINT])
		controller.set_movement_target(get_turf(controller.blackboard[BB_BOT_SUMMON_WAYPOINT]), /datum/ai_movement/jps)
		controller.queue_behavior(/datum/ai_behavior/move_to_summon_location)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(bot_pawn.bot_mode_flags & BOT_MODE_AUTOPATROL)
		if(!controller.blackboard[BB_BOT_CURRENT_PATROL_POINT])
			controller.queue_behavior(/datum/ai_behavior/find_closest_patrol_point)

		if(!controller.blackboard[BB_BOT_CURRENT_PATROL_POINT])
			return //No patrol point found

		controller.set_movement_target(get_turf(controller.blackboard[BB_BOT_CURRENT_PATROL_POINT]), /datum/ai_movement/jps)
		PatrolBehavior(controller, delta_time)

		return SUBTREE_RETURN_FINISH_PLANNING


/// override this if the bot has patrol behavior (like finding baddies)
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
	bot_pawn.set_current_behavior_description("Patrolling")

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
	bot_pawn.set_current_behavior_description()

	controller.CancelActions() //This is important because we are often performing permanent actions (e.g. looking for targets) while patrolling. Maybe we can think of a better solution for this in the future?

///Move to summon location and then finish!
/datum/ai_behavior/move_to_summon_location
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 0
	required_distance = 0

/datum/ai_behavior/move_to_summon_location/setup(datum/ai_controller/controller, ...)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	bot_pawn.set_current_behavior_description("Being summoned")

/datum/ai_behavior/move_to_summon_location/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, TRUE) //We don't actually need to do anything besides move there.

/datum/ai_behavior/move_to_summon_location/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	bot_pawn.set_current_behavior_description()
	controller.blackboard[BB_BOT_CURRENT_SUMMONER] = null
	controller.blackboard[BB_BOT_SUMMON_WAYPOINT] = null
