/// As base but stop if the command is rescinded
/datum/ai_behavior/basic_melee_attack/pet_command

/datum/ai_behavior/basic_melee_attack/pet_command/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	if (controller.blackboard[BB_ACTIVE_PET_COMMAND] != PET_COMMAND_ATTACK)
		finish_action(controller, FALSE, target_key, targetting_datum_key, hiding_location_key)
		return
	return ..()
