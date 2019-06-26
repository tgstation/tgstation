/*
All the important duct code:
/code/datums/components/plumbing/plumbing.dm
/code/datums/ductnet.dm
*/
/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "nduct"

	var/connects = NORTH | SOUTH
	var/datum/ductnet/duct
	var/capacity = 10

	var/active = TRUE //wheter to even bother with plumbing code or not

/obj/machinery/duct/bent
	icon_state = "nduct_bent"
	connects = NORTH | EAST

/obj/machinery/duct/joined
	icon_state = "nduct_joined"
	connects = NORTH | WEST | SOUTH

/obj/machinery/duct/cross
	icon_state = "nduct_crossed"
	connects = NORTH | SOUTH | EAST | WEST

/obj/machinery/duct/Initialize(mapload, no_anchor, spin=SOUTH)
	. = ..()

	setDir(spin)
	if(no_anchor)
		active = FALSE
		anchored = FALSE
	else if(!can_anchor())
		CRASH("Overlapping ducts detected")
		qdel(src)
	if(active)
		attempt_connect()

/obj/machinery/duct/ComponentInitialize()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE)

/obj/machinery/duct/proc/update_dir()
	//Note that the use of the SOUTH define as default is because it's the initial direction of the ducts and it's connects
	var/new_connects
	var/angle = 180 - dir2angle(dir)
	if(dir == SOUTH)
		connects = initial(connects)
	else
		for(var/D in GLOB.cardinals)
			if(D & initial(connects))
				new_connects += turn(D, angle)
		connects = new_connects

/obj/machinery/duct/proc/attempt_connect()
	update_dir()
	for(var/D in GLOB.cardinals)
		if(D & connects)
			for(var/atom/movable/AM in get_step(src, D))
				connect_network(AM, D)

/obj/machinery/duct/proc/connect_network(atom/movable/AM, direction)
	var/opposite_dir = turn(direction, 180)
	if(istype(AM, /obj/machinery/duct))
		var/obj/machinery/duct/D = AM
		if(!D.active || ((duct == D.duct) && duct)) //check if we're not just comparing two null values
			return
		if(opposite_dir & D.connects)
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