/datum/ai_behavior/clean
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM


/datum/ai_behavior/clean/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	var/mob/living/basic/bot/bot = controller.pawn
	bot.set_current_mode(BOT_CLEANING)
	RegisterSignal(bot, COMSIG_AINOTIFY_CLEANBOT_FINISH_CLEANING, .proc/on_finish_cleaning)

/datum/ai_behavior/clean/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	var/atom/target = controller.blackboard[target_key]

	if(!targetting_datum.can_attack(controller.pawn, target))
		finish_action(controller, FALSE)

	if(DT_PROB(5, delta_time))
		controller.pawn.audible_message("[controller.pawn] makes an excited beeping booping sound!")

	var/mob/living/living_pawn = controller.pawn

	if(controller.blackboard[BB_CLEAN_BOT_BUSY_CLEANING])
		return

	if(get_dist(controller.pawn, target) <= required_distance)
		living_pawn.UnarmedAttack(target, proximity_flag = TRUE) //Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
		controller.blackboard[BB_CLEAN_BOT_BUSY_CLEANING] = TRUE

/datum/ai_behavior/clean/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key)
	. = ..()

	var/mob/living/basic/bot/bot = controller.pawn
	UnregisterSignal(bot, COMSIG_AINOTIFY_CLEANBOT_FINISH_CLEANING, .proc/on_finish_cleaning)
	bot.set_current_mode()

	if(!succeeded)
		var/atom/target = controller.blackboard[BB_CLEAN_BOT_TARGET]
		controller.blackboard[BB_IGNORE_LIST][WEAKREF(target)] = TRUE

	controller.blackboard[BB_CLEAN_BOT_BUSY_CLEANING] = FALSE
	controller.blackboard[BB_CLEAN_BOT_TARGET] = null

/datum/ai_behavior/clean/proc/on_finish_cleaning(datum/source, datum/ai_controller/controller)

	var/list/arguments = list(controller, TRUE)
	var/list/stored_arguments = controller.behavior_args[type]
	if(stored_arguments)
		arguments += stored_arguments

	finish_action(arglist(arguments))


/datum/ai_behavior/evil_clean
	required_distance = 1
	action_cooldown = 1.5 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/evil_clean/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	var/mob/living/basic/bot/bot = controller.pawn
	bot.set_current_mode(BOT_CLEANING)

/datum/ai_behavior/evil_clean/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]


	if(!targetting_datum.can_attack(living_pawn, target))
		finish_action(controller, FALSE)

	living_pawn.UnarmedAttack(target, proximity_flag = TRUE) // Acid spray

/datum/ai_behavior/spray_foam
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/spray_foam/perform(delta_time, datum/ai_controller/controller, ...)
	. = ..()

	var/mob/living/living_pawn = controller.pawn


	if(isopenturf(living_pawn.loc) && DT_PROB(15, delta_time)) // Wets floors and spawns foam randomly
		if(prob(75))
			var/turf/open/current_floor =  living_pawn.loc
			if(istype(current_floor))
				current_floor.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
		else
			living_pawn.visible_message(span_danger("[living_pawn] whirs and bubbles violently, before releasing a plume of froth!"))
			new /obj/effect/particle_effect/fluid/foam(living_pawn.loc)
