/datum/targetting_datum/floorbot

/datum/targetting_datum/floorbot/can_attack(mob/living/living_mob, atom/the_target)
	var/mob/living/basic/bot/floorbot/floorbot = living_mob

	if(IS_DATUM_RESERVED_BY(the_target, TRAIT_AI_FLOOR_WORK_RESERVATION, floorbot)) //Check if someone is already cleaning it!
		return FALSE

	if(living_mob.ai_controller.blackboard[BB_IGNORE_LIST][WEAKREF(the_target)])
		return FALSE

	var/target_is_floor = isfloorturf(the_target)
	var/target_is_plating = isplatingturf(the_target)

	if(!isopenturf(the_target))
		return FALSE

	if(floorbot.bot_cover_flags & BOT_COVER_EMAGGED && target_is_floor && !target_is_plating)
		return TRUE

	if(isspaceturf(the_target))
		var/area/target_area = get_area(the_target)
		if(!(target_area.area_flags & NOT_HULLBREACHABLE)) //The area is not space or a shuttle.
			return TRUE

	if(floorbot.floorbot_mode_flags & FLOORBOT_FIX_FLOORS && target_is_floor)
		var/turf/open/floor/target_floor = the_target
		if(target_floor.broken || target_floor.burnt)
			return TRUE

	if(floorbot.floorbot_mode_flags & FLOORBOT_PLACE_TILES && target_is_plating)
		return TRUE

	if(floorbot.floorbot_mode_flags & FLOORBOT_REPLACE_TILES && floorbot.tilestack && target_is_floor)
		var/turf/open/floor/target_floor = the_target
		if((target_floor.type != floorbot.tilestack.turf_type)) //Don't replace if same type
			return TRUE
