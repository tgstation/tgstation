/datum/ai_controller/basic_controller/cow
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/cow/cow.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("moo?", "moo", "MOOOOOO"),
			BB_EMOTE_HEAR = list("brays."),
			BB_EMOTE_SEE = list("shakes her head."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/cow/cow.ogg'),
			BB_SPEAK_CHANCE = 1,
		),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance

/// While we're tipped over, plead with nearby people instead of doing anything else.
/datum/bt_node/subtree/tip_reaction
	behavior_tree_json = "code/datums/ai/basic_mobs/basic_subtrees/tip_reaction.bt.json"

/// Avoid attacking people holding food for taming.
/datum/targeting_strategy/basic/allow_items/tameable
	// Path to required food
	var/tame_food

/datum/targeting_strategy/basic/allow_items/tameable/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE

	if(isliving(the_target)) //Targeting vs living mobs
		var/mob/living/living_target = the_target
		for(tame_food in living_target.held_items)
			return FALSE //heyyy this can tame me! let's NOT fight
