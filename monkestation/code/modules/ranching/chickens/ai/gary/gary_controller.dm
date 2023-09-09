/datum/ai_controller/chicken/gary
	planning_subtrees = list(
		/datum/ai_planning_subtree/gary,
		/datum/ai_planning_subtree/flee_target/low_health,
		)
	idle_behavior = /datum/idle_behavior/chicken

/datum/ai_controller/chicken/gary/TryPossessPawn(atom/new_pawn)
	. = ..()
	blackboard += BB_GARY_HIDEOUT
	blackboard += BB_GARY_TARGET_AREA
	blackboard += BB_GARY_BARTERING
	blackboard += BB_GARY_BARTER_FRIEND
	blackboard += BB_GARY_HIDEOUT_SETTING_UP
	blackboard += BB_GARY_COME_HOME
	blackboard += BB_GARY_HAS_SHINY
