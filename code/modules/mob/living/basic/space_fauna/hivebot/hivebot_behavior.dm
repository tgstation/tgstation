/datum/ai_behavior/find_and_set/hive_partner

/datum/ai_behavior/find_and_set/hive_partner/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	var/list/hive_partners = list()
	for(var/mob/living/target in oview(10, living_pawn))
		if(!istype(target, locate_path))
			continue
		if(target.stat == DEAD)
			continue
		hive_partners += target

	if(length(hive_partners))
		return pick(hive_partners)


/datum/ai_behavior/relay_message
	var/length_of_message = 4
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT|AI_BEHAVIOR_REQUIRE_REACH


/datum/ai_behavior/relay_message/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	// It stopped existing
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)


/datum/ai_behavior/relay_message/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return
	var/message_relayed = ""
	for(var/i in 1 to length_of_message)
		if(prob(50))
			message_relayed += "1"
			continue
		message_relayed += "0"
	living_pawn.say(message_relayed, forced = "AI Controller")
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/relay_message/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/find_hunt_target/repair_machines

/datum/ai_behavior/find_hunt_target/repair_machines/valid_dinner(mob/living/source, obj/machinery/repair_target, radius)
	if(repair_target.get_integrity() >= repair_target.max_integrity)
		return FALSE

	return can_see(source, repair_target, radius)

/datum/ai_behavior/hunt_target/repair_machines
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/repair_machines/target_caught(mob/living/hunter, obj/machinery/repair_target)
	var/datum/callback/callback = CALLBACK(hunter, TYPE_PROC_REF(/mob/living/basic/hivebot/mechanic, repair_machine), repair_target)
	callback.Invoke()

/datum/ai_behavior/basic_ranged_attack/hivebot
	action_cooldown = 3 SECONDS

/datum/ai_behavior/basic_ranged_attack/hivebot_rapid
	action_cooldown = 1.5 SECONDS
