/datum/ai_controller/basic_controller/hugglebipper
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/hugglebipper_stalking,
		//attacking will remove the person it attacked
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/hugglebipper_stalking

/datum/ai_planning_subtree/hugglebipper_stalking/SelectBehaviors(datum/ai_controller/controller, delta_time)

	if(controller.blackboard[BB_HUGGLEBIPPER_STOP_STALKING])
		return //skip stalking behavior and act!

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(!target || QDELETED(target))
		return SUBTREE_RETURN_FINISH_PLANNING //also stop because if we have no target we have nothing to do after stalking

	controller.queue_behavior(/datum/ai_behavior/hugglebipper_stalking, BB_BASIC_MOB_CURRENT_TARGET)

	return SUBTREE_RETURN_FINISH_PLANNING //focus on stalking

/datum/ai_behavior/hugglebipper_stalking
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 7

/datum/ai_behavior/hugglebipper_stalking/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE
	controller.current_movement_target = target
	RegisterSignal(target, COMSIG_FIRER_PROJECTILE_ON_HIT, .proc/on_projectile_hit)
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/on_item_afterattack)

///hugglebipper's reaction to you putting a mob in crit via projectile
/datum/ai_behavior/hugglebipper_stalking/proc/on_projectile_hit(mob/living/firer, atom/fired_from, atom/target, angle)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.stat == CONSCIOUS || living_target == firer || istype(living_target, /mob/living/basic/mining/hugglebipper))
		return
	//target got harmed, try to """"save"""" our stalk target

	var/datum/ai_controller/controller = firer.ai_controller
	if(!controller)
		return //i have no idea how this would happen but it should be considered
	controller.blackboard[BB_HUGGLEBIPPER_STOP_STALKING] = TRUE

///hugglebipper's reaction to you putting a mob in crit via weapon
/datum/ai_behavior/hugglebipper_stalking/proc/on_item_afterattack(mob/living/attacker, atom/target, obj/item/weapon, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.stat == CONSCIOUS || living_target == attacker || istype(living_target, /mob/living/basic/mining/hugglebipper))
		return
	//target got harmed, try to """"save"""" our stalk target

	var/datum/ai_controller/controller = attacker.ai_controller
	if(!controller)
		return //i have no idea how this would happen but it should be considered
	controller.blackboard[BB_HUGGLEBIPPER_STOP_STALKING] = TRUE

/datum/ai_behavior/hugglebipper_stalking/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()

	if(controller.blackboard[BB_HUGGLEBIPPER_STOP_STALKING])
		//oh shit, go """help""" them!
		finish_action(controller, TRUE, target_key)

	//targetting datum will kill the action if not real anymore
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target?.resolve()

	if(!target)
		//false means forget the target too
		finish_action(controller, FALSE, target_key)
		return

	if(target.stat > SOFT_CRIT)
		//oh shit, go actually help them!
		finish_action(controller, TRUE, target_key)

/datum/ai_behavior/hugglebipper_stalking/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target?.resolve()
	if(target)
		UnregisterSignal(target, list(COMSIG_FIRER_PROJECTILE_ON_HIT, COMSIG_MOB_ITEM_AFTERATTACK))
		if(succeeded)
			var/mob/living/basic/hugglebipper = controller.pawn
			hugglebipper.say("Me help, me help!!")
	if(!succeeded)
		controller.blackboard -= target_key
		return
