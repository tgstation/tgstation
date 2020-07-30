/obj/effect/proc_holder/spell/cone
	name = "Cone of Nothing"
	desc = "Does nothing in a cone! Wow!"
	school = "evocation"
	charge_max = 100
	clothes_req = FALSE
	invocation = "FUKAN NOTHAN"
	invocation_type = "shout"
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	range = -1
	cooldown_min = 0.5 SECONDS
	///This controls how many levels the cone has, increase this value to make a bigger cone.
	var/cone_levels = 3
	///This var controls how many tiles the cone grows in a straight line before expanding.
	///This value determines if the cone penetrates walls.
	var/respect_density = FALSE

/obj/effect/proc_holder/spell/cone/choose_targets(mob/user = usr)
	perform(null, user=user)

///This proc creates a list of turfs that are hit by the cone
/obj/effect/proc_holder/spell/cone/proc/cone_helper(var/turf/starter_turf, var/dir_to_use, var/cone_levels = 3)
	var/list/turfs_to_return = list()
	var/turf/turf_to_use = starter_turf
	var/turf/left_turf
	var/turf/right_turf
	var/right_dir
	var/left_dir
	switch(dir_to_use)
		if(NORTH)
			left_dir = WEST
			right_dir = EAST
		if(SOUTH)
			left_dir = EAST
			right_dir = WEST
		if(EAST)
			left_dir = NORTH
			right_dir = SOUTH
		if(WEST)
			left_dir = SOUTH
			right_dir = NORTH


	for(var/i in 1 to cone_levels)
		var/list/level_turfs = list()
		turf_to_use = get_step(turf_to_use, dir_to_use)
		level_turfs += turf_to_use
		if(i != 1)
			left_turf = get_step(turf_to_use, left_dir)
			level_turfs += left_turf
			right_turf = get_step(turf_to_use, right_dir)
			level_turfs += left_turf
			for(var/left_i in 1 to i -calculate_end_taper(i))
				if(left_turf.density && respect_density)
					break
				left_turf = get_step(left_turf, left_dir)
				level_turfs += left_turf
			for(var/right_i in 1 to i -calculate_end_taper(i))
				if(right_turf.density && respect_density)
					break
				right_turf = get_step(right_turf, right_dir)
				level_turfs += right_turf
		turfs_to_return += list(level_turfs)
		if(i == cone_levels)
			continue
		if(turf_to_use.density && respect_density)
			break
	return turfs_to_return

/obj/effect/proc_holder/spell/cone/cast(list/targets,mob/user = usr)
	var/list/cone_turfs = cone_helper(get_turf(user), user.dir, cone_levels)
	for(var/list/turf_list in cone_turfs)
		do_cone_effects(turf_list)

/obj/effect/proc_holder/spell/cone/proc/do_cone_effects(list/target_turf_list)
	for(var/target_turf in target_turf_list)
		if(!target_turf) //if turf is no longer there
			continue
		do_turf_cone_effect(target_turf)
		if(isopenturf(target_turf))
			var/turf/open/open_turf = target_turf
			for(var/movable_content in open_turf)
				if(isobj(movable_content))
					do_obj_cone_effect(movable_content)
				else if(ismob(movable_content))
					do_mob_cone_effect(movable_content)


/obj/effect/proc_holder/spell/cone/proc/do_turf_cone_effect(turf/target_turf)
	return

/obj/effect/proc_holder/spell/cone/proc/do_obj_cone_effect(obj/target_obj)
	return

/obj/effect/proc_holder/spell/cone/proc/do_mob_cone_effect(mob/target_mob)
	return

/obj/effect/proc_holder/spell/cone/proc/calculate_end_taper(current_level)
	var/end_taper_start = round(cone_levels * 0.8)
	if(current_level > end_taper_start)
		return (current_level % end_taper_start) * 2
	else
		return 2

/obj/effect/proc_holder/spell/cone/staggered

/obj/effect/proc_holder/spell/cone/staggered/cast(list/targets,mob/user = usr)
	var/shitcode = 0 //remove dis
	var/list/cone_turfs = cone_helper(get_turf(user), user.dir, cone_levels)
	for(var/list/turf_list in cone_turfs)
		shitcode++
		addtimer(CALLBACK(src, .proc/do_cone_effects, turf_list), 2 * shitcode)
