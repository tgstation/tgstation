//Smash obstacles between us and our target. Does not prevent replanning so can be cancelled out of nowhere and does not self-cancel.
/datum/ai_behavior/basic_smash_obstacles
	action_cooldown = 1 SECONDS
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_ALLOWS_REPLANNING

/datum/ai_behavior/basic_smash_obstacles/setup(datum/ai_controller/controller)
	. = ..()

/datum/ai_behavior/basic_smash_obstacles/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/mob_pawn = controller.pawn
	if(mob_pawn.buckled)
		mob_pawn.buckled.attack_basic_mob(src)
	if(!isturf(mob_pawn.loc) && !isnull(mob_pawn.loc))//Did someone put us in something?
		mob_pawn.loc.attack_basic_mob(src)//Bang on it till we get out

	var/dir_to_target = get_dir(mob_pawn, controller.current_movement_target)
	var/dir_list = list()

	if(ISDIAGONALDIR(dir_to_target)) //it's diagonal, so we need two directions to hit. apparently
		for(var/direction in GLOB.cardinals)
			if(direction & dir_to_target)
				dir_list += direction
	else
		dir_list += dir_to_target
	for(var/direction in dir_list) //now we hit all of the directions we got in this fashion, since it's the only directions we should actually need
		var/turf/turf_in_direction = get_step(mob_pawn, direction)
		if(QDELETED(turf_in_direction))
			continue
		if(turf_in_direction.Adjacent(mob_pawn)) //Required because it might be obscured by cardinals.
			if(iswallturf(turf_in_direction) || ismineralturf(turf_in_direction))
				turf_in_direction.attack_basic_mob(mob_pawn)
				break
		for(var/obj/object_in_direction in turf_in_direction.contents)
			if(!object_in_direction.Adjacent(mob_pawn))
				continue
			if((ismachinery(object_in_direction) || isstructure(object_in_direction)) && object_in_direction.density && mob_pawn.environment_smash & ENVIRONMENT_SMASH_STRUCTURES && !object_in_direction.IsObscured())
				object_in_direction.attack_basic_mob(mob_pawn)
				break

