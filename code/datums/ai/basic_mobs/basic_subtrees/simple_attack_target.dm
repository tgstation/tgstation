/datum/ai_planning_subtree/basic_melee_attack_subtree
	/// What do we do in order to attack someone?
	var/datum/ai_behavior/basic_melee_attack/melee_attack_behavior = /datum/ai_behavior/basic_melee_attack
	/// Is this the last thing we do? (if we set a movement target, this will usually be yes)
	var/end_planning = TRUE

/datum/ai_planning_subtree/basic_melee_attack_subtree/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	controller.queue_behavior(melee_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	if (end_planning)
		return SUBTREE_RETURN_FINISH_PLANNING //we are going into battle...no distractions.

/datum/ai_planning_subtree/basic_ranged_attack_subtree
	operational_datums = list(/datum/component/ranged_attacks)
	var/datum/ai_behavior/basic_ranged_attack/ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack

/datum/ai_planning_subtree/basic_ranged_attack_subtree/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	controller.queue_behavior(ranged_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING //we are going into battle...no distractions.

/datum/ai_planning_subtree/basic_melee_attack_subtree/no_fisherman

/datum/ai_planning_subtree/basic_melee_attack_subtree/no_fisherman/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/movable/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return ..()
	if(!HAS_TRAIT(target, TRAIT_SCARY_FISHERMAN))
		return ..()

/datum/ai_planning_subtree/basic_melee_attack_subtree/multi_target
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/multi_target
	/// Behavior used for secondary targets
	var/secondary_melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/multi_target

/datum/ai_planning_subtree/basic_melee_attack_subtree/multi_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/found_target = FALSE
	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		controller.queue_behavior(melee_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
		found_target = TRUE

	if(length(controller.blackboard[BB_BASIC_MOB_SECONDARY_TARGET_LIST]))
		controller.queue_behavior(secondary_melee_attack_behavior, BB_BASIC_MOB_SECONDARY_TARGET_LIST, BB_TARGETING_STRATEGY, null)
		found_target = TRUE

	if (end_planning && found_target)
		return SUBTREE_RETURN_FINISH_PLANNING // we are going into battle... no distractions.
