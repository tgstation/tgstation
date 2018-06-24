/proc/place_power_cable_node(turf/T, dirnew, color)
	if(!dirnew)
		return
	var/obj/structure/cable/C = new(T, color, 0, dirnew, TRUE)
	if(!QDELETED(C))
		return C

/proc/place_power_cable_joining(obj/structure/cable/C, turf/S, defdir)
	var/turf/T = C.loc

	if(S == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		return place_power_cable_node(T, defdir)

	var/dirn = get_dir(T, S)

	// one end of the target cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		return place_power_cable_node(S, get_dir(S, T))

	// exisiting cable doesn't point at source, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn

		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2

		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				return

		C.d1 = nd1
		C.d2 = nd2

		C.update_icon()

		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
