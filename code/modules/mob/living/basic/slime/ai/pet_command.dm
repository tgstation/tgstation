/datum/pet_command/point_targeting/attack/slime
	speech_commands = list("attack", "sic", "kill", "eat", "feed")
	command_feedback = "blorbles"
	pointed_reaction = "and blorbles"
	refuse_reaction = "jiggles sadly"

	var/hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/slime

/datum/pet_command/point_targeting/attack/slime/execute_action(datum/ai_controller/controller)

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(isslime(slime_pawn) && slime_pawn.can_feed_on(controller.blackboard[BB_CURRENT_PET_TARGET], check_friendship = TRUE))
		controller.queue_behavior(hunting_behavior, BB_CURRENT_PET_TARGET, BB_HUNTING_COOLDOWN)
		return SUBTREE_RETURN_FINISH_PLANNING

	return ..()
