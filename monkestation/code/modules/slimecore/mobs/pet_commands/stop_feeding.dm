/datum/pet_command/stop_eating
	command_name = "Stop Eating"
	command_desc = "Command your pet to stop eating."
	radial_icon = 'icons/testing/turf_analysis.dmi'
	radial_icon_state = "red_arrow"
	speech_commands = list("stop eating", "get off")

/datum/pet_command/stop_eating/execute_action(datum/ai_controller/controller)
	var/mob/living/mob = controller.pawn
	if(mob.buckled)
		mob.buckled.unbuckle_mob(mob, force=TRUE)

	return SUBTREE_RETURN_FINISH_PLANNING
