
/datum/ai_controller/haunted
	movement_delay = 0.4 SECONDS
	blackboard = list(
		BB_ITEM_MOVE_AND_ATTACK_TYPE = /datum/ai_behavior/item_move_close_and_attack/ghostly,
		BB_ITEM_AGGRO_ADDITION = 2,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/item_ghost_resist,
		/datum/ai_planning_subtree/item_aggro_attack,
	)
	idle_behavior = /datum/idle_behavior/idle_ghost_item

/datum/ai_controller/haunted/TryPossessPawn(atom/new_pawn)
	if(!isitem(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
