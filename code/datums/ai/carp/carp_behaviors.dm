/datum/ai_behavior/battle_screech/carp
	screeches = list("gnashes")

/// This behavior involves attacking a target.
/datum/ai_behavior/carp_attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

/datum/ai_behavior/carp_attack/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return

	var/datum/weakref/attack_ref = controller.blackboard[BB_CARP_ATTACK_TARGET]
	var/atom/movable/attack_target = attack_ref?.resolve()
	if(!attack_target || !can_see(living_pawn, attack_target, length=AI_CARP_VISION_RANGE))
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = attack_target
	if(istype(living_target) && (living_target.stat == DEAD))
		finish_action(controller, TRUE)
		return


	attack(controller, living_target)

/datum/ai_behavior/carp_attack/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.blackboard[BB_CARP_ATTACK_TARGET] = null

/// A proc representing when the mob is pushed to actually attack the target. Again, subtypes can be used to represent different attacks from different animals, or it can be some other generic behavior
/datum/ai_behavior/carp_attack/proc/attack(datum/ai_controller/controller, mob/living/living_target)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.ClickOn(living_target, list())

/datum/ai_behavior/carp_attack/ranged
	required_distance = 3

/// This behavior involves attacking a target.
/datum/ai_behavior/carp_follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

/datum/ai_behavior/carp_follow/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return

	var/datum/weakref/follow_ref = controller.blackboard[BB_CARP_FOLLOW_TARGET]
	var/atom/movable/follow_target = follow_ref?.resolve()
	if(!follow_target || !can_see(living_pawn, follow_target, length=AI_CARP_VISION_RANGE))
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = follow_target
	if(istype(living_target) && (living_target.stat == DEAD))
		finish_action(controller, TRUE)
		return

/datum/ai_behavior/carp_follow/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.blackboard[BB_CARP_FOLLOW_TARGET] = null
