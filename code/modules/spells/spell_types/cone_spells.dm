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
	cooldown_min = 5
	var/cone_levels = 3

/obj/effect/proc_holder/spell/cone/choose_targets(mob/user = usr)
	perform(null, user=user)

/obj/effect/proc_holder/spell/cone/proc/cone_helper(var/turf/starter_turf, var/dir_to_use, var/cone_levels = 3)
	var/list/turfs_to_return = list(starter_turf)
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
	left_turf = get_step(turf_to_use, left_dir)
	right_turf = get_step(turf_to_use, right_dir)
	turfs_to_return += left_turf
	turfs_to_return += right_turf
	turf_to_use = get_step(starter_turf, dir_to_use)
	turfs_to_return += turf_to_use

	for(var/i in 1 to cone_levels)
		left_turf = get_step(turf_to_use, left_dir)
		right_turf = get_step(turf_to_use, right_dir)
		turfs_to_return += left_turf
		turfs_to_return += right_turf
		for(var/left_i in 1 to i)
			left_turf = get_step(left_turf, left_dir)
			turfs_to_return += left_turf
		for(var/right_i in 1 to i)
			right_turf = get_step(right_turf, right_dir)
			turfs_to_return += right_turf
		if(i == cone_levels)
			continue
		turf_to_use = get_step(turf_to_use, dir_to_use)
		turfs_to_return += turf_to_use
	return turfs_to_return

/obj/effect/proc_holder/spell/cone/cast(list/targets,mob/user = usr)
	var/list/cone_turfs = cone_helper(get_step(user, user.dir), user.dir, cone_levels)
	for(var/T in cone_turfs)
		do_turf_cone_effect(T)
		if(isopenturf(T))
			var/turf/open/O = T
			for(var/A in O)
				if(isobj(A))
					do_obj_cone_effect(A)
				if(ismob(A))
					do_mob_cone_effect(A)

/obj/effect/proc_holder/spell/cone/proc/do_turf_cone_effect(var/turf/T)

/obj/effect/proc_holder/spell/cone/proc/do_obj_cone_effect(var/obj/O)

/obj/effect/proc_holder/spell/cone/proc/do_mob_cone_effect(var/mob/M)