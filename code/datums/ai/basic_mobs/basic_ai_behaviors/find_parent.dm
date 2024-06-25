/datum/ai_behavior/find_mom
	///range to look for the mom
	var/look_range = 7

/datum/ai_behavior/find_mom/perform(seconds_per_tick, datum/ai_controller/controller, mom_key, ignore_mom_key, found_mom)
	var/mob/living_pawn = controller.pawn
	var/list/mom_types = controller.blackboard[mom_key]
	var/list/all_moms = list()
	var/list/ignore_types = controller.blackboard[ignore_mom_key]

	if(!length(mom_types))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	for(var/mob/mother in oview(look_range, living_pawn))
		if(!is_type_in_list(mother, mom_types))
			continue
		if(is_type_in_list(mother, ignore_types)) //so the not permanent baby and the permanent baby subtype dont followed each other
			continue
		all_moms += mother

	if(length(all_moms))
		controller.set_blackboard_key(found_mom, pick(all_moms))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
