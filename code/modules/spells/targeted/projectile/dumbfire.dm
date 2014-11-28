/atom/movable/spell/targeted/projectile/dumbfire
	name = "dumbfire spell"

/atom/movable/spell/targeted/projectile/dumbfire/choose_targets(mob/user = usr)

	var/list/targets = new

	var/starting_dir = user.dir //where are we facing at the time of casting?
	var/turf/starting_turf = get_turf(user)
	var/current_loc = starting_turf.loc
	for(var/i = 1; i <= src.range; i++)
		current_loc = get_step(current_loc, starting_dir)

	targets += get_turf(current_loc)

	return targets