// Point controlling procs

/mob/camera/blob/proc/can_buy(var/cost = 15)
	if(blob_points < cost)
		src << "<span class='warning'>You cannot afford this.</span>"
		return 0
	add_points(-cost)
	return 1

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Blob"
	set name = "Jump to Core"
	set desc = "Transport back to your core."

	if(blob_core)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Transport back to a selected node."

	if(blob_nodes.len)
		var/list/nodes = list()
		for(var/i = 1; i <= blob_nodes.len; i++)
			nodes["Blob Node #[i]"] = blob_nodes[i]
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/effect/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			src.loc = chosen_node.loc

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create Shield Blob (10)"
	set desc = "Create a shield blob."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(var/turf/T)

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		src << "There is no blob here!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		src << "Unable to use this blob, find a normal one."
		return

	if(!can_buy(10))
		return


	B.change_to(/obj/effect/blob/shield)
	return



/mob/camera/blob/verb/create_resource()
	set category = "Blob"
	set name = "Create Resource Blob (40)"
	set desc = "Create a resource tower which will generate points for you."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		src << "There is no blob here!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		src << "Unable to use this blob, find a normal one."
		return

	for(var/obj/effect/blob/resource/blob in orange(4, T))
		src << "There is a resource blob nearby, move more than 4 tiles away from it!"
		return

	if(!can_buy(40))
		return


	B.change_to(/obj/effect/blob/resource)
	var/obj/effect/blob/resource/R = locate() in T
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
		src << "There is no blob here!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		src << "Unable to use this blob, find a normal one."
		return

	for(var/obj/effect/blob/node/blob in orange(5, T))
		src << "There is another node nearby, move more than 5 tiles away from it!"
		return

	if(!can_buy(60))
		return


	B.change_to(/obj/effect/blob/node)
	return


/mob/camera/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Factory Blob (60)"
	set desc = "Create a Spore producing blob."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		src << "You must be on a blob!"
		return

	if(!istype(B, /obj/effect/blob/normal))
		src << "Unable to use this blob, find a normal one."
		return

	for(var/obj/effect/blob/factory/blob in orange(7, T))
		src << "There is a factory blob nearby, move more than 7 tiles away from it!"
		return

	if(!can_buy(60))
		return

	B.change_to(/obj/effect/blob/factory)
	return


/mob/camera/blob/verb/relocate_core()
	set category = "Blob"
	set name = "Relocate Core (80)"
	set desc = "Relocates your core to the node you are on, your old core will be turned into a node."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/effect/blob/node/B = locate(/obj/effect/blob/node) in T
	if(!B)
		src << "You must be on a blob node!"
		return

	if(!can_buy(80))
		return

	// The old switcharoo.
	var/turf/old_turf = blob_core.loc
	blob_core.loc = T
	B.loc = old_turf
	return


/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Removes a blob."

	var/turf/T = get_turf(src)
	if(!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		src << "You must be on a blob!"
		return

	if(istype(B, /obj/effect/blob/core))
		src << "Unable to remove this blob."
		return

	B.Destroy()
	return


/mob/camera/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Expand/Attack Blob (5)"
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear we will attack it, which might clear it."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(var/turf/T)
	if(!T)
		return

	var/obj/effect/blob/B = locate() in T
	if(B)
		src << "There is a blob here!"
		return

	var/obj/effect/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		src << "There is no blob adjacent to you."
		return

	if(!can_buy(5))
		return
	OB.expand(T, 0)
	return


/mob/camera/blob/verb/rally_spores_power()
	set category = "Blob"
	set name = "Rally Spores (5)"
	set desc = "Rally the spores to move to your location."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(var/turf/T)

	if(!can_buy(5))
		return

	src << "You rally your spores."

	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blobspore/BS in living_mob_list)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return