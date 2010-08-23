// attach a wire to a power machine - leads from the turf you are standing on

/obj/machinery/power/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/weapon/cable_coil))

		var/obj/item/weapon/cable_coil/coil = W

		var/turf/T = user.loc

		if(T.intact || !istype(T, /turf/simulated/floor))
			return

		if(get_dist(src, user) > 1)
			return

		if(!directwired)		// only for attaching to directwired machines
			return

		var/dirn = get_dir(user, src)


		for(var/obj/cable/LC in T)
			if(LC.d1 == dirn || LC.d2 == dirn)
				user << "There's already a cable at that position."
				return

		var/obj/cable/NC = new(T)
		NC.d1 = 0
		NC.d2 = dirn
		NC.add_fingerprint()
		NC.updateicon()
		NC.update_network()
		coil.use(1)
		return
	else
		..()
	return


// the power cable object

/obj/cable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)


/obj/cable/Del()		// called when a cable is deleted

	if(!defer_powernet_rebuild)	// set if network will be rebuilt manually

		if(netnum && powernets && powernets.len >= netnum)		// make sure cable & powernet data is valid
			var/datum/powernet/PN = powernets[netnum]
			PN.cut_cable(src)									// updated the powernets
	else
		if(Debug) diary << "Defered cable deletion at [x],[y]: #[netnum]"
	..()													// then go ahead and delete the cable

/obj/cable/hide(var/i)

	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	updateicon()

/obj/cable/proc/updateicon()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"


// returns the powernet this cable belongs to
/obj/cable/proc/get_powernet()
	var/datum/powernet/PN			// find the powernet
	if(netnum && powernets && powernets.len >= netnum)
		PN = powernets[netnum]
	return PN

/obj/cable/attackby(obj/item/weapon/W, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return

	if(istype(W, /obj/item/weapon/wirecutters))

		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/weapon/cable_coil(T, 2)
		else
			new/obj/item/weapon/cable_coil(T, 1)

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [user] cuts the cable.", 1)

		shock(user, 50)

		defer_powernet_rebuild = 0		// to fix no-action bug
		del(src)

		return	// not needed, but for clarity


	else if(istype(W, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/coil = W

		coil.cable_join(src, user)
		//note do shock in cable_join

	else if(istype(W, /obj/item/device/multitool))

		var/datum/powernet/PN = get_powernet()		// find the powernet

		if(PN && (PN.avail > 0))		// is it powered?
			user << "\red [PN.avail]W in power network."

		else
			user << "\red The cable is not powered."

		if(prob(40))
			shock(user, 10)

	else
		shock(user, 10)

	src.add_fingerprint(user)

// shock the user with probability prb

/obj/cable/proc/shock(mob/user, prb)
	if(!netnum)		// unconnected cable is unpowered
		return 0

	return src.electrocute(user, prb, netnum)


/atom/proc/electrocute(mob/user, prb, netnum)

	if(!prob(prb))
		return 0

	if(!netnum)		// unconnected cable is unpowered
		return 0

	var/datum/powernet/PN
	if(powernets && powernets.len >= netnum)
		PN = powernets[netnum]

	if(PN && (PN.avail > 0))		// is it powered?
		var/prot = 1

		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves

				prot = G.siemens_coefficient
		else if (istype(user, /mob/living/silicon))
			return 0

		if(prot == 0)		// elec insulted gloves protect completely
			return 0

		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		var/shock_damage = 0
		if(PN.avail > 750000)	//someone juiced up the grid enough, people going to die!
			shock_damage = min(rand(70,145),rand(70,145))*prot
		else if(PN.avail > 100000)
			shock_damage = min(rand(35,110),rand(35,110))*prot
		else if(PN.avail > 75000)
			shock_damage = min(rand(30,100),rand(30,100))*prot
		else if(PN.avail > 50000)
			shock_damage = min(rand(25,90),rand(25,90))*prot
		else if(PN.avail > 25000)
			shock_damage = min(rand(20,80),rand(20,80))*prot
		else if(PN.avail > 10000)
			shock_damage = min(rand(20,65),rand(20,65))*prot
		else
			shock_damage = min(rand(20,45),rand(20,45))*prot

//		message_admins("\blue <B>ADMIN: </B>DEBUG: shock_damage = [shock_damage] PN.avail = [PN.avail] user = [user] netnum = [netnum]")

		user.burn_skin(shock_damage)
		user.fireloss += shock_damage
		user.updatehealth()
		user << "\red <B>You feel a powerful shock course through your body!</B>"
		sleep(1)

		if(user.stunned < shock_damage)	user.stunned = shock_damage
		if(user.weakened < 20*prot)	user.weakened = 20*prot
		for(var/mob/M in viewers(src))
			if(M == user)	continue
			M.show_message("\red [user.name] was shocked by the [src.name]!", 3, "\red You hear a heavy electrical crack", 2)
		return 1
	return 0


/obj/cable/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1)
				del(src)

		if(3.0)
			if (prob(25))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1)
				del(src)
	return

// the cable coil object, used for laying cable

/obj/item/weapon/cable_coil/New(loc, length = MAXCOIL)
	src.amount = length
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()
	..(loc)

/obj/item/weapon/cable_coil/cut/New(loc)
	..(loc)
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()

/obj/item/weapon/cable_coil/proc/updateicon()
	if(amount == 1)
		icon_state = "coil1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil2"
		name = "cable piece"
	else
		icon_state = "coil"
		name = "cable coil"

/obj/item/weapon/cable_coil/examine()
	set src in view(1)

	if(amount == 1)
		usr << "A short piece of power cable."
	else if(amount == 1)
		usr << "A piece of power cable."
	else
		usr << "A coil of power cable. There are [amount] lengths of cable in the coil."

/obj/item/weapon/cable_coil/attackby(obj/item/weapon/W, mob/user)
	if( istype(W, /obj/item/weapon/wirecutters) && src.amount > 1)
		src.amount--
		new/obj/item/weapon/cable_coil(user.loc, 1)
		user << "You cut a piece off the cable coil."
		src.updateicon()
		return

	else if( istype(W, /obj/item/weapon/cable_coil) )
		var/obj/item/weapon/cable_coil/C = W
		if(C.amount == MAXCOIL)
			user << "The coil is too long, you cannot add any more cable to it."
			return

		if( (C.amount + src.amount <= MAXCOIL) )
			C.amount += src.amount
			user << "You join the cable coils together."
			C.updateicon()
			del(src)
			return

		else
			user << "You transfer [MAXCOIL - src.amount ] length\s of cable from one coil to the other."
			src.amount -= (MAXCOIL-C.amount)
			src.updateicon()
			C.amount = MAXCOIL
			C.updateicon()
			return

/obj/item/weapon/cable_coil/proc/use(var/used)
	if(src.amount < used)
		return 0
	else if (src.amount == used)
		del(src)
	else
		amount -= used
		updateicon()
		return 1

// called when cable_coil is clicked on a turf/simulated/floor

/obj/item/weapon/cable_coil/proc/turf_place(turf/simulated/floor/F, mob/user)

	if(!isturf(user.loc))
		return

	if(get_dist(F,user) > 1)
		user << "You can't lay cable at a place that far away."
		return

	if(F.intact)		// if floor is intact, complain
		user << "You can't lay cable there unless the floor tiles are removed."
		return

	else
		var/dirn

		if(user.loc == F)
			dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(F, user)

		for(var/obj/cable/LC in F)
			if(LC.d1 == dirn || LC.d2 == dirn)
				user << "There's already a cable at that position."
				return

		var/obj/cable/C = new(F)
		C.d1 = 0
		C.d2 = dirn
		C.add_fingerprint(user)
		C.updateicon()
		C.update_network()
		use(1)
		//src.laying = 1
		//last = C


// called when cable_coil is click on an installed obj/cable

/obj/item/weapon/cable_coil/proc/cable_join(obj/cable/C, mob/user)


	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		user << "You can't lay cable at a place that far away."
		return


	if(U == T)		// do nothing if we clicked a cable we're standing on
		return		// may change later if can think of something logical to do

	var/dirn = get_dir(C, user)

	if(C.d1 == dirn || C.d2 == dirn)		// one end of the clicked cable is pointing towards us
		if(U.intact)						// can't place a cable if the floor is complete
			user << "You can't lay cable there unless the floor tiles are removed."
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn && LC.d2 == fdirn)
					user << "There's already a cable at that position."
					return

			var/obj/cable/NC = new(U)
			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()
			NC.update_network()
			use(1)
			C.shock(user, 25)

			return
	else if(C.d1 == 0)		// exisiting cable doesn't point at our position, so see if it's a stub
							// if so, make it a full cable pointing from it's old direction to our dirn

		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn

		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				user << "There's already a cable at that position."
				return
		C.shock(user, 25)
		del(C)
		var/obj/cable/NC = new(T)
		NC.d1 = nd1
		NC.d2 = nd2
		NC.add_fingerprint()
		NC.updateicon()
		NC.update_network()

		use(1)

		return


// called when a new cable is created
// can be 1 of 3 outcomes:
// 1. Isolated cable (or only connects to isolated machine) -> create new powernet
// 2. Joins to end or bridges loop of a single network (may also connect isolated machine) -> add to old network
// 3. Bridges gap between 2 networks -> merge the networks (must rebuild lists also)



/obj/cable/proc/update_network()
	// easy way: do /makepowernets again
	makepowernets()
	// do things more logically if this turns out to be too slow
	// may just do this for case 3 anyway (simpler than refreshing list)
