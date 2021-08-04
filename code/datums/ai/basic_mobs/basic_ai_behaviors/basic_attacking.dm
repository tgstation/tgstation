
/datum/ai_behavior/can_still_attack_target
	action_cooldown = 2 SECONDS

/datum/ai_behavior/can_still_attack_target/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum.can_attack(basic_mob, target))
		finish_action(controller, TRUE, target_key)
		controller.CancelActions() //Abort!
		return

/datum/ai_behavior/can_still_attack_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.blackboard[target_key] = null

/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	controller.current_movement_target =  controller.blackboard[hiding_location_key] || controller.blackboard[target_key] //Hiding location is priority

/datum/ai_behavior/basic_melee_attack/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	var/hiding_target = targetting_datum.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!

	controller.blackboard[hiding_location_key] = hiding_target

	if(hiding_target) //Slap it!
		basic_mob.melee_attack(hiding_target)
	else
		basic_mob.melee_attack(target)


/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.blackboard[target_key] = null
/datum/ai_behavior/basic_ranged_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3

/datum/ai_behavior/basic_ranged_attack/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	controller.current_movement_target =  controller.blackboard[hiding_location_key] || controller.blackboard[target_key] //Hiding location is priority


/datum/ai_behavior/basic_ranged_attack/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!target) //Need a new target
		finish_action(controller, FALSE)
		return

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat) //owned noob
			finish_action(controller, FALSE)

	var/hiding_target = targetting_datum.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!

	controller.blackboard[hiding_location_key] = hiding_target

	if(hiding_target) //Shoot it!
		basic_mob.RangedAttack(hiding_target)
	else
		basic_mob.RangedAttack(target)

/datum/ai_behavior/basic_ranged_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.blackboard[target_key] = null
