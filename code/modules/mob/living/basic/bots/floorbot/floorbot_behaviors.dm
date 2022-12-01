/datum/ai_behavior/repair_floor
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM


/datum/ai_behavior/repair_floor/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	var/mob/living/basic/bot/bot = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	RESERVE_DATUM(target, TRAIT_AI_FLOOR_WORK_RESERVATION, bot)

/datum/ai_behavior/repair_floor/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	var/atom/target = controller.blackboard[target_key]

	if(!targetting_datum.can_attack(controller.pawn, target))
		finish_action(controller, FALSE)

	if(DT_PROB(5, delta_time))
		controller.pawn.audible_message("[controller.pawn] makes an excited beeping booping sound!")

	var/mob/living/basic/bot/floorbot/floorbot = controller.pawn

	if(controller.blackboard[BB_FLOOR_BOT_BUSY_DOING_FLOOR_WORK])
		return

	if(get_dist(controller.pawn, target) <= required_distance)
		controller.blackboard[BB_FLOOR_BOT_BUSY_DOING_FLOOR_WORK] = TRUE

		if(floorbot.bot_cover_flags & BOT_COVER_EMAGGED)
			floorbot.grief(target_key)
			finish_action(controller, TRUE, target_key)

		if(floorbot.repair(target))
			finish_action(controller, TRUE, target_key)

/datum/ai_behavior/repair_floor/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()

	var/mob/living/basic/bot/floorbot/floorbot = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(target)
		UNRESERVE_DATUM(target, TRAIT_AI_FLOOR_WORK_RESERVATION, floorbot)
	floorbot.set_current_mode()

	if(!succeeded)
		controller.blackboard[BB_IGNORE_LIST][WEAKREF(target)] = TRUE

	controller.blackboard[BB_FLOOR_BOT_BUSY_DOING_FLOOR_WORK] = FALSE
	controller.blackboard[target_key] = null
