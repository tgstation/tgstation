/// Cowardly when small, aggressive when big. Tries to transform whenever possible.
/datum/ai_controller/basic_controller/wumborian_fugu
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/wumborian_fugu/wumborian_fugu.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/wumborian_fugu
	attack_behaviour = /datum/ai_behavior/attack_obstructions/wumborian_fugu

/datum/ai_behavior/attack_obstructions/wumborian_fugu
	can_attack_turfs = TRUE
	time_between_perform = 2.5 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/inflate
	ability_key = BB_FUGU_INFLATE
