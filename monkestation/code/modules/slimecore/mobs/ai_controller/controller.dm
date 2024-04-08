/datum/ai_controller/basic_controller/slime
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_BASIC_MOB_SCARED_ITEM = /obj/item/extinguisher,
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_WONT_TARGET_CLIENTS = FALSE, //specifically to stop targetting clients
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_slime_playful
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		//we try to flee first these flip flop based on flee state which is controlled by a componenet on the mob
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee_has_item,
		/datum/ai_planning_subtree/flee_target,
		//now we try to
		/datum/ai_planning_subtree/simple_find_target_no_trait/slime,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/slime,
	)
