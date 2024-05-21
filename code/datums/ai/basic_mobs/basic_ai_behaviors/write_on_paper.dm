/datum/ai_behavior/write_on_paper

/datum/ai_behavior/write_on_paper/perform(seconds_per_tick, datum/ai_controller/controller, found_paper, list_of_writings)
	var/mob/living/wizard = controller.pawn
	var/list/writing_list = controller.blackboard[list_of_writings]
	var/obj/item/paper/target = controller.blackboard[found_paper]
	if(length(writing_list))
		target.add_raw_text(pick(writing_list))
		target.update_appearance()
	wizard.dropItemToGround(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/write_on_paper/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
