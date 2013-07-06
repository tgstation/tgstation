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
	set name = "Create Resource Blob (50)"
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

	for(var/obj/effect/blob/resource/blob in orange(2))
		usr << "There is a resource blob nearby, move more than 2 tiles away from it!"
		return

	if(!can_buy(50))
		return


	B.change_to(/obj/effect/blob/resource)
	var/obj/effect/blob/resource/R = locate(/obj/effect/blob/resource)
	if(R)
		R.overmind = src

	return

/mob/camera/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node Blob (80)"
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

	for(var/obj/effect/blob/node/blob in orange(5))
		usr << "There is another node nearby, move more than 5 tiles  away from it!"
		return

	for(var/obj/effect/blob/factory/blob in orange(2))
		usr << "There is a factory blob nearby, move more than 2 tiles away from it!"
		return

	if(!can_buy(80))
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

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
	if(!B)
		usr << "You must be on a blob!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		usr << "Unable to use this blob, find a normal one."
		return

	for(var/obj/effect/blob/blob in orange(2))//Not right next to nodes/cores

		if(istype(B,/obj/effect/blob/node))
			usr << "There is a node nearby, move away from it!"
			return

		if(istype(B,/obj/effect/blob/core))
			usr << "There is a core nearby, move away from it!"
			return

		if(istype(B,/obj/effect/blob/factory))
			usr << "There is another factory blob nearby, move away from it!"
			return

	if(!can_buy(70))
		return

	B.change_to(/obj/effect/blob/factory)
	return


/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob (0)"
	set desc = "Removes a porous blob."
	if(creating_blob)	return

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
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
	set desc = "Attempts to create a new blob in this tile."
	if(creating_blob)	return
	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
	if(B)
		usr << "There is a blob here!"
		return
	if(!can_buy(10))
		return
	new /obj/effect/blob/normal(src.loc)
	return