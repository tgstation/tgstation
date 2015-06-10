#define RCLMAX 30

/obj/item/weapon/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcl-0"
	item_state = "rcl-0"
	opacity = 0
	flags = FPRINT
	siemens_coefficient = 1 //Not quite as conductive as working with cables themselves
	force = 5.0 //Plastic is soft
	throwforce = 5.0
	throw_speed = 1
	throw_range = 10
	w_class = 3.0
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = "engineering=2;materials=4"
	//var/active = 0 Depreciated; Leaving it because it is a useful framework tool if you want to make it automagically place on movement
	var/obj/structure/cable/last = null
	var/cables = 0

/obj/item/weapon/rcl/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		var/calc = min(RCLMAX - cables,C.amount)
		cables += calc
		update_icon()
		C.use(calc)
		user << "<span class='notice'>You add the cables to the RCL. It now contains [cables].</span>"
	else
		..()

/obj/item/weapon/rcl/examine(mob/user)
	..()
	user << "<span class='info'>It contains [cables]/30 cables.</span>"

/obj/item/weapon/rcl/update_icon()
	switch(cables)
		if(21 to INFINITY)
			icon_state = "rcl-30"
			item_state = "rcl"
		if(11 to 20)
			icon_state = "rcl-20"
			item_state = "rcl"
		if(1 to 10)
			icon_state = "rcl-10"
			item_state = "rcl"
		else
			icon_state = "rcl-0"
			item_state = "rcl-0"

/obj/item/weapon/rcl/proc/use(mob/user)
	cables--
	if(!cables)
		//active = 0
		user << "<span class='notice'>The last of the cables unreel from the RCL.</span>"
	update_icon()

/obj/item/weapon/rcl/proc/turf_place(turf/simulated/floor/F, mob/user) //Stolen mostly from cable_coil, altered for my use
	if(!isturf(user.loc))
		return

	if(!cables)
		user << "<span class='warning'>The RCL is empty!</span>"
		return

	if(!user.Adjacent(F))		//too far
		user << "<span class='warning'>You can't lay cable at a place that far away.</span>"
		return

	if(F.intact)					// if floor is intact, complain
		user << "<span class='warning'>You can't lay cable there unless the floor tiles are removed.</span>"
		return

	var/dirn
	//active = !active //This should start and end the process of dropping cables. -- Depreciated, see note at top
	if(user.loc != F)
		dirn = get_dir(F, user)
		handle_cable_placement(F,dirn,user)
	dirn = user.dir
	handle_cable_placement(F,dirn,user)

/obj/item/weapon/rcl/proc/handle_cable_placement(turf/simulated/floor/F, var/dirn, mob/user)
	if(!cables)
		user << "<span class='warning'>The RCL is empty!</span>"
		//active = 0
		return
	for(var/obj/structure/cable/LC in F)
		if(LC.d2 == dirn && LC.d1 == 0)
			user << "There's already a cable at that position."
			return
	if(F.intact)	// can't place a cable if the floor is complete
		user << "You can't lay cable there unless the floor tile is removed."
		return
	var/obj/structure/cable/C = getFromPool(/obj/structure/cable, F)
	C.cableColor(_color)

	// set up the new cable
	C.d1 = 0 // it's a O-X node cable
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon()

	//create a new powernet with the cable, if needed it will be merged later
	var/datum/powernet/PN = getFromDPool(/datum/powernet)
	PN.add_cable(C)

	C.mergeConnectedNetworks(C.d2)		// merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf()	// merge the powernet with on turf powernets

	if(C.d2 & (C.d2 - 1)) // if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)
	use(1)
	last = C

/obj/item/weapon/rcl/proc/cable_join(obj/structure/cable/C, mob/user)
	var/turf/U = user.loc

	if(!isturf(U))
		return
	var/turf/T = C.loc
	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(!cables)
		user << "<span class='warning'>The RCL is empty!</span>"
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		user << "You can't lay cable at a place that far away."
		return
	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		turf_place(T,user)
		return

	var/dirn = get_dir(C, user)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(U.intact)						// can't place a cable if the floor is complete
			user << "You can't lay cable there unless the floor tile is removed."
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile
			handle_cable_placement(T, turn(dirn,180),user)
			return

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
		// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2		// these will be the new directions
		var/nd2 = dirn

		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2

		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)								// skip the cable we're interacting with
				continue

			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				user << "There's already a cable at that position."
				return

		C.cableColor(_color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.update_icon()

		C.mergeConnectedNetworks(C.d1) // merge the powernets...
		C.mergeConnectedNetworks(C.d2) // ...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1)) // if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1)) // if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		use(1)
		C.denode() // this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.

/*/obj/item/weapon/rcl/dropped(mob/wearer as mob)
	..()
	active = 0*/

/obj/item/weapon/rcl/attack_self(mob/user as mob)
	if(!cables)
		user << "<span class='warning'>The RCL is empty!</span>"
		return
	if(last)
		if(get_dist(last, user) == 0) //hacky, but it works
			last = null
		else if(get_dist(last, user) == 1)
			cable_join(last,user)
		else
			last = null
	handle_cable_placement(get_turf(src.loc),turn(user.dir,180),user)
