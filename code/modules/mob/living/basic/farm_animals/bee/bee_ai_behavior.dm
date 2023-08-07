/datum/ai_behavior/hunt_target/pollinate
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/pollinate/target_caught(mob/living/hunter, obj/machinery/hydroponics/hydro_target)
	var/datum/callback/callback = CALLBACK(hunter, TYPE_PROC_REF(/mob/living/basic/bee, pollinate), hydro_target)
	callback.Invoke()

/datum/ai_behavior/find_hunt_target/pollinate

/datum/ai_behavior/find_hunt_target/pollinate/valid_dinner(mob/living/source, obj/machinery/hydroponics/dinner, radius)
	if(!dinner.can_bee_pollinate())
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_behavior/enter_exit_hive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/enter_exit_hive/setup(datum/ai_controller/controller, target_key, attack_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/enter_exit_hive/perform(seconds_per_tick, datum/ai_controller/controller, target_key, attack_key)
	. = ..()
	var/obj/structure/beebox/current_home = controller.blackboard[target_key]
	var/mob/living/bee_pawn = controller.pawn
	var/atom/attack_target = controller.blackboard[attack_key]

	if(attack_target) // forget about who we attacking when we go home
		controller.clear_blackboard_key(attack_key)

	var/datum/callback/callback = CALLBACK(bee_pawn, TYPE_PROC_REF(/mob/living/basic/bee, handle_habitation), current_home)
	callback.Invoke()
	finish_action(controller, TRUE)

/datum/ai_behavior/inhabit_hive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/inhabit_hive/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/inhabit_hive/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/structure/beebox/potential_home = controller.blackboard[target_key]
	var/mob/living/bee_pawn = controller.pawn

	if(!potential_home.habitable(bee_pawn)) //the house become full before we get to it
		finish_action(controller, FALSE, target_key)
		return

	var/datum/callback/callback = CALLBACK(bee_pawn, TYPE_PROC_REF(/mob/living/basic/bee, handle_habitation), potential_home)
	callback.Invoke()
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/inhabit_hive/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key) //failed to make it our home so find another

/datum/ai_behavior/find_and_set/bee_hive
	action_cooldown = 10 SECONDS

/datum/ai_behavior/find_and_set/bee_hive/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/valid_hives = list()
	var/mob/living/bee_pawn = controller.pawn

	if(istype(bee_pawn.loc, /obj/structure/beebox))
		return bee_pawn.loc //for premade homes

	for(var/obj/structure/beebox/potential_home in oview(search_range, bee_pawn))
		if(!potential_home.habitable(bee_pawn))
			continue
		valid_hives += potential_home

	if(valid_hives.len)
		return pick(valid_hives)

/datum/targetting_datum/basic/bee

/datum/targetting_datum/basic/bee/can_attack(mob/living/owner, atom/target)
	if(!isliving(target))
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/mob_target = target
	return !(mob_target.bee_friendly())
