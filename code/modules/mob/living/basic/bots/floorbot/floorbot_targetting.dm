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

	var/turf/open/open_turf = the_target

	//Check if the destination is in a tile we can't even enter.
	var/reverse_dir = get_dir(open_turf, src)
	for(var/obj/iter_object in open_turf)
		// This is an optimization because of the massive call count of this code
		if(!iter_object.density && iter_object.can_astar_pass == CANASTARPASS_DENSITY)
			continue
		if(!iter_object.CanAStarPass(floorbot.access_card, reverse_dir, floorbot, FALSE))
			return FALSE

	if(floorbot.bot_cover_flags & BOT_COVER_EMAGGED && target_is_floor && !target_is_plating)
		return TRUE

	if(isspaceturf(the_target))
		var/area/target_area = get_area(the_target)
		if(target_area.area_flags & FLOORBOT_IGNORE) //The area is space or a shuttle.
			return FALSE

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
