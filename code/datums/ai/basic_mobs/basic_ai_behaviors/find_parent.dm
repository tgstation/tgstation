/// Looks around for a nearby adult of one of BB_FIND_MOM_TYPES (skipping BB_IGNORE_MOM_TYPES) and stores it.
/datum/bt_node/ai_behavior/find_mom
	time_between_perform = 2 SECONDS
	/// How far to look for our parent.
	var/look_range = 7
	/// Blackboard key holding the list of typepaths we accept as parents.
	var/mom_types_key = BB_FIND_MOM_TYPES
	/// Blackboard key holding typepaths to skip even if they match (e.g. other babies).
	var/ignore_types_key = BB_IGNORE_MOM_TYPES
	/// Blackboard key to store the found parent in.
	var/found_mom_key = BB_FOUND_MOM

/datum/bt_node/ai_behavior/find_mom/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living_pawn = controller.pawn
	var/list/mom_types = controller.blackboard[mom_types_key]
	if(!length(mom_types))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/ignore_types = controller.blackboard[ignore_types_key]
	var/list/all_moms = list()
	for(var/mob/mother in oview(look_range, living_pawn))
		if(is_possible_mom(mother, mom_types, ignore_types))
			all_moms += mother

	if(length(all_moms))
		controller.set_blackboard_key(found_mom_key, pick(all_moms))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/find_mom/proc/is_possible_mom(mob/mother, list/mom_types, list/ignore_types)
	if(!is_type_in_list(mother, mom_types))
		return FALSE
	if(is_type_in_list(mother, ignore_types))
		return FALSE
	return TRUE

/// A baby emotes at its parent: crying if the parent is dead, dancing happily otherwise.
/datum/bt_node/ai_behavior/look_to_parent
	/// Blackboard key holding the parent to react to.
	var/parent_key = BB_FOUND_MOM

/datum/bt_node/ai_behavior/look_to_parent/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/parent = controller.blackboard[parent_key]
	if(QDELETED(parent))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/baby = controller.pawn
	if(parent.stat == DEAD)
		baby.manual_emote("cries for their parent!")
	else
		baby.manual_emote("dances around their parent!")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
