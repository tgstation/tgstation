/obj/item/mounted
	var/list/buildon_types = list(/turf/simulated/wall)


/obj/item/mounted/afterattack(var/atom/A, mob/user)
	var/found_type = 0
	for(var/turf_type in src.buildon_types)
		if(istype(A, turf_type))
			found_type = 1
			break

	if(found_type)
		if(try_build(A, user))
			return do_build(A, user)
	else
		..()

/obj/item/mounted/proc/try_build(turf/on_wall, mob/user) //checks
	if(!on_wall || !user)
		return
	if (get_dist(on_wall, get_turf(src)) > 1)
		return
	if (!( get_dir(user,on_wall) in cardinal))
		user << "You need to be standing next to a wall to place \the [src]"
		return

	if(gotwallitem(get_turf(user), get_dir(user,on_wall)))
		user << "\red There's already an item on this wall!"
		return

	return 1

/obj/item/mounted/proc/do_build(turf/on_wall, mob/user) //the buildy bit after we pass the checks
	return
