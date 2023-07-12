/datum/ai_behavior/find_mom
	///range to look for the mom
	var/look_range = 7

/datum/ai_behavior/find_mom/perform(seconds_per_tick, datum/ai_controller/controller, mom_key, found_mom)
	. = ..()

	var/mob/living_pawn = controller.pawn
	var/list/mom_types = controller.blackboard[mom_key]
	var/list/all_moms = list()
	if(!length(mom_types))
		finish_action(controller, FALSE)
		return

	for(var/mob/mother in oview(look_range, living_pawn))
		if(!is_type_in_list(mother, mom_types))
			continue
		if(istype(mother, living_pawn.type))
			continue
		all_moms += mother

	if(length(all_moms))
		controller.set_blackboard_key(found_mom, pick(all_moms))
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)
