/// Basetype with normal parameters
/datum/ai_controller/basic_controller/simple
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = ABSTRACT_AI_CLASS


/datum/bt_node/subtree/simple_hostile_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_hostile_combat.bt.json"


/datum/ai_controller/basic_controller/simple/simple_hostile
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_hostile.bt.json"


/datum/bt_node/subtree/simple_ranged_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ranged_combat.bt.json"

/datum/bt_node/subtree/simple_ranged_retaliate_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ranged_retaliate_combat.bt.json"


/datum/bt_node/subtree/simple_skirmisher_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_skirmisher_combat.bt.json"

/datum/bt_node/subtree/simple_ability_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_combat.bt.json"

/datum/bt_node/subtree/simple_ability_retaliate_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_retaliate_combat.bt.json"

/datum/bt_node/subtree/simple_ability_melee_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_melee_combat.bt.json"

/datum/bt_node/subtree/simple_ability_ranged_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_ranged_combat.bt.json"


/datum/bt_node/subtree/simple_retaliate_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_retaliate_combat.bt.json"

/datum/bt_node/subtree/simple_capricious_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_capricious_combat.bt.json"

/datum/bt_node/subtree/simple_fearful_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_fearful_combat.bt.json"

/datum/bt_node/subtree/simple_skittish_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_skittish_combat.bt.json"

/datum/bt_node/subtree/simple_hostile_obstacles_combat
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_hostile_obstacles_combat.bt.json"



/// Find a target, walk at target, attack intervening obstacles
/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_hostile_obstacles.bt.json"

/// Find a target, maintain distance, shoot them
/datum/ai_controller/basic_controller/simple/simple_ranged
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ranged.bt.json"

/datum/ai_controller/basic_controller/simple/simple_ranged_retaliate
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ranged_retaliate.bt.json"

/// Find a target, walk towards it AND shoot it
/datum/ai_controller/basic_controller/simple/simple_skirmisher
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_skirmisher.bt.json"

/// Use an ability on target on cooldown
/datum/ai_controller/basic_controller/simple/simple_ability
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability.bt.json"

/datum/ai_controller/basic_controller/simple/simple_ability_retaliate
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_retaliate.bt.json"

/// Use an ability on target on cooldown, then try to punch them
/datum/ai_controller/basic_controller/simple/simple_ability_melee
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_melee.bt.json"

/// Use an ability on target on cooldown, then try to shoot them
/datum/ai_controller/basic_controller/simple/simple_ability_ranged
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_ranged.bt.json"

/// Fight back if attacked
/datum/ai_controller/basic_controller/simple/simple_retaliate
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_retaliate.bt.json"
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED

/// Get pissed at random people for no reason
/datum/ai_controller/basic_controller/simple/simple_capricious
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_capricious.bt.json"
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED

/// Runs away from anyone it sees
/datum/ai_controller/basic_controller/simple/simple_fearful
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_fearful.bt.json"
	ai_traits = PASSIVE_AI_FLAGS

/// Runs away when attacked
/datum/ai_controller/basic_controller/simple/simple_skittish
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_skittish.bt.json"
	ai_traits = PASSIVE_AI_FLAGS

/// Does what it is told and protects da boss
/// TODO: port pet command system to BT so pet_planning functions correctly
/datum/ai_controller/basic_controller/simple/simple_goon
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_goon.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)


/// Literally does nothing except random speech
/datum/ai_controller/basic_controller/talk
	behavior_tree_json = "code/datums/ai/basic_mobs/talk.bt.json"


/datum/bt_node/subtree/simple_hostile_combat_with_retaliate
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_hostile_combat_with_retaliate.bt.json"
