/datum/ai_planning_subtree/find_and_hunt_target/look_for_functional_pipes
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/functional_plasma_pipes
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/plasma_extraction_pipe
	hunt_targets = list(/obj/structure/liquid_plasma_extraction_pipe)
	hunt_range = 7

/datum/ai_behavior/hunt_target/unarmed_attack_target/plasma_extraction_pipe
	hunt_cooldown = 10 SECONDS
	always_reset_target = TRUE

/datum/ai_behavior/find_hunt_target/functional_plasma_pipes

/datum/ai_behavior/find_hunt_target/functional_plasma_pipes/valid_dinner(mob/living/source, obj/structure/liquid_plasma_extraction_pipe/dinner, radius)
	if(dinner.pipe_state != PIPE_STATE_FINE || dinner.pipe_status != PIPE_STATUS_ON) //only home in on ones running & making 'noise' (aka is active)
		return FALSE

	return can_see(source, dinner, radius)
