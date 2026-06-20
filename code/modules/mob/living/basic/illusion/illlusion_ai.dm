/// Standard Illusion behavior is primarily dependent on their context, whether they exist as a decoy or someone meant to retaliate against a threat (of varied origin)
/// For the time being however, the AI is very simple and doesn't rely on any advanced tactics. Just go to thing it was assigned to attack and attack it (if assigned, else wander around)
/// However, the action we undergo is based on the subtype of illusion we are and that's done on the mob subtype level.
/datum/ai_controller/basic_controller/illusion
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_hostile.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance

/// Escape subtype of illusions are made to flee from threats rather than attack them. They do not undergo any retaliation behavior.
/// We also want to account for the possibility of new threats attacking us and fleeing from those too, more randomness is ideal.
/datum/ai_controller/basic_controller/illusion/escape
	behavior_tree_json = "escape.bt.json"

/// Retaliate subtypes of escape illusions can fight back against threats that attack them, making them more dangerous.
/datum/ai_controller/basic_controller/illusion/escape/retaliate
	behavior_tree_json = "retaliate.bt.json"

