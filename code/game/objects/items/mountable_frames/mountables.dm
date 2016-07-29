/obj/item/mounted
	var/list/buildon_types = list(/turf/simulated/wall, /turf/simulated/shuttle/wall)


/obj/item/mounted/afterattack(var/atom/A, mob/user, proximity_flag)
	var/found_type = 0
	for(var/turf_type in src.buildon_types)
		if(istype(A, turf_type))
			found_type = 1
			break

	if(found_type)
		if(try_build(A, user, proximity_flag))
			return do_build(A, user)
	else
		..()

/obj/item/mounted/proc/try_build(turf/on_wall, mob/user, proximity_flag) //checks
	if(!on_wall || !user)
		return
	if (proximity_flag != 1) //if we aren't next to the wall
		return
	if (!( get_dir(user,on_wall) in cardinal))
		to_chat(user, "<span class='rose'>You need to be standing next to a wall to place \the [src].</span>")
		return

	if(gotwallitem(get_turf(user), get_dir(user,on_wall)))
		to_chat(user, "<span class='rose'>There's already an item on this wall!</span>")
		return

	return 1

/obj/item/mounted/proc/do_build(turf/on_wall, mob/user) //the buildy bit after we pass the checks
	return
