/datum/ai_behavior/basic_melee_attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	controller.
	controller.current_movement_target =  controller.blackboard[hiding_location_key] || controller.blackboard[target_key] //Hiding location is priority

/datum/ai_behavior/basic_melee_attack/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	controller.blackboard[target_key] = null

	if(!target || !targetting_datum.can_attack(basic_mob, target)) //Need a new target
		finish_action(controller, FALSE)
		return

	var/turf/T = get_turf(src)

	var/target_distance = get_dist(basic_mob, target)

	var/hiding_target = targetting_datum.find_hidden_mobs(basic_mob, target) //They're still hidden!

	if(hiding_target && hiding_target != controller.blackboard[hiding_location_key]) //But not in the same place!
		controller.blackboard[hiding_location_key] = hiding_target

	if(hiding_target) //Slap it!
		MeleeAttack(hiding_target)
	else
		MeleeAttack(target)


/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(!succeeded)
		controller.blackboard[target_key] = null
