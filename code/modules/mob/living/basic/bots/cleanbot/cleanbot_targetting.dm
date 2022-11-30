/datum/targetting_datum/cleanbot
	var/max_target_distance = 20

/datum/targetting_datum/cleanbot/can_attack(mob/living/living_mob, atom/the_target)
	if(!istype(living_mob, /mob/living/basic/bot)) // bail out on invalids
		return FALSE

	var/mob/living/basic/bot/targetting_bot = living_mob

	if(QDELETED(the_target) || !isturf(the_target.loc))
		return FALSE

	if(living_mob.ai_controller.blackboard[BB_IGNORE_LIST][WEAKREF(the_target)])
		return FALSE

	if(isliving(the_target))
		var/mob/living/living_target = the_target
		if(living_target.stat == DEAD)
			return FALSE

		if(iscarbon(living_target))
			var/mob/living/carbon/target_carbon = living_target
			if(target_carbon.body_position != LYING_DOWN)
				return FALSE


	if(!is_type_in_typecache(the_target, targetting_bot.ai_controller.blackboard[BB_CLEAN_BOT_VALID_TARGETS]))
		return FALSE

	if(IS_DATUM_RESERVED_BY(the_target, TRAIT_AI_CLEANING_RESERVATION, living_mob)) //Check if someone is already cleaning it!
		return FALSE

	return TRUE
