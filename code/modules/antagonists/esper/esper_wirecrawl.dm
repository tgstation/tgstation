/mob/living/esper/proc/add_wirecrawl(var/obj/structure/cable/starter)
	var/list/totalMembers = list()

	if(!istype(starter.powernet) || !LAZYLEN(starter.powernet.cables))
		return FALSE

	for(var/A in starter.powernet.cables)
		var/obj/structure/cable/C = A
		if(istype(C))
			totalMembers |= C

	if(!totalMembers.len)
		return

	if(client)
		for(var/X in totalMembers)
			var/obj/structure/cable/A = X //all elements in totalMembers are necessarily of this type.
			if(in_view_range(client.mob, A))
				if(!A.cable_vision_img)
					A.cable_vision_img = image(A, A.loc, layer = ABOVE_HUD_LAYER, dir = A.dir)
					A.cable_vision_img.plane = ABOVE_HUD_PLANE
				client.images |= A.cable_vision_img
				cables_shown |= A.cable_vision_img
	setMovetype(movement_type | WIRECRAWLING)

/mob/living/esper/proc/remove_wirecrawl()
	if(client)
		for(var/image/current_image in cables_shown)
			client.images -= current_image
	LAZYCLEARLIST(cables_shown)
	setMovetype(movement_type & ~WIRECRAWLING)

/mob/living/esper/proc/update_wire_vision(atom/new_loc = null)
	. = loc
	if(new_loc)
		. = new_loc
	remove_wirecrawl()
	add_wirecrawl(.)