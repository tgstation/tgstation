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

		for(var/obj/structure/cable/LC in T)
			if( (LC.d1 == dirn && LC.d2 == 0 ) || ( LC.d2 == dirn && LC.d1 == 0) )
				user << "There's already a cable at that position."
				return

		var/obj/structure/cable/NC = new(T)

		NC.cableColor(coil.color)

		NC.d1 = 0
		NC.d2 = dirn
		NC.add_fingerprint()
		NC.updateicon()

		NC.mergeConnectedNetworks(NC.d2)
		NC.mergeConnectedNetworksOnTurf()
		if(netnum == 0 && NC.netnum == 0)
			var/datum/powernet/PN = new()

			PN.number = powernets.len + 1
			powernets += PN
			NC.netnum = PN.number
			netnum = PN.number
			PN.cables += NC
			PN.nodes += src
			powernet = PN
		else if(netnum == 0)
			netnum = NC.netnum
			var/datum/powernet/PN = powernets[netnum]
			powernet = PN
			PN.nodes += src
		NC.mergeConnectedNetworksOnTurf()

		coil.use(1)
		if (NC.shock(user, 50))
			if (prob(50)) //fail
				new/obj/item/weapon/cable_coil(NC.loc, 1, NC.color)
				del(NC)
		return
	else
		..()
	return

// the power cable object

/obj/structure/cable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)


/obj/structure/cable/Del()		// called when a cable is deleted

	if(!defer_powernet_rebuild)	// set if network will be rebuilt manually

		if(netnum && powernets && powernets.len >= netnum)		// make sure cable & powernet data is valid
			var/datum/powernet/PN = powernets[netnum]
			PN.cut_cable(src)									// updated the powernets
	else
		if(Debug) diary << "Defered cable deletion at [x],[y]: #[netnum]"
	..()													// then go ahead and delete the cable

/obj/structure/cable/hide(var/i)

	if(level == 1 && istype(loc, /turf))
		invisibility = i ? 101 : 0
	updateicon()

/obj/structure/cable/proc/updateicon()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"


// returns the powernet this cable belongs to
/obj/structure/cable/proc/get_powernet()
	var/datum/powernet/PN			// find the powernet
	if(netnum && powernets && powernets.len >= netnum)
		PN = powernets[netnum]
	return PN

/obj/structure/cable/attack_hand(mob/user)
	if(ishuman(user))
		if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
			call(/obj/item/clothing/gloves/space_ninja/proc/drain)("WIRE",src,user:wear_suit)
	return

/obj/structure/cable/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return

	if(istype(W, /obj/item/weapon/wirecutters))

		if(power_switch)
			user << "\red This piece of cable is tied to a power switch. Flip the switch to remove it."
			return

		if (shock(user, 50))
			return

		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/weapon/cable_coil(T, 2, color)
		else
			new/obj/item/weapon/cable_coil(T, 1, color)

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [user] cuts the cable.", 1)

		if(defer_powernet_rebuild)
			if(netnum && powernets && powernets.len >= netnum)
				var/datum/powernet/PN = powernets[netnum]
				PN.cut_cable(src)
		del(src)

		return	// not needed, but for clarity


	else if(istype(W, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/coil = W
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/device/multitool))

		var/datum/powernet/PN = get_powernet()		// find the powernet

		if(PN && (PN.avail > 0))		// is it powered?
			user << "\red [PN.avail]W in power network."

		else
			user << "\red The cable is not powered."

		shock(user, 5, 0.2)

	else
		if (W.flags & CONDUCT)
			shock(user, 50, 0.7)

	src.add_fingerprint(user)

// shock the user with probability prb

/obj/structure/cable/proc/shock(mob/user, prb, var/siemens_coeff = 1.0)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernets[src.netnum], src, siemens_coeff))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0

/obj/structure/cable/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				del(src)

		if(3.0)
			if (prob(25))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				del(src)
	return

// the cable coil object, used for laying cable

/obj/item/weapon/cable_coil/New(loc, length = MAXCOIL, var/param_color = null)
	..()
	src.amount = length
	if (param_color)
		color = param_color
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()


/obj/item/weapon/cable_coil/cut/New(loc)
	..()
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	updateicon()

/obj/item/weapon/cable_coil/proc/updateicon()
	if (!color)
		color = pick("red", "yellow", "blue", "green", "pink")
	if(amount == 1)
		icon_state = "coil_[color]1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil_[color]2"
		name = "cable piece"
	else
		icon_state = "coil_[color]"
		name = "cable coil"

/obj/item/weapon/cable_coil/examine()
	set src in view(1)

	if(amount == 1)
		usr << "A short piece of power cable."
	else if(amount == 2)
		usr << "A piece of power cable."
	else
		usr << "A coil of power cable. There are [amount] lengths of cable in the coil."

/obj/item/weapon/cable_coil/verb/make_restraint()
	set name = "Make Cable Restraints"
	set category = "Object"
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat) return
	if(!istype(usr.loc,/turf)) return
	if(src.amount <= 14)
		usr << "\red You need at least 15 lengths to make restraints!"
		return
	var/obj/item/weapon/handcuffs/cable/B = new /obj/item/weapon/handcuffs/cable(usr.loc)
	usr << "\blue You wind some cable together to make some restraints."
	if(src.amount == 15)
		del(src)
	else
		src.amount -= 15
	B.layer = 20
	..()

/obj/item/weapon/cable_coil/attackby(obj/item/weapon/W, mob/user)
	..()
	if( istype(W, /obj/item/weapon/wirecutters) && src.amount > 1)
		src.amount--
		new/obj/item/weapon/cable_coil(user.loc, 1,color)
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
			user << "You transfer [MAXCOIL - C.amount ] length\s of cable from one coil to the other."
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

		for(var/obj/structure/cable/LC in F)
			if((LC.d1 == dirn && LC.d2 == 0 ) || ( LC.d2 == dirn && LC.d1 == 0))
				user << "There's already a cable at that position."
				return

		var/obj/structure/cable/C = new(F)

		C.cableColor(color)

		C.d1 = 0
		C.d2 = dirn
		C.add_fingerprint(user)
		C.updateicon()

		var/datum/powernet/PN = new()
		PN.number = powernets.len + 1
		powernets += PN
		C.netnum = PN.number
		PN.cables += C

		C.mergeConnectedNetworks(C.d2)
		C.mergeConnectedNetworksOnTurf()


		use(1)
		if (C.shock(user, 50))
			if (prob(50)) //fail
				new/obj/item/weapon/cable_coil(C.loc, 1, C.color)
				del(C)
		//src.laying = 1
		//last = C


// called when cable_coil is click on an installed obj/cable

/obj/item/weapon/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)

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

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					user << "There's already a cable at that position."
					return

			var/obj/structure/cable/NC = new(U)
			NC.cableColor(color)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()

			NC.netnum = C.netnum
			var/datum/powernet/PN = powernets[C.netnum]
			PN.cables += NC
			NC.mergeConnectedNetworks(NC.d2)
			NC.mergeConnectedNetworksOnTurf()
			use(1)
			if (NC.shock(user, 50))
				if (prob(50)) //fail
					new/obj/item/weapon/cable_coil(NC.loc, 1, NC.color)
					del(NC)

			return
	else if(C.d1 == 0)		// exisiting cable doesn't point at our position, so see if it's a stub
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
				user << "There's already a cable at that position."
				return


		C.cableColor(color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.updateicon()


		C.mergeConnectedNetworks(C.d1)
		C.mergeConnectedNetworks(C.d2)
		C.mergeConnectedNetworksOnTurf()

		use(1)
		if (C.shock(user, 50))
			if (prob(50)) //fail
				new/obj/item/weapon/cable_coil(C.loc, 2, C.color)
				del(C)

		return

/obj/structure/cable/proc/mergeConnectedNetworks(var/direction)
	var/turf/TB
	if((d1 == direction || d2 == direction) != 1)
		return
	TB = get_step(src, direction)

	for(var/obj/structure/cable/TC in TB)

		if(!TC)
			continue

		if(src == TC)
			continue

		var/fdir = (!direction)? 0 : turn(direction, 180)

		if(TC.d1 == fdir || TC.d2 == fdir)

			if(!netnum)
				var/datum/powernet/PN = powernets[TC.netnum]
				netnum = TC.netnum
				PN = powernets[netnum]
				PN.cables += src
				continue

			if(TC.netnum != netnum)
				var/datum/powernet/PN = powernets[netnum]
				var/datum/powernet/TPN = powernets[TC.netnum]

				PN.merge_powernets(TPN)

/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()


	for(var/obj/structure/cable/C in loc)


		if(!C)
			continue

		if(C == src)
			continue
		if(netnum == 0)
			var/datum/powernet/PN = powernets[C.netnum]
			netnum = C.netnum
			PN.cables += src
			continue

		var/datum/powernet/PN = powernets[netnum]
		var/datum/powernet/TPN = powernets[C.netnum]

		PN.merge_powernets(TPN)

	for(var/obj/machinery/power/M in loc)

		if(!M)
			continue

		if(!M.netnum)
			var/datum/powernet/PN = powernets[netnum]
			PN.nodes += M
			M.netnum = netnum
			M.powernet = powernets[M.netnum]

		if(M.netnum < 0)
			continue

		var/datum/powernet/PN = powernets[netnum]
		var/datum/powernet/TPN = powernets[M.netnum]

		PN.merge_powernets(TPN)

	for(var/obj/machinery/power/apc/N in loc)
		if(!N)	continue

		var/obj/machinery/power/M
		M = N.terminal
		if(!M)	continue

		if(!M.netnum)
			if(!netnum)continue
			var/datum/powernet/PN = powernets[netnum]
			PN.nodes += M
			M.netnum = netnum
			M.powernet = powernets[M.netnum]
			continue

		var/datum/powernet/PN = powernets[netnum]
		var/datum/powernet/TPN = powernets[M.netnum]

		PN.merge_powernets(TPN)

obj/structure/cable/proc/cableColor(var/colorC)
	var/color_n = "red"
	if(colorC)
		color_n = colorC
	color = color_n
	switch(colorC)
		if("red")
			icon = 'power_cond_red.dmi'
		if("yellow")
			icon = 'power_cond_yellow.dmi'
		if("green")
			icon = 'power_cond_green.dmi'
		if("blue")
			icon = 'power_cond_blue.dmi'
