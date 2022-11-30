/datum/ai_controller/basic_controller/bot
	blackboard = list(
		BB_BOT_CURRENT_SUMMONER = null,
		BB_BOT_CURRENT_PATROL_POINT = null,
	)
	ai_movement = /datum/ai_movement/jps
	max_target_distance = 200 //It can go far to patrol.

	planning_subtrees = list(
		/datum/ai_planning_subtree/bot_clear_ignore_list,
		/datum/ai_planning_subtree/bot_summoning,
		/datum/ai_planning_subtree/bot_patrolling
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

	CancelActions() //Cancel whatever I was doing before!

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

///Handles the ocassional clearing of our ignore list!
/datum/ai_planning_subtree/bot_clear_ignore_list
	COOLDOWN_DECLARE(reset_ignore_cooldown)

/datum/ai_planning_subtree/bot_clear_ignore_list/SelectBehaviors(datum/ai_controller/controller, delta_time)
	// occasionally reset our ignore list
	if(COOLDOWN_FINISHED(src, reset_ignore_cooldown) && length(controller.blackboard[BB_IGNORE_LIST]))
		COOLDOWN_START(src, reset_ignore_cooldown, AI_BOT_IGNORE_DURATION)
		controller.blackboard[BB_IGNORE_LIST] = list()

///Handles getting summoned
/datum/ai_planning_subtree/bot_summoning/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_BOT_SUMMON_WAYPOINT])
		controller.set_movement_target(get_turf(controller.blackboard[BB_BOT_SUMMON_WAYPOINT]), /datum/ai_movement/jps)
		controller.queue_behavior(/datum/ai_behavior/move_to_summon_location)
		return SUBTREE_RETURN_FINISH_PLANNING

///Handles patrolling for a bot
/datum/ai_planning_subtree/bot_patrolling/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/basic/bot/bot_pawn = controller.pawn

	if(bot_pawn.bot_mode_flags & BOT_MODE_AUTOPATROL)
		if(!controller.blackboard[BB_BOT_CURRENT_PATROL_POINT])
			controller.queue_behavior(/datum/ai_behavior/find_closest_patrol_point)

		if(!controller.blackboard[BB_BOT_CURRENT_PATROL_POINT])
			return //No patrol point found

		controller.set_movement_target(get_turf(controller.blackboard[BB_BOT_CURRENT_PATROL_POINT]), /datum/ai_movement/jps)
		PatrolBehavior(controller, delta_time)

		return SUBTREE_RETURN_FINISH_PLANNING


/// override this if the bot has patrol behavior (like finding baddies)
/datum/ai_planning_subtree/bot_patrolling/proc/PatrolBehavior(datum/ai_controller/controller, delta_time)
	controller.queue_behavior(/datum/ai_behavior/move_to_next_patrol_point)
