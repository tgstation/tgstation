// Point controlling procs

/mob/camera/blob/proc/can_buy(var/cost = 15)
	if(blob_points < cost)
		src << "<span class='warning'>You cannot afford this.</span>"
		return 0
	blob_points -= cost
	return 1

/mob/camera/blob/proc/add_points(var/points = 0)
	if(points)
		blob_points = min(max_blob_points, blob_points + points)

// Power verbs

/mob/camera/blob/verb/transport()
	set category = "Blob"
	set name = "Return to Core"
	set desc = "Transport back to your core."

	if(blob_core)
		src.loc = blob_core.loc


/mob/camera/blob/verb/create_shield()
	set category = "Blob"
	set name = "Create Shield Blob (10)"
	set desc = "Create a shield blob."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		usr << "There is no blob here!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		usr << "Unable to use this blob, find a normal one."
		return

	if(!can_buy(10))
		return


	B.change_to(/obj/effect/blob/shield)
	return


/mob/camera/blob/verb/create_resource()
	set category = "Blob"
	set name = "Create Resource Blob (30)"
	set desc = "Create a resource tower which will generate points for you."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		usr << "There is no blob here!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		usr << "Unable to use this blob, find a normal one."
		return

	for(var/obj/effect/blob/resource/blob in orange(3))
		usr << "There is a resource blob nearby, move more than 3 tiles away from it!"
		return

	if(!can_buy(30))
		return


	B.change_to(/obj/effect/blob/resource)
	var/obj/effect/blob/resource/R = locate(/obj/effect/blob/resource)
	if(R)
		R.overmind = src

	return

/mob/camera/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node Blob (60)"
	set desc = "Create a Node."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		usr << "There is no blob here!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		usr << "Unable to use this blob, find a normal one."
		return

	for(var/obj/effect/blob/node/blob in orange(4))
		usr << "There is another node nearby, move more than 4 tiles away from it!"
		return

	if(!can_buy(60))
		return


	B.change_to(/obj/effect/blob/node)
	return


/mob/camera/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Factory Blob (70)"
	set desc = "Create a Spore producing blob."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		usr << "You must be on a blob!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		usr << "Unable to use this blob, find a normal one."
		return

	for(var/obj/effect/blob/factory/blob in orange(4))
		usr << "There is a factory blob nearby, move more than 4 tiles away from it!"
		return

	if(!can_buy(70))
		return

	B.change_to(/obj/effect/blob/factory)
	return


/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob (0)"
	set desc = "Removes a blob."
	if(creating_blob)	return

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		usr << "You must be on a blob!"
		return

	if(istype(B, /obj/effect/blob/core))
		usr << "Unable to use this blob, find another one."
		return

	B.change_to(/obj/effect/blob)
	return


/mob/camera/blob/verb/spawn_blob()
	set category = "Blob"
	set name = "Expand Blob (10)"
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear we will attack it, which might clear it."
	if(creating_blob)	return
	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = locate() in T
	if(B)
		usr << "There is a blob here!"
		return

	var/obj/effect/blob/OB = locate() in circlerange(src, 1)
	if(!OB)
		usr << "There is no blob adjacent to you."
		return

	if(!can_buy(10))
		return
	OB.expand(T, 0)
	return


/mob/camera/blob/verb/rally_spores()
	set category = "Blob"
	set name = "Rally Spores (5)"
	set desc = "Rally the spores to move to your location."
	if(creating_blob)	return

	if(!can_buy(5))
		return

	var/list/surrounding_turfs = block(locate(x - 1, y - 1, z), locate(x + 1, y + 1, z))
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blobspore/BS in living_mob_list)
		if(isturf(BS.loc) && get_dist(BS, src) <= 16)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return