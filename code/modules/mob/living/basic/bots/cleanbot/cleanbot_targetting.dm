/datum/targetting_datum/cleanbot
	var/max_target_distance = 20

/datum/targetting_datum/cleanbot/can_attack(mob/living/living_mob, atom/the_target)
	if(!istype(living_mob, /mob/living/basic/bot)) // bail out on invalids
		return FALSE

	var/mob/living/basic/bot/targetting_bot = living_mob


	if(iscarbon(the_target))
		var/mob/living/carbon/target_carbon = the_target
		if(!(target_carbon in view(DEFAULT_SCAN_RANGE, src)))
			return null
		if(target_carbon.stat == DEAD)
			return null
		if(target_carbon.body_position != LYING_DOWN)
			return null
		return TRUE
	if(is_type_in_typecache(the_target, targetting_bot.ai_controller.blackboard[BB_CLEAN_BOT_VALID_TARGETS]))
		return the_target

	return FALSE
