/datum/pet_command/attack/slime
	speech_commands = list("attack", "sic", "kill", "eat", "feed", "glop")

/datum/pet_command/attack/slime/get_feedback_message(mob/living/parent, feedback_type, mob/living/commander = null, atom/target = null, explicit_command = FALSE)
	switch(feedback_type)
		if(PET_COMMAND_FEEDBACK_ACTIVATED)
			return "[parent] glops"
		if(PET_COMMAND_FEEDBACK_REFUSED_TARGET)
			return target ? "[parent] jiggles sadly at [target]" : "[parent] jiggles sadly"
		if(PET_COMMAND_FEEDBACK_ACCEPTED_TARGET)
			return "[parent] glops at [target]"
	return ..()

/datum/pet_command/attack/slime/execute_action(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(isslime(slime_pawn) && slime_pawn.can_feed_on(controller.blackboard[BB_CURRENT_PET_TARGET], check_friendship = TRUE))
		controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/attack/slime)
		return
	return ..()
