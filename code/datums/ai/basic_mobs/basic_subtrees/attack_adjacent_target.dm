/// Attack something which is already adjacent to us, without ending planning
/datum/ai_planning_subtree/attack_adjacent_target
	/// Behaviour to execute to slap someone
	var/melee_attack_behavior = /datum/ai_behavior/attack_adjacent_target
	/// Blackboard key in which to store targetting datum
	var/targetting_key = BB_TARGETTING_DATUM
	/// Blackboard key in which to store selected target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Blackboard key in which to store selected target hiding place
	var/hiding_key = BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION

/datum/ai_planning_subtree/attack_adjacent_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || !controller.pawn.Adjacent(target))
		return
	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (LAZYLEN(pawn.do_afters))
			return
	controller.queue_behavior(melee_attack_behavior, targetting_key, target_key, hiding_key)

/// Attack something which is already adjacent to us
/datum/ai_behavior/attack_adjacent_target
	action_cooldown = 0.2 SECONDS

/datum/ai_behavior/attack_adjacent_target/perform(seconds_per_tick, datum/ai_controller/controller, targetting_datum_key, target_key, hiding_location_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if(!targetting_datum.can_attack(controller.pawn, target) || !controller.pawn.Adjacent(target))
		finish_action(controller, succeeded = FALSE)
		return
	if (!isliving(controller.pawn))
		return
	var/mob/living/pawn = controller.pawn
	if (world.time < pawn.next_move)
		finish_action(controller, succeeded = FALSE)
		return
	pawn.combat_mode = TRUE
	pawn.ClickOn(target, list())
	finish_action(controller, succeeded = TRUE)
