GLOBAL_LIST_INIT(cable_colors, list(
	"yellow" = "#ffff00",
	"green" = "#00aa00",
	"blue" = "#1919c8",
	"pink" = "#ff3cc8",
	"orange" = "#ff8000",
	"cyan" = "#00ffff",
	"white" = "#ffffff",
	"red" = "#ff0000"
	))

///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)

	//USE DIRECTION DEFINES IN CODE, NOT NUMBERS! THIS IS FOR SPRITEWORK. Also, use 16 for UP and 32 for DOWN.
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

//Cables can only connect to cables of the exact same type as them!

/obj/structure/cable
	name = "cable"
	desc = "A generic industrial-grade flexible superconductor sheathed in rubber."
	icon = 'icons/obj/power_cond/cables.dmi'
	icon_state = "0-1"
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	anchored = TRUE
	layer = WIRE_LAYER
	level = ATOM_LEVEL_UNDERFLOOR
	color = "#ff0000"
	var/d1			//Direction define, if null it will try to initialize from icon_state. Knot cables should have D1 as none.
	var/d2			//Same as above.
	var/cable_item_type = /obj/item/stack/cable_coil		//EXACT path.
	var/cable_color = "red"
	var/datum/cablenet/network
	var/network_type = /datum/cablenet

/obj/structure/cable/proc/set_color(newcolor)
	color = GLOB.cable_colors[newcolor] || color

// the power cable object
/obj/structure/cable/Initialize(mapload, param_color, dir1, dir2)
	. = ..()
	var/d1 = dir1
	var/d2 = dir2

	var/icon_state_resolved = FALSE
	//Fill in d1/d2 if icon state has it but it doesn't.
	if(isnull(d1) || isnull(d2))
		var/dash = findtext(icon_state, "-")
		d1 = text2num(copytext(icon_state, 1, dash))
		d2 = text2num(copytext(icon_state, dash+1))
	var/turf/T = get_turf(src)			// hide if turf is not intact
	if(level == ATOM_LEVEL_UNDERFLOOR)
		hide(T.intact)
	set_color(param_color || cable_color || pick(GLOB.cable_colors))
	set_directions(d1, d2)

/obj/structure/cable/Destroy()					// called when a cable is deleted
	if(network)
		network.cut_cable(src)
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = loc
		var/obj/item/stack/cable_coil/C = new(cable_item_type, d1? 2 : 1, cable_color)
		transfer_fingerprints_to(C)
	qdel(src)

//If underfloor, hide the cable
/obj/structure/cable/hide(i)
	if(level == ATOM_LEVEL_UNDERFLOOR && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/structure/cable/proc/set_directions(dir1, dir2)
	if(!dir2)
		return FALSE
	if(dir1 == d1 && dir2 == d2)
		return TRUE
	var/has_network = network? TRUE : FALSE
	var/list/changed = has_network? ((connected_cables(d1, d2) + get_node_connections(d1, d2)) - (connected_cables(dir1, dir2) + get_node_connections(dir1, dir2))) : null	//don't bother doing this if there's no network.
	if(LAZYLEN(changed))
		disconnect_from_network()
	d1 = dir1
	d2 = dir2
	if(!has_network || changed.len)		//Changed will be a list if there's a network initially.
		connect_to_network()
	return TRUE

/obj/structure/cable/update_icon()
	icon_state = "[d1]-[d2]"
	color = null
	add_atom_colour(cable_color, FIXED_COLOUR_PRIORITY)

/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(handlecable(W, user, params))
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if (shock(user, 50))
			return
		user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
		stored.add_fingerprint(user)
		investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		deconstruct()
		return
	return ..()

/obj/structure/cable/handlecable(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return FALSE

	else if(W.type == cable_item_type)
		var/obj/item/stack/cable_coil/power/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return TRUE
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/twohanded/rcl))
		var/obj/item/twohanded/rcl/R = W
		if(R.loaded.type == cable_item_type)
			R.loaded.cable_join(src, user)
			R.is_empty(user)
			return TRUE
	return TRUE.

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	return

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/is_node()
	return d1 == NONE

/obj/structure/cable/proc/connected_cables(d1 = src.d1, d2 = src.d2)
	. = list()
	var/turf/T = get_turf(src)
	var/is_node = is_node()
	for(var/i in T.contents)			//Get stuff on our turf
		var/obj/structure/cable/C = i
		if((C.type == type) && ((C.d1 == opp) || (C.d2 == opp)) && can_connect_cable(C) && C.can_connect_cable(src))
			. |= C
	if(d1)
		var/turf/T1 = get_dir(T, d1)
		var/opp = turn(d1, 180)
		for(var/i in T1.contents)
			var/obj/structure/cable/C = i
			if((C.type == type) && ((C.d1 == opp) || (C.d2 == opp)) && can_connect_cable(C) && C.can_connect_cable(src))
				. |= C
	if(d2)
		var/turf/T2 = get_dir(T, d2)
		var/opp = turn(d2, 180)
		for(var/i in T2.contents)
			var/obj/structure/cable/C = i
			if((C.type == type) && ((C.d1 == opp) || (C.d2 == opp)) && can_connect_cable(C) && C.can_connect_cable(src))
				. |= C

/obj/structure/cable/proc/can_connect_cable(obj/structure/cable/other, turf/other)
	return TRUE

/obj/structure/cable/proc/connect_to_network()
	var/list/obj/structure/cable/cables = connected_cables()
	for(var/i in cables)
		var/obj/structure/cable/C = i
		if(C.network)
			C.network.propogate_network(src)
			return
	network = new network_type(src)
	network.build_network(src)

/obj/structure/cable/proc/on_network_connect(datum/cablenet/C)

/obj/structure/cable/proc/disconnect_from_network()
	if(network)
		network.cut_cable(src)

/obj/structure/cable/proc/on_network_disconnect(datum/cablenet/C)

/obj/structure/cable/proc/force_rebuild_network()
	if(QDELETED(src))
		return
	network = new
	network.build_network(src)

/obj/structure/cable/proc/force_rebuild_network_branched(list/branches)
	if(isnull(branches))
		return force_rebuild_network()
	if(!branches.len)					//No need!
		return
	if(QDELETED(src))
		return
	network = new
	network.build_network(src)
	for(var/i in branches)
		if(i in network.cables)
			branches -= i

/proc/make_cable(path, loc, color, d1, d2)
	return new path(loc, color, d1, d2)

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

GLOBAL_LIST_INIT(cable_coil_recipes, list (new/datum/stack_recipe("cable restraints", /obj/item/restraints/handcuffs/cable, 15)))

/obj/item/stack/cable_coil
	name = "cable coil"
	desc = "A coil of industrial grade flexible superconductor wiring."
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	item_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil
	item_color = "red"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10, MAT_GLASS=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "cable piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list("copper" = 2) //2 copper per cable in the coil. Also, great superconductor..
	usesound = 'sound/items/deconstruct.ogg'
	var/can_change_color = FALSE
	var/cable_path = /obj/structure/cable

/obj/item/stack/cable_coil/attack_self(mob/user)
	. = ..()
	if(!can_change_color)
		return
	var/cable_color = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	item_color = cable_color
	update_icon()

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null, param_color = null)
	. = ..()

	var/list/cable_colors = GLOB.cable_colors
	item_color = param_color || item_color || pick(cable_colors)
	if(cable_colors[item_color])
		item_color = cable_colors[item_color]

	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	recipes = GLOB.cable_coil_recipes

/obj/item/stack/cable_coil/update_icon()
	icon_state = "[initial(item_state)][amount < 3 ? amount : ""]"
	name = "cable [amount < 3 ? "piece" : "coil"]"
	color = null
	add_atom_colour(item_color, FIXED_COLOUR_PRIORITY)

/obj/item/stack/cable_coil/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/item/stack/cable_coil/new_cable = ..()
	if(istype(new_cable))
		new_cable.item_color = item_color
		new_cable.update_icon()
		new_cable.cable_path = cable_path

//add cables to the stack
/obj/item/stack/cable_coil/power/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_icon()

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

// called when cable_coil is clicked on a turf
/obj/item/stack/cable_coil/power/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/cable/power/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/power/C = make_cable(cable_path, T, item_color, 0, dirn)

	C.add_fingerprint(user)

/*
	//create a new powernet with the cable, if needed it will be merged later
	var/datum/cablenet/power/PN = new()
	PN.add_cable(C)

	C.mergeConnectedNetworks(C.d2) //merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

	if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)
*/

	use(1)

	if(C.shock(user, 50))
		if(prob(50)) //fail
			C.deconstruct()

	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/power/proc/cable_join(obj/structure/cable/power/C, mob/user, var/showerror = TRUE)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return


	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(!U.can_have_cabling())						//checking if it's a plating or catwalk
			if (showerror)
				to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
			return
		if(U.intact)						//can't place a cable if it's a plating with a tile on it
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/cable/power/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					if (showerror)
						to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
					return

			var/obj/structure/cable/power/NC = make_cable(cable_path, U, item_color, 0, fdirn)
			NC.add_fingerprint(user)

/*
			//create a new powernet with the cable, if needed it will be merged later
			var/datum/cablenet/power/newPN = new()
			newPN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2) //merge the powernet with adjacents powernets
			NC.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

			if(NC.d2 & (NC.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
				NC.mergeDiagonalsNetworks(NC.d2)
*/


			use(1)

			if (NC.shock(user, 50))
				if (prob(50)) //fail
					NC.deconstruct()

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/power/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				if (showerror)
					to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")

				return

		C.set_directions(nd1, nd2)
		C.add_fingerprint(user)

/*
		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)
*/

		use(1)

		if (C.shock(user, 50))
			if (prob(50)) //fail
				C.deconstruct()
				return

//		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
