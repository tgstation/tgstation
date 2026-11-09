/// Cowardly when small, aggressive when big. Tries to transform whenever possible.
/datum/ai_controller/basic_controller/wumborian_fugu
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/wumborian_fugu/wumborian_fugu.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
