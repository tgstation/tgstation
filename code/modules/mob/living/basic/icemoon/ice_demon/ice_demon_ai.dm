/datum/ai_controller/basic_controller/ice_demon
	behavior_tree_json = "ice_demon.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 7,
		BB_LIST_SCARY_ITEMS = list(
			/obj/item/weldingtool,
			/obj/item/flashlight/flare,
		),
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/basic_controller/ice_demon/afterimage
	behavior_tree_json = "ice_demon_afterimage.bt.json"

/// Flees from a target holding a lit scary item, slipping them on the way out.
/datum/bt_node/subtree/ice_demon_flee_from_fire
	behavior_tree_json = "ice_demon_flee_from_fire.bt.json"


/datum/bt_node/subtree/ice_demon_combat
	behavior_tree_json = "ice_demon_combat.bt.json"
