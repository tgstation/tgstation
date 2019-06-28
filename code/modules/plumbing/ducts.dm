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
	var/duct_layer = DUCT_LAYER_DEFAULT //0,1,2,4,8

	var/active = TRUE //wheter to even bother with plumbing code or not
	var/list/neighbours = list() //track ducts we're connected to. Mainly for ducts we connect to that we normally wouldn't, like different layers and colors, for when we regenerate the ducts

/obj/machinery/duct/Initialize(mapload, no_anchor, color_of_duct, layer_of_duct = DUCT_LAYER_DEFAULT)
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
	handle_layer()
	for(var/obj/machinery/duct/D in loc)
		if(D == src)
			continue
		if(D.duct_layer & duct_layer)
			qdel(src) //replace with dropping or something
	if(active)
		attempt_connect()

/obj/machinery/duct/proc/attempt_connect()
	connects = 0 //All connects are gathered here again eitherway, we might aswell reset it so they properly update when reconnecting
	for(var/D in GLOB.cardinals)
		for(var/atom/movable/AM in get_step(src, D))
			if(connect_network(AM, D))
				connects |= D
				break //we found this directions duct/plumber so there's really no point in continueing
	update_icon()

/obj/machinery/duct/proc/connect_network(atom/movable/AM, direction, ignore_color)
	var/opposite_dir = turn(direction, 180)
	if(istype(AM, /obj/machinery/duct))
		var/obj/machinery/duct/D = AM

		if(!active || !D.active)
			return

		if((duct == D.duct) && duct)//check if we're not just comparing two null values

			add_neighbour(D)

			D.connects |= opposite_dir
			D.update_icon()
			return TRUE //tell the current pipe to also update it's sprite
		if(!(D in neighbours)) //we cool
			if(duct_color != D.duct_color && !ignore_color)
				return

			if(!(duct_layer & D.duct_layer))
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
		add_neighbour(D)
		D.attempt_connect()//tell our buddy its time to pass on the torch of connecting to pipes. This shouldn't ever infinitely loop since it only works on pipes that havent been inductrinated
		return TRUE

	if(duct_layer != 3) //plumbing devices don't support multilayering. 3 is the default layer so we only use that. We can change this later
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

/obj/machinery/duct/proc/disconnect_duct()
	if(duct)
		duct.remove_duct()
	anchored = FALSE
	active = FALSE
	lose_neighbours()
	connects = 0
	update_icon()

/obj/machinery/duct/proc/create_duct()
	duct = new()
	duct.add_duct(src)

/obj/machinery/duct/proc/add_neighbour(obj/machinery/duct/D)
	if(!(D in neighbours))
		neighbours += D
	if(!(src in D.neighbours))
		D.neighbours += src

/obj/machinery/duct/proc/lose_neighbours()
	for(var/A in neighbours)
		var/obj/machinery/duct/D = A
		D.neighbours.Remove(src)
	neighbours = list()

/obj/machinery/duct/proc/get_adjacent_ducts()
	var/list/adjacents = list()
	for(var/A in GLOB.cardinals)
		if(A & connects)
			for(var/obj/machinery/duct/D in get_step(src, A))
				if((turn(A, 180) & D.connects) && D.active)
					adjacents += D
	return adjacents

/obj/machinery/duct/update_icon() //setting connects isnt a parameter because sometimes we make more than one change, overwrite it completely or just add it to the bitfield
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
		if(FIRST_DUCT_LAYER)
			offset = -10
		if(SECOND_DUCT_LAYER)
			offset = -5
		if(THIRD_DUCT_LAYER)
			offset = 0
		if(FOURTH_DUCT_LAYER)
			offset = 5
		if(FIFTH_DUCT_LAYER)
			offset = 10
	pixel_x = offset
	pixel_y = offset


/obj/machinery/duct/wrench_act(mob/living/user, obj/item/I) //I can also be the RPD
	add_fingerprint(user)
	I.play_tool_sound(src)
	if(anchored)
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

/obj/machinery/duct/MouseDrop_T(atom/A, mob/living/user)
	if(!istype(A, /obj/machinery/duct))
		return
	var/obj/machinery/duct/D = A
	var/obj/item/I = user.get_active_held_item()
	if(I?.tool_behaviour != TOOL_WRENCH)
		to_chat(user, "<span class='warning'>You need to be holding a wrench in your active hand to do that!</span>")
		return
	if(get_dist(src, D) != 1)
		return
	var/direction = get_dir(src, D)
	if(!(direction in GLOB.cardinals))
		return
	connect_network(D, direction, TRUE)
	connects |= direction
	update_icon()

/obj/machinery/duct/multilayered
	name = "duct layer manifold"
	duct_layer = FIRST_DUCT_LAYER + SECOND_DUCT_LAYER + THIRD_DUCT_LAYER + FOURTH_DUCT_LAYER + FIFTH_DUCT_LAYER

