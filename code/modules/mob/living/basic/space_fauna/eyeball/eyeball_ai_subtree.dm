/datum/ai_controller/basic_controller/eyeball
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/eyeball,
		BB_EYE_DAMAGE_THRESHOLD = 10,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/glare,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/heal_the_blind,
		/datum/ai_planning_subtree/find_and_hunt_target/carrot,
	)

/datum/ai_planning_subtree/heal_the_blind

/datum/ai_planning_subtree/heal_the_blind/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_BLIND_TARGET))
		controller.queue_behavior(/datum/ai_behavior/heal_eye_damage, BB_BLIND_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_the_blind, BB_BLIND_TARGET, BB_EYE_DAMAGE_THRESHOLD)

/datum/targeting_strategy/basic/eyeball/can_attack(mob/living/owner, atom/target, vision_range)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return TRUE
	var/mob/living/carbon/human_target = target
	if(human_target.is_blind())
		return FALSE
	var/eye_damage_threshold = owner.ai_controller.blackboard[BB_EYE_DAMAGE_THRESHOLD]
	if(!eye_damage_threshold)
		return TRUE
	var/obj/item/organ/eyes/eyes = human_target.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes.damage > eye_damage_threshold) //we dont attack people with bad vision
		return FALSE

	return can_see(target, owner, 9) //if the target cant see us dont attack him

/datum/ai_planning_subtree/targeted_mob_ability/glare
	ability_key = BB_GLARE_ABILITY
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/glare_at_target
	finish_planning = TRUE

/datum/ai_planning_subtree/find_and_hunt_target/carrot
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/carrot
	hunt_targets = list(/obj/item/food/grown/carrot)
	hunt_range = 6
