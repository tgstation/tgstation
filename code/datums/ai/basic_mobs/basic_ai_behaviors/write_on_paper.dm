/// Scrawls a random line from the writing list onto the carried paper, then drops it. Clears the carry key on finish.
/datum/bt_node/ai_behavior/write_on_paper
	/// Blackboard key holding the paper to write on (also the virtual carry slot).
	var/paper_key
	/// Blackboard key holding the list of phrases to choose from.
	var/writing_list_key

/datum/bt_node/ai_behavior/write_on_paper/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/wizard = controller.pawn
	var/obj/item/paper/target = controller.blackboard[paper_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/writing_list = controller.blackboard[writing_list_key]
	if(length(writing_list))
		target.add_raw_text(pick(writing_list))
		target.update_appearance()
	if(target.loc == wizard)
		target.forceMove(get_turf(wizard))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/write_on_paper/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(paper_key)
