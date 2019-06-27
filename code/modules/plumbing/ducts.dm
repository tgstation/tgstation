/*
All the important duct code:
/code/datums/components/plumbing/plumbing.dm
/code/datums/ductnet.dm
*/
/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "nduct"

	var/connects
	var/datum/ductnet/duct
	var/capacity = 10

	var/duct_color = null
	var/duct_layer = DUCT_LAYER_DEFAULT //1,2,3,4,5

	var/active = TRUE //wheter to even bother with plumbing code or not

/obj/machinery/duct/Initialize(mapload, no_anchor, color_of_duct, layer_of_duct)
	. = ..()

	duct_color = color_of_duct
	duct_layer = layer_of_duct
	if(no_anchor)
		active = FALSE
		anchored = FALSE
	else if(!can_anchor())
		CRASH("Overlapping ducts detected")
		qdel(src)
	if(duct_color)
		add_atom_colour(duct_color, FIXED_COLOUR_PRIORITY)
	if(duct_layer)
		handle_layer()
	for(var/obj/machinery/duct/D in loc)
		if(D == src)
			continue
		if(is_compatible(D))
			qdel(src) //replace with dropping or something
	if(active)
		attempt_connect()

/obj/machinery/duct/proc/attempt_connect()
	for(var/D in GLOB.cardinals)
		for(var/atom/movable/AM in get_step(src, D))
			if(connect_network(AM, D))
				connects |= D
	update_icon()

/obj/machinery/duct/proc/connect_network(atom/movable/AM, direction)
	var/opposite_dir = turn(direction, 180)
	if(istype(AM, /obj/machinery/duct))
		var/obj/machinery/duct/D = AM
		if(!active || !D.active)
			return
		if((duct == D.duct) && duct)//check if we're not just comparing two null values
			D.connects |= opposite_dir
			D.update_icon() //also update the older pipes icon
			return TRUE //tell the current pipe to also update it's sprite

		if(!is_compatible(D))
			return

		if(D.duct)
			if(duct)
				duct.assimilate(D.duct)
			else
				D.duct.add_duct(src)
		else
			if(duct)
				duct.add_duct(D)
			else
				create_duct()
				duct.add_duct(D)
		D.attempt_connect()//tell our buddy its time to pass on the torch of connecting to pipes. This shouldn't ever infinitely loop since it only works on pipes that havent been inductrinated
		return TRUE

	if(layer != 3) //plumbing devices don't support multilayering. 3 is the default layer so we only use that. We can change this later
		return
	var/datum/component/plumbing/P = AM.GetComponent(/datum/component/plumbing)
	if(!P)
		return

	var/comp_directions = P.supply_connects + P.demand_connects //they should never, ever have supply and demand connects overlap or catastrophic failure
	if(opposite_dir & comp_directions)
		if(duct)
			duct.add_plumber(P, opposite_dir)
		else
			create_duct()
			duct.add_plumber(P, opposite_dir)
		return TRUE

/obj/machinery/duct/proc/is_compatible(obj/machinery/duct/D)
	return (duct_layer == D.duct_layer) && (duct_color == D.duct_color)

/obj/machinery/duct/proc/disconnect_duct() //when calling this, make sure something happened to the duct or it'll just reconnect
	if(!duct)
		return
	duct.remove_duct(src)

/obj/machinery/duct/proc/create_duct()
	duct = new()
	duct.add_duct(src)

/obj/machinery/duct/proc/get_adjacent_ducts()
	var/list/adjacents = list()
	for(var/A in GLOB.cardinals)
		if(A & connects)
			for(var/obj/machinery/duct/D in get_step(src, A))
				if((turn(A, 180) & D.connects) && D.active)
					adjacents += D
	return adjacents

/obj/machinery/duct/update_icon()
	var/temp_icon = initial(icon_state)
	for(var/D in GLOB.cardinals)
		if(D & connects)
			if(D == NORTH)
				temp_icon += "_n"
			if(D == SOUTH)
				temp_icon += "_s"
			if(D == EAST)
				temp_icon += "_e"
			if(D == WEST)
				temp_icon += "_w"
	icon_state = temp_icon

/obj/machinery/duct/proc/handle_layer()
	var/offset
	switch(duct_layer)
		if(1)
			offset = -10
		if(2)
			offset = -5
		if(3)
			offset = 0
		if(4)
			offset = 5
		if(5)
			offset = 10
	pixel_x = offset
	pixel_y = offset


/obj/machinery/duct/wrench_act(mob/living/user, obj/item/I) //I can also be the RPD
	add_fingerprint(user)
	I.play_tool_sound(src)
	if(anchored)
		anchored = FALSE
		active = FALSE
		user.visible_message( \
		"[user] unfastens \the [src].", \
		"<span class='notice'>You unfasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")
		disconnect_duct()
	else if(can_anchor())
		anchored = TRUE
		active = TRUE
		user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")
		attempt_connect()
	return TRUE

/obj/machinery/duct/proc/can_anchor(turf/T)
	if(!T)
		T = get_turf(src)
	for(var/obj/machinery/duct/D in T)
		if(!anchored)
			continue
		for(var/A in GLOB.cardinals)
			if(A & connects && A & D.connects)
				return FALSE
	return TRUE

/obj/machinery/duct/doMove(destination)
	. = ..()
	disconnect_duct()
	anchored = FALSE

/obj/machinery/duct/Destroy()
	disconnect_duct()
	return ..()