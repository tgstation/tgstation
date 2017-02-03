///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/cable
	level = 1 //is underfloor
	anchored =1
	on_blueprints = TRUE
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/power_cond_red.dmi'
	icon_state = "0-1"
	var/d1 = 0   // cable direction 1 (see above)
	var/d2 = 1   // cable direction 2 (see above)
	layer = WIRE_LAYER //Above pipes, which are at GAS_PIPE_LAYER
	var/cable_color = "red"
	var/obj/item/stack/cable_coil/stored

/obj/structure/cable/yellow
	cable_color = "yellow"
	icon = 'icons/obj/power_cond/power_cond_yellow.dmi'

/obj/structure/cable/green
	cable_color = "green"
	icon = 'icons/obj/power_cond/power_cond_green.dmi'

/obj/structure/cable/blue
	cable_color = "blue"
	icon = 'icons/obj/power_cond/power_cond_blue.dmi'

/obj/structure/cable/pink
	cable_color = "pink"
	icon = 'icons/obj/power_cond/power_cond_pink.dmi'

/obj/structure/cable/orange
	cable_color = "orange"
	icon = 'icons/obj/power_cond/power_cond_orange.dmi'

/obj/structure/cable/cyan
	cable_color = "cyan"
	icon = 'icons/obj/power_cond/power_cond_cyan.dmi'

/obj/structure/cable/white
	cable_color = "white"
	icon = 'icons/obj/power_cond/power_cond_white.dmi'

// the power cable object
/obj/structure/cable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)
	cable_list += src //add it to the global cable list

	if(d1)
		stored = new/obj/item/stack/cable_coil(null,2,cable_color)
	else
		stored = new/obj/item/stack/cable_coil(null,1,cable_color)

/obj/structure/cable/Destroy()					// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	cable_list -= src							//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		var/turf/T = loc
		stored.forceMove(T)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

//If underfloor, hide the cable
/obj/structure/cable/hide(i)

	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	updateicon()

/obj/structure/cable/proc/updateicon()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"


// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	var/turf/T = src.loc
	if(T.intact)
		return
	if(istype(W, /obj/item/weapon/wirecutters))
		if (shock(user, 50))
			return
		user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
		stored.add_fingerprint(user)
		investigate_log("was cut by [key_name(usr, usr.client)] in [user.loc.loc]","wires")
		deconstruct()
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			user << "<span class='warning'>Not enough cable!</span>"
			return
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/device/multitool))
		if(powernet && (powernet.avail > 0))		// is it powered?
			user << "<span class='danger'>[powernet.avail]W in power network.</span>"
		else
			user << "<span class='danger'>The cable is not powered.</span>"
		shock(user, 5, 0.2)

	src.add_fingerprint(user)

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0

/obj/structure/cable/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/cableColor(colorC = "red")
	cable_color = colorC
	switch(colorC)
		if("red")
			icon = 'icons/obj/power_cond/power_cond_red.dmi'
		if("yellow")
			icon = 'icons/obj/power_cond/power_cond_yellow.dmi'
		if("green")
			icon = 'icons/obj/power_cond/power_cond_green.dmi'
		if("blue")
			icon = 'icons/obj/power_cond/power_cond_blue.dmi'
		if("pink")
			icon = 'icons/obj/power_cond/power_cond_pink.dmi'
		if("orange")
			icon = 'icons/obj/power_cond/power_cond_orange.dmi'
		if("cyan")
			icon = 'icons/obj/power_cond/power_cond_cyan.dmi'
		if("white")
			icon = 'icons/obj/power_cond/power_cond_white.dmi'

/obj/structure/cable/proc/update_stored(length = 1, colorC = "red")
	stored.amount = length
	stored.item_color = colorC
	stored.update_icon()

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return powernet.avail-powernet.load
	else
		return 0

/obj/structure/cable/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

//handles merging diagonally matching cables
//for info : direction^3 is flipping horizontally, direction^12 is flipping vertically
/obj/structure/cable/proc/mergeDiagonalsNetworks(direction)

	//search for and merge diagonally matching cables from the first direction component (north/south)
	var/turf/T  = get_step(src, direction&3)//go north/south

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == (direction^3) || C.d2 == (direction^3)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

	//the same from the second direction component (east/west)
	T  = get_step(src, direction&12)//go east/west

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue
		if(C.d1 == (direction^12) || C.d2 == (direction^12)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(istype(AM,/obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

		else if(istype(AM,/obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet)
				continue

			to_connect += N.terminal //we'll connect the machines after all cables are merged

		else if(istype(AM,/obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//if powernetless_only = 1, will only get connections without powernet
/obj/structure/cable/proc/get_connections(powernetless_only = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += power_list(T, src, turn(d1, 180), powernetless_only) //get adjacents matching cables

	if(d1&(d1-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d1&3) // go north/south
		if(T)
			. += power_list(T, src, d1 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d1&12) // go east/west
		if(T)
			. += power_list(T, src, d1 ^ 12, powernetless_only) //get diagonally matching cables

	. += power_list(loc, src, d1, powernetless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step(src, d2)
	if(T)
		. += power_list(T, src, turn(d2, 180), powernetless_only) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,d2&3) // go north/south
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step(src,d2&12) // go east/west
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only) //get diagonally matching cables
	. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1) return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(powerlist.len>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet()
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = power_list(T1, src, turn(d1,180),0,cable_only = 1)	// what adjacently joins on to cut cable...

	P_list += power_list(loc, src, d1, 0, cable_only = 1)//... and on turf


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	loc = null
	powernet.remove_cable(src) //remove the cut cable from its powernet

	spawn(0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables
		if(O && !qdeleted(O))
			var/datum/powernet/newPN = new()// creates a new powernet...
			propagate_network(O, newPN)//... and propagates it to the other side of the cable

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

var/global/list/datum/stack_recipe/cable_coil_recipes = list ( \
	new/datum/stack_recipe("cable restraints", /obj/item/weapon/restraints/handcuffs/cable, 15), \
	new/datum/stack_recipe("noose", /obj/structure/noose, 30, time = 100, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/cable_coil
	name = "cable coil"
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil_red"
	item_state = "coil_red"
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	item_color = "red"
	desc = "A coil of insulated power cable."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10, MAT_GLASS=5)
	flags = CONDUCT
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "cable piece"

/obj/item/stack/cable_coil/cyborg
	is_cyborg = 1
	materials = list()
	cost = 1

/obj/item/stack/cable_coil/cyborg/attack_self(mob/user)
	var/cable_color = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	item_color = cable_color
	update_icon()

/obj/item/stack/cable_coil/suicide_act(mob/living/user)
	if((locate(/obj/structure/stool) in user.loc) || (locate(/obj/structure/bed) in usr.loc) || (locate(/obj/structure/table) in user.loc) || (locate(/obj/structure/toilet) in user.loc))
		user.visible_message("<span class='suicide'>[user] is making a noose with the [src]! It looks like \he's trying to commit suicide.</span>")
		if(do_after(user, 20, target = user.loc))
			qdel(src)
			var/obj/structure/noose/N = new(get_turf(user.loc))
			N.buckle_mob(user)
			var/obj/item/organ/limb/affecting = null
			if(user.mob_has_gravity)
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					affecting = H.get_organ("head")
				user.say("--Hrnk!!")
				user.apply_damage(max(100 - user.getBruteLoss(), 0), BRUTE, affecting) //Pretty hardcore damage
				user.adjustOxyLoss(30)
				playsound(user.loc, 'sound/effects/noosed.ogg', 50, 1, -1)
				playsound(user.loc, 'sound/misc/crack.ogg', 50, 1, -3)
				user << "<span class='suicide'>With a loud crack in your neck, you feel your consciousness slipping away...</span>"
				return
		else
			return
	else
		user.visible_message("<span class='suicide'>[user] is strangling \himself with the [src]! It looks like \he's trying to commit suicide.</span>")
		return(OXYLOSS)

/obj/item/stack/cable_coil/New(loc, amount = MAXCOIL, var/param_color = null)
	..()
	src.amount = amount
	if(param_color)
		item_color = param_color
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	recipes = cable_coil_recipes
	
/obj/structure/noose //It's a "chair".
	name = "noose"
	desc = "Well this just got a whole lot more morbid."
	icon_state = "noose"
	buckle_lying = 0
	icon = 'icons/obj/objects.dmi'
	anchored = 1
	can_buckle = 1
	burn_state = 0 //Burnable
	burntime = 30
	layer = 5
	var/image/over = null
	var/ticks = 0

/obj/structure/noose/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wirecutters))
		user.visible_message("[user] cuts the noose.", "<span class='notice'>You cut the noose.</span>")
		if(buckled_mob && buckled_mob.mob_has_gravity)
			buckled_mob.visible_message("<span class='danger'>[buckled_mob] falls over and hits the ground!</span>",\
										"<span class='userdanger'>You fall over and hit the ground!</span>")
			buckled_mob.adjustBruteLoss(10)
		var/obj/item/stack/cable_coil/C = new(get_turf(src))
		C.amount = 25
		qdel(src)
		return
	..()

/obj/structure/noose/New()
	..()
	pixel_y += 16 //Noose looks like it's "hanging" in the air
	over = image(icon, "noose_overlay")
	over.layer = MOB_LAYER + 0.1

/obj/structure/noose/Destroy()
	SSobj.processing.Remove(src)
	return ..()

/obj/structure/noose/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		layer = MOB_LAYER
		overlays += over
		SSobj.processing.Add(src)
		M.pixel_y = initial(M.pixel_y) + 8 //rise them up a bit
		M.dir = SOUTH
	else
		layer = initial(layer)
		overlays -= over
		SSobj.processing.Remove(src)
		pixel_x = initial(pixel_x)
		M.pixel_x = initial(M.pixel_x)
		M.pixel_y = M.get_standard_pixel_y_offset(M.lying)

/obj/structure/noose/user_unbuckle_mob(mob/living/user)
	if(buckled_mob && buckled_mob.buckled == src)
		var/mob/living/M = buckled_mob
		if(M != user)
			user.visible_message("<span class='notice'>[user] begins to untie the noose over [M]'s neck...</span>",\
								"<span class='notice'>You begin to untie the noose over [M]'s neck...</span>")
			if(do_mob(user, M, 100))
				user.visible_message("<span class='notice'>[user] unties the noose over [M]'s neck!</span>",\
									"<span class='notice'>You untie the noose over [M]'s neck!</span>")
			else
				return
		else
			M.visible_message(\
				"<span class='warning'>[M] struggles to untie the noose over their neck!</span>",\
				"<span class='notice'>You struggle to untie the noose over your neck... (Stay still for 15 seconds.)</span>")
			if(!do_after(M, 150, target = src))
				if(M && M.buckled)
					M << "<span class='warning'>You fail to untie yourself!</span>"
				return
			if(!M.buckled)
				return
			M.visible_message(\
				"<span class='warning'>[M] unties the noose over their neck!</span>",\
				"<span class='notice'>You untie the noose over your neck!</span>")
			M.Weaken(3)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			H.noosed = 0
		unbuckle_mob()
		add_fingerprint(user)

/obj/structure/noose/user_buckle_mob(mob/living/carbon/human/M, mob/user)
	if(!in_range(user, src) || user.stat || user.restrained() || !iscarbon(M))
		return 0

	var/hashead = 0

	for(var/obj/item/organ/limb/temp in M.organs) //Checks if the target has a head.
		if(temp.body_part == HEAD)
			hashead = 1

	if(hashead != 1)
		user << "<span class='danger'>They don't have a head....</span>"
		return 0

	if(M.loc != src.loc) return 0 //Can only noose someone if they're on the same tile as noose

	add_fingerprint(user)

	if(M == user && buckle_mob(M))
		M.visible_message(\
			"<span class='suicide'>[M] ties \the [src] over their neck!</span>",\
			"<span class='suicide'>You tie \the [src] over your neck!</span>")
		playsound(user.loc, 'sound/effects/noosed.ogg', 50, 1, -1)
		add_logs(user, null, "hanged themselves", src)
		M.noosed = 1
		return 1
	else
		M.visible_message(\
			"<span class='danger'>[user] attempts to tie \the [src] over [M]'s neck!</span>",\
			"<span class='userdanger'>[user] ties \the [src] over your neck!</span>")
		user << "<span class='notice'>It will take 20 seconds and you have to stand still.</span>"
		if(do_mob(user, M, 200))
			if(buckle_mob(M))
				M.visible_message(\
					"<span class='danger'>[user] ties \the [src] over [M]'s neck!</span>",\
					"<span class='userdanger'>[user] ties \the [src] over your neck!</span>")
				playsound(user.loc, 'sound/effects/noosed.ogg', 50, 1, -1)
				add_logs(user, M, "hanged", src)
				M.noosed = 1
				return 1
			else
				user.visible_message(\
					"<span class='warning'>[user] fails to tie \the [src] over [M]'s neck!</span>",\
					"<span class='warning'>You fail to tie \the [src] over [M]'s neck!</span>")
				return 0
		else
			user.visible_message(\
				"<span class='warning'>[user] fails to tie \the [src] over [M]'s neck!</span>",\
				"<span class='warning'>You fail to tie \the [src] over [M]'s neck!</span>")
			return 0

/obj/structure/noose/process()
	if(!buckled_mob)
		SSobj.processing.Remove(src)
		buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
		pixel_x = initial(pixel_x)
		return
	ticks++
	switch(ticks)
		if(1)
			pixel_x -= 1
			buckled_mob.pixel_x -= 1
		if(2)
			pixel_x = initial(pixel_x)
			buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
		if(3) //Every third tick it plays a sound and RNG's a flavor text
			pixel_x += 1
			buckled_mob.pixel_x += 1
			if(buckled_mob.mob_has_gravity)
				if(prob(50))
					var/flavor_text = list("<span class='suicide'>[buckled_mob]'s legs flail for anything to stand on.</span>",\
											"<span class='suicide'>[buckled_mob]'s hands are desperately clutching the noose.</span>",\
											"<span class='suicide'>[buckled_mob]'s limbs sway back and forth with diminishing strength.</span>")
					if(buckled_mob.stat == DEAD)
						flavor_text = list("<span class='suicide'>[buckled_mob]'s limbs lifelessly sway back and forth.</span>",\
											"<span class='suicide'>[buckled_mob]'s eyes stare straight ahead.</span>")
					buckled_mob.visible_message(pick(flavor_text))
				playsound(buckled_mob.loc, 'sound/effects/noose_idle.ogg', 50, 1, -3)
		if(4)
			pixel_x = initial(pixel_x)
			buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
			ticks = 0
	if(buckled_mob.mob_has_gravity)
		buckled_mob.adjustOxyLoss(5)
		buckled_mob.emote("gasp")

///////////////////////////////////
// General procedures
///////////////////////////////////

//you can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		user.visible_message("<span class='notice'>[user] starts to fix some of the wires in [H]'s [affecting.name].</span>", "<span class='notice'>You start fixing some of the wires in [H]'s [affecting.name].</span>")
		if(!do_mob(user, H, 50))
			return
		if(item_heal_robotic(H, user, 0, 5))
			use(1)
		return
	else
		return ..()


/obj/item/stack/cable_coil/update_icon()
	if(!item_color)
		item_color = pick("red", "yellow", "blue", "green")
	item_state = "coil_[item_color]"
	if(amount == 1)
		icon_state = "coil_[item_color]1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil_[item_color]2"
		name = "cable piece"
	else
		icon_state = "coil_[item_color]"
		name = "cable coil"

/obj/item/stack/cable_coil/attack_hand(mob/user)
	var/obj/item/stack/cable_coil/new_cable = ..()
	if(istype(new_cable))
		new_cable.item_color = item_color
		new_cable.update_icon()

//add cables to the stack
/obj/item/stack/cable_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_icon()



///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/proc/get_new_cable(location)
	var/path = "/obj/structure/cable" + (item_color == "red" ? "" : "/" + item_color)
	return new path (location)

// called when cable_coil is clicked on a turf
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user)
	if(!isturf(user.loc))
		return

	if(!T.can_have_cabling())
		user << "<span class='warning'>You can only lay cables on catwalks and plating!</span>"
		return

	if(get_amount() < 1) // Out of cable
		user << "<span class='warning'>There is no cable left!</span>"
		return

	if(get_dist(T,user) > 1) // Too far
		user << "<span class='warning'>You can't lay cable at a place that far away!</span>"
		return

	else
		var/dirn

		if(user.loc == T)
			dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)

		for(var/obj/structure/cable/LC in T)
			if(LC.d2 == dirn && LC.d1 == 0)
				user << "<span class='warning'>There's already a cable at that position!</span>"
				return

		var/obj/structure/cable/C = get_new_cable(T)

		//set up the new cable
		C.d1 = 0 //it's a O-X node cable
		C.d2 = dirn
		C.add_fingerprint(user)
		C.updateicon()

		//create a new powernet with the cable, if needed it will be merged later
		var/datum/powernet/PN = new()
		PN.add_cable(C)

		C.mergeConnectedNetworks(C.d2) //merge the powernet with adjacents powernets
		C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)


		use(1)

		if (C.shock(user, 50))
			if (prob(50)) //fail
				C.deconstruct()

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		user << "<span class='warning'>You can't lay cable at a place that far away!</span>"
		return


	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(!U.can_have_cabling())						//checking if it's a plating or catwalk
			user << "<span class='warning'>You can only lay cables on catwalks and plating!</span>"
			return
		if(U.intact)						//can't place a cable if it's a plating with a tile on it
			user << "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>"
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					user << "<span class='warning'>There's already a cable at that position!</span>"
					return

			var/obj/structure/cable/NC = get_new_cable (U)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()

			//create a new powernet with the cable, if needed it will be merged later
			var/datum/powernet/newPN = new()
			newPN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2) //merge the powernet with adjacents powernets
			NC.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

			if(NC.d2 & (NC.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
				NC.mergeDiagonalsNetworks(NC.d2)

			use(1)

			if (NC.shock(user, 50))
				if (prob(50)) //fail
					NC.deconstruct()

			return

	// exisiting cable doesn't point at our position, so see if it's a stub
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
				user << "<span class='warning'>There's already a cable at that position!</span>"
				return


		C.cableColor(item_color)

		C.d1 = nd1
		C.d2 = nd2

		//updates the stored cable coil
		C.update_stored(2, item_color)

		C.add_fingerprint()
		C.updateicon()


		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		use(1)

		if (C.shock(user, 50))
			if (prob(50)) //fail
				C.deconstruct()
				return

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
		return

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/cut
	item_state = "coil_red2"

/obj/item/stack/cable_coil/cut/New(loc)
	..()
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/cable_coil/yellow
	item_color = "yellow"
	icon_state = "coil_yellow"

/obj/item/stack/cable_coil/blue
	item_color = "blue"
	icon_state = "coil_blue"
	item_state = "coil_blue"

/obj/item/stack/cable_coil/green
	item_color = "green"
	icon_state = "coil_green"

/obj/item/stack/cable_coil/pink
	item_color = "pink"
	icon_state = "coil_pink"

/obj/item/stack/cable_coil/orange
	item_color = "orange"
	icon_state = "coil_orange"

/obj/item/stack/cable_coil/cyan
	item_color = "cyan"
	icon_state = "coil_cyan"

/obj/item/stack/cable_coil/white
	item_color = "white"
	icon_state = "coil_white"

/obj/item/stack/cable_coil/random/New()
	item_color = pick("red","orange","yellow","green","cyan","blue","pink","white")
	icon_state = "coil_[item_color]"
	..()
