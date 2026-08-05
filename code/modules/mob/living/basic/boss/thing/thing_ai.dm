/datum/ai_controller/basic_controller/thing_boss
	behavior_tree_json = "code/modules/mob/living/basic/boss/thing/thing_boss.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/no_gutted_mobs,
		BB_TARGET_MINIMUM_STAT = DEAD, // Will attack dead ungutted mobs
		BB_THETHING_MELEEMODE = TRUE, //Whether we are using our melee abilities right now
		BB_THETHING_NOAOE = TRUE, // Restricts us to only melee abilities
		BB_THETHING_LASTAOE = null, // Last AOE ability key executed
	)

	ai_movement = /datum/ai_movement/basic_avoidance // dont need anything better because the arena is a square lol

/datum/bt_node/subtree/thing_aoe
	behavior_tree_json = "code/modules/mob/living/basic/boss/thing/thing_aoe.bt.json"

/datum/bt_node/subtree/thing_melee
	behavior_tree_json = "code/modules/mob/living/basic/boss/thing/thing_melee.bt.json"
