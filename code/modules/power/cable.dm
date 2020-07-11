//Use this only for things that aren't a subtype of obj/machinery/power
//For things that are, override "should_have_node()" on them
GLOBAL_LIST_INIT(wire_node_generating_types, typecacheof(list(/obj/structure/grille)))


///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////
////////////////////////////////
// Definitions
////////////////////////////////
/obj/structure/cable
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/layer_cable.dmi'
	icon_state = "l2-1-2-4-8-node"
	color = "yellow"
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	/// This is a graph of all the cables this is connected to
	/// I figure using an indexed list is faster to trasverse
	/// than either an associated list or a O(n) set
	/// Side note, UP is uesed for machine connections
	var/list/linked = list()	   			// List of all cables AND power machines linked
	var/obj/machinery/power/over = null   	// If there is a machine over us, here it is
	var/visited = FALSE			/// used for trasversing
	var/datum/powernet/powernet = null

	var/linked_state = -1	// Mask used for updating icons, -1 means we need to do a full update
	var/node = FALSE //used for sprites display
	var/cable_layer = CABLE_LAYER_2			//bitflag
	var/machinery_layer = MACHINERY_LAYER_1 //bitflag


/obj/structure/cable/layer1
	color = "red"
	cable_layer = CABLE_LAYER_1
	machinery_layer = MACHINERY_LAYER_1
	layer = WIRE_LAYER - 0.01
	icon_state = "l1-1-2-4-8-node"

/obj/structure/cable/layer2
	color = "yellow"
	cable_layer = CABLE_LAYER_1
	machinery_layer = MACHINERY_LAYER_2
	layer = WIRE_LAYER
	icon_state = "l2-1-2-4-8-node"

/obj/structure/cable/layer3
	color = "blue"
	cable_layer = CABLE_LAYER_3
	machinery_layer = MACHINERY_LAYER_3
	layer = WIRE_LAYER + 0.01
	icon_state = "l4-1-2-4-8-node"

/obj/structure/cable/Initialize(mapload)
	. = ..()
	GLOB.cable_list += src //add it to the global cable list
	visited = FALSE
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

	// on mapload, we will do it somewhere else
	if(!mapload)
		graph_cable()

// don't call this on mapload and should only be called once in Init
/obj/structure/cable/proc/graph_cable()
	// main workhouse, we go though all the sides, see what is connected
	// and connect, set the icon state, etc etc
	var/obj/machinery/power/under = null
	var/obj/machinery/power/terminal/term = null
	var/datum/powernet/largest_powernet = null
	var/list/power_nets = list()
	ASSERT(linked_state == -1) // linked state should be -1 at startup too
	// check if this cable was placed under a machine
	for(var/obj/machinery/power/P in loc)
		under = P	// we are under this,
		// under is linked latter

	// check each direction to see if we are connected to another cable
	for(var/check_dir in GLOB.cardinals)
		var/turf/TB = get_step(src, check_dir)
		// special case for terminal, no connection to the machine side from it
		if(under)
			term = under
			if(term && term.terminal.loc == TB) // if we are the term, don't connect the wire to the machine
				continue
			else if(under.terminal && under.terminal.loc == TB)
				continue // or if we are the machine, don't connect to the terminal
		var/inverse = turn(check_dir, 180)
		for(var/obj/structure/cable/C in TB)
			// we should change evey /obj/structure/cable to var/obj/structure/cable/layer2
			// .... but not now
			if(istype(C) || (C.cable_layer & cable_layer))
				linked += C
				linked_state |= check_dir
				C.linked += src
				C.linked_state |= inverse
				C.update_icon()
				// lets collect the powernets
				ASSERT(C.powernet) // should also have powernets
				if(!largest_powernet)
					largest_powernet = C.powernet
				else if(largest_powernet == C.powernet || C.powernet in power_nets)
					continue // we already collected it
				else if(C.powernet.cables.len > largest_powernet.cables.len)
					power_nets |= largest_powernet
					largest_powernet = C.powernet
				else
					power_nets |= C.powernet
				break // early exit since

	// Ok, the cable is in the graph, connected, lets merge the powernets
	// Best case, we are just assigning the powernet on the side
	// worst case, we have to merge 3 powernets.  Need to profile that
	for(var/i = 1; i <= power_nets.len; i++)
		largest_powernet.merge(power_nets[i])

	// and we are done, don't forget to add our self or any connected machine
	powernet = largest_powernet
	powernet.cables[src] = powernet
	if(under)
		node = TRUE
		connect_machine(under)
	update_icon()


// these procs should NOT be called outside of cable.dm
/obj/structure/cable/_clear_all_visited()
	var/obj/structure/cable/C
	var/list/cable_list = GLOB.cable_list
	for(var/i in 1 to cable_list.len)
		C = cable_list[i]
		C.visited = FALSE


// Main machiine connect function.
/obj/structure/cable/proc/connect_machine(obj/machinery/power/M)
	ASSERT(powernet)	// we should already have a powernet
	powernet.connect_machine(M)
	linked += M


/obj/structure/cable/proc/disconnect_machine(obj/machinery/power/M)
	ASSERT(powernet == M.powernet)
	powernet.disconnect_machine(M)
	linked -= M


/// disconnect the cable from the net, q a powernet rebuild
/obj/structure/cable/proc/disconnect()
	var/obj/structure/cable/C
	for(var/i =1 ;i <= CABLE_DIR_DOWN; i++)
		if(istype(linked[i], obj/structure/cable))
			C = linked[i]
			C.linked[CABLE_DIR_INVERT(i)] = null
			linked[i] = null
			C.update_icon()
		else if(istype(linked[i], obj/machinery/power))
			powernet.disconnect_machine(linked[i])
	SSmachines.powernets
	powernet.

/obj/structure/cable/Destroy()					// called when a cable is deleted
	Disconnect_cable()

	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	GLOB.cable_list -= src							//remove it from global cable list
	QDEL_NULL(edge)
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/cable_coil(drop_location(), 1)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////
/obj/structure/cable/update_icon_state()
	// linked_state MUST be valid, we don't check anything else
	// Use this to do quick icon updates
	if(icon_state == -1)
		refresh_icon_state()
	if(!icon_state)
		icon_state = "l[cable_layer]-noconnection"
	else
		var/list/dir_icon_list = list()
		dir_string += "l[cable_layer]"
		if(linked_state & NORTH)
			dir_string += "[NORTH]"
		if(linked_state & SOUTH)
			dir_string += "[SOUTH]"
		if(linked_state & EAST)
			dir_string += "[EAST]"
		if(linked_state & WEST)
			dir_string += "[WEST]"
		if(node)
			dir_string += "node"
		icon_state = dir_icon_list.Join("-")

// this is a hard check on the surounding
/obj/structure/cable/refresh_icon_state()
	if(!linked_dirs)
		icon_state = "l[cable_layer]-noconnection"
	else

		var/turf/T
		/// This is faster.  Why?  Because its not a loop that needs a var
		/// and if you think for(in) is fast, then your an idiot
		// Just be carful, order must be the same as GLOB
		// NORTH, SOUTH, EAST, WEST


		for(var/k in 1 to GLOB.cardinals.len)
			T = get_step(src,GLOB.cardinals[k])
			for(var/obj/structure/cable/C in T)
				if(!(cable_layer & C.cable_layer))
					continue

		if(!C)
			continue

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)
		if(!C)
			continue

		if(src == C)
			continue

		if(!(cable_layer & C.cable_layer))
			continue

		if(C.linked_dirs & inverse_dir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet, C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet
			T = get_step(loc,dir) //resolve where the thing is.
			C = locate(get_step())
			if(C && C.cable_layer == cable_layer)
				if(over && over.terminal && ov)
				dir_icon_list += "[dir]"
				//first let's add turf cables to our powernet
	//then we'll connect machines on turf where a cable is present
	for(var/atom/movable/AM in loc)

		for(var/obj/O in loc)
			if(GLOB.wire_node_generating_types[O.type])
				dir_icon_list += "node"
				break
			else if(istype(O, /obj/machinery/power))
				var/obj/machinery/power/P = O
				if(P.should_have_node())
					dir_icon_list += "node"
					break
		icon_state = dir_icon_list.Join("-")


/obj/structure/cable/proc/handlecable(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if (shock(user, 50))
			return
		user.visible_message("<span class='notice'>[user] cuts the cable.</span>", "<span class='notice'>You cut the cable.</span>")
		investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		deconstruct()
		return

	else if(W.tool_behaviour == TOOL_MULTITOOL)
		if(powernet && (powernet.avail > 0))		// is it powered?
			to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
		else
			to_chat(user, "<span class='danger'>The cable is not powered.</span>")
		shock(user, 5, 0.2)

	add_fingerprint(user)

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	handlecable(W, user, params)


// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return FALSE
	if(electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return TRUE
	else
		return FALSE

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return clamp(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/avail(amount)
	if(powernet)
		return amount ? powernet.avail >= amount : powernet.avail
	else
		return 0

/obj/structure/cable/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////
/proc/forcedPowernetRebuild()
	// This will DELETE all powernets, and rebuild them as graphed
	// Any power used or not used goes to 0 and will have to wait
	// a machine tick to turn back up



// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/inverse_dir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)
		if(!C)
			continue

		if(src == C)
			continue

		if(!(cable_layer & C.cable_layer))
			continue

		if(C.linked_dirs & inverse_dir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet, C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()
	node = FALSE

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf where a cable is present
	for(var/atom/movable/AM in loc)
		if(istype(AM, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet) //already connected
				continue

			to_connect += N.terminal //we'll connect the machines after all cables are merged

		else if(istype(AM, /obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		node = TRUE
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

/obj/structure/cable/proc/get_cable_connections(powernetless_only)
	. = list()
	var/turf/T = get_turf(src)
	for(var/check_dir in GLOB.cardinals)
		if(linked_dirs & check_dir)
			T = get_step(src, check_dir)
			for(var/obj/structure/cable/C in T)
				if(cable_layer & C.cable_layer)
					. += C

/obj/structure/cable/proc/get_all_cable_connections(powernetless_only)
	. = list()
	var/turf/T
	for(var/check_dir in GLOB.cardinals)
		T = get_step(src, check_dir)
		for(var/obj/structure/cable/C in T.contents - src)
			. += C

/obj/structure/cable/proc/get_machine_connections(powernetless_only)
	. = list()
	for(var/obj/machinery/power/P in get_turf(src))
		if(!powernetless_only || !P.powernet)
			if(P.anchored)
				. += P



// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove = TRUE)
	if(!powernet)
		return

	var/turf/T1 = loc
	if(!T1)
		return

	if(linked.len > 0)
		for(var/i in 1 to linked.len)
			if(istype(linked[i], /obj/machinery/power))
				var/obj/machinery/power/M = linked[i]
					M.powernet.disconnect_machine(M)
			else if(istype(linked[i], /obj/structure/cable))
				var/obj/structure/cable/C = linked[i]
				var/dir = get_dir(loc,C.loc)
				var/inverse = turn(dir,180)
				linked_state &= ~dir
				C.linked_state &= ~inverse
				C.linked  -= src
				linked -= C

	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		moveToNullspace()

	powernet.cables[src] = null  //remove the cut cable from its powernet
	var/current_powernet = powernet
	powernet = null
	addtimer(CALLBACK(O, .proc/split_powernet(current_powernet), O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

GLOBAL_LIST_INIT(cable_coil_recipes, list(new/datum/stack_recipe("cable restraints", /obj/item/restraints/handcuffs/cable, 15), new/datum/stack_recipe("multilayer cable", /obj/structure/cable/multilayer, 1), new/datum/stack_recipe("multiZ cable", /obj/structure/cable/multilayer/multiz, 1)))

/obj/item/stack/cable_coil
	name = "cable coil"
	custom_price = 75
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	inhand_icon_state = "coil"
	novariants = FALSE
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	color = "yellow"
	desc = "A coil of insulated power cable."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "cable piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/copper = 2) //2 copper per cable in the coil
	usesound = 'sound/items/deconstruct.ogg'
	var/cable_color = "yellow"
	var/obj/structure/cable/target_type = /obj/structure/cable
	var/target_layer = CABLE_LAYER_2

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null)
	. = ..()
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	recipes = GLOB.cable_coil_recipes

/obj/item/stack/cable_coil/examine(mob/user)
	. = ..()
	. += "<b>Ctrl+Click</b> to change the layer you are placing on."

/obj/item/stack/cable_coil/update_icon_state()
	if(novariants)
		return
	icon_state = "[initial(icon_state)][amount < 3 ? amount : ""]"
	var/how_many_things = amount < 3 ? "piece" : "coil"
	name = "cable [how_many_things]"
	desc = "A [how_many_things] of insulated power cable."

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/stack/cable_coil/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

GLOBAL_LIST(cable_radial_layer_list)

/obj/item/stack/cable_coil/CtrlClick(mob/living/user)
	if(loc!=user)
		return ..()
	if(!user)
		return
	if(!GLOB.cable_radial_layer_list)
		GLOB.cable_radial_layer_list = list(
		"Layer 1" = image(icon = 'icons/mob/radial.dmi', icon_state = "coil-red"),
		"Layer 2" = image(icon = 'icons/mob/radial.dmi', icon_state = "coil-yellow"),
		"Layer 3" = image(icon = 'icons/mob/radial.dmi', icon_state = "coil-blue"),
		"Multilayer cable hub" = image(icon = 'icons/obj/power.dmi', icon_state = "cable_bridge"),
		"Multi Z layer cable hub" = image(icon = 'icons/obj/power.dmi', icon_state = "cablerelay-broken-cable")
		)
	var/layer_result = show_radial_menu(user, src, GLOB.cable_radial_layer_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(layer_result)
		if("Layer 1")
			color = "red"
			target_type = /obj/structure/cable/layer1
			target_layer = CABLE_LAYER_1
			novariants = FALSE
		if("Layer 2")
			color = "yellow"
			target_type = /obj/structure/cable
			target_layer = CABLE_LAYER_2
			novariants = FALSE
		if("Layer 3")
			color = "blue"
			target_type = /obj/structure/cable/layer3
			target_layer = CABLE_LAYER_3
			novariants = FALSE
		if("Multilayer cable hub")
			name = "multilayer cable hub"
			desc = "A multilayer cable hub."
			icon_state = "cable_bridge"
			color = "white"
			target_type = /obj/structure/cable/multilayer
			target_layer = CABLE_LAYER_2
			novariants = TRUE
		if("Multi Z layer cable hub")
			name = "multi z layer cable hub"
			desc = "A multi-z layer cable hub."
			icon_state = "cablerelay-broken-cable"
			color = "white"
			target_type = /obj/structure/cable/multilayer/multiz
			target_layer = CABLE_LAYER_2
			novariants = TRUE
	update_icon()


///////////////////////////////////
// General procedures
///////////////////////////////////
//you can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		if(user == H)
			user.visible_message("<span class='notice'>[user] starts to fix some of the wires in [H]'s [affecting.name].</span>", "<span class='notice'>You start fixing some of the wires in [H == user ? "your" : "[H]'s"] [affecting.name].</span>")
			if(!do_mob(user, H, 50))
				return
		if(item_heal_robotic(H, user, 0, 15))
			use(1)
		return
	else
		return ..()

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

// called when cable_coil is clicked on a turf
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
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

	for(var/obj/structure/cable/C in T)
		if(C.cable_layer & target_layer)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = new target_type(T)

	//create a new powernet with the cable, if needed it will be merged later
	var/datum/powernet/PN = new()
	PN.add_cable(C)

	for(var/dir_check in GLOB.cardinals)
		C.mergeConnectedNetworks(dir_check) //merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

	use(1)

	if(C.shock(user, 50))
		if(prob(50)) //fail
			new /obj/item/stack/cable_coil(get_turf(C), 1)
			C.deconstruct()

	return C

/obj/item/stack/cable_coil/five
	amount = 5

/obj/item/stack/cable_coil/cut
	amount = null
	icon_state = "coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	. = ..()
	if(!amount)
		amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/cable_coil/cyborg
	is_cyborg = 1
	custom_materials = list()
	cost = 1

#undef UNDER_SMES
#undef UNDER_TERMINAL

///multilayer cable to connect different layers
/obj/structure/cable/multilayer
	name = "multilayer cable hub"
	desc = "A flexible, superconducting insulated multilayer hub for heavy-duty multilayer power transfer."
	icon = 'icons/obj/power.dmi'
	icon_state = "cable_bridge"
	cable_layer = CABLE_LAYER_2
	machinery_layer = MACHINERY_LAYER_1
	layer = WIRE_LAYER - 0.02 //Below all cables Disabled layers can lay over hub
	color = "white"
	var/obj/effect/node/machinery_node
	var/obj/effect/node/layer1/cable_node_1
	var/obj/effect/node/layer2/cable_node_2
	var/obj/effect/node/layer3/cable_node_3

/obj/effect/node
	icon = 'icons/obj/power_cond/layer_cable.dmi'
	icon_state = "l2-noconnection"
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
	color = "black"

/obj/effect/node/layer1
	color = "red"
	icon_state = "l1-1-2-4-8-node"
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_UNDERLAY

/obj/effect/node/layer2
	color = "yellow"
	icon_state = "l2-1-2-4-8-node"
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_UNDERLAY

/obj/effect/node/layer3
	color = "blue"
	icon_state = "l4-1-2-4-8-node"
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_UNDERLAY

/obj/structure/cable/multilayer/update_icon_state()
	return

/obj/structure/cable/multilayer/update_icon()

	machinery_node?.alpha = machinery_layer & MACHINERY_LAYER_1 ? 255 : 0

	cable_node_1?.alpha = cable_layer & CABLE_LAYER_1 ? 255 : 0

	cable_node_2?.alpha = cable_layer & CABLE_LAYER_2 ? 255 : 0

	cable_node_3?.alpha = cable_layer & CABLE_LAYER_3 ? 255 : 0

	return ..()

/obj/structure/cable/multilayer/Initialize(mapload)
	. = ..()

	var/turf/T = get_turf(src)
	for(var/obj/structure/cable/C in T.contents - src)
		if(C.cable_layer & cable_layer)
			C.deconstruct()						// remove adversary cable
	if(!mapload)
		auto_propagate_cut_cable(src)

	machinery_node = new /obj/effect/node()
	vis_contents += machinery_node
	cable_node_1 = new /obj/effect/node/layer1()
	vis_contents += cable_node_1
	cable_node_2 = new /obj/effect/node/layer2()
	vis_contents += cable_node_2
	cable_node_3 = new /obj/effect/node/layer3()
	vis_contents += cable_node_3
	update_icon()

/obj/structure/cable/multilayer/Destroy()					// called when a cable is deleted
	QDEL_NULL(machinery_node)
	QDEL_NULL(cable_node_1)
	QDEL_NULL(cable_node_2)
	QDEL_NULL(cable_node_3)
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/multilayer/examine(mob/user)
	. += ..()
	. += "<span class='notice'>L1:[cable_layer & CABLE_LAYER_1 ? "Connect" : "Disconnect"].</span>"
	. += "<span class='notice'>L2:[cable_layer & CABLE_LAYER_2 ? "Connect" : "Disconnect"].</span>"
	. += "<span class='notice'>L3:[cable_layer & CABLE_LAYER_3 ? "Connect" : "Disconnect"].</span>"
	. += "<span class='notice'>M:[machinery_layer & MACHINERY_LAYER_1 ? "Connect" : "Disconnect"].</span>"

GLOBAL_LIST(hub_radial_layer_list)

/obj/structure/cable/multilayer/attack_robot(mob/user)
	attack_hand(user)

/obj/structure/cable/multilayer/attack_hand(mob/living/user)
	if(!user)
		return
	if(!GLOB.hub_radial_layer_list)
		GLOB.hub_radial_layer_list = list(
			"Layer 1" = image(icon = 'icons/mob/radial.dmi', icon_state = "coil-red"),
			"Layer 2" = image(icon = 'icons/mob/radial.dmi', icon_state = "coil-yellow"),
			"Layer 3" = image(icon = 'icons/mob/radial.dmi', icon_state = "coil-blue"),
			"Machinery" = image(icon = 'icons/obj/power.dmi', icon_state = "smes")
			)

	var/layer_result = show_radial_menu(user, src, GLOB.hub_radial_layer_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	var/CL
	switch(layer_result)
		if("Layer 1")
			CL = CABLE_LAYER_1
			to_chat(user, "<span class='warning'>You toggle L1 connection.</span>")
		if("Layer 2")
			CL = CABLE_LAYER_2
			to_chat(user, "<span class='warning'>You toggle L2 connection.</span>")
		if("Layer 3")
			CL = CABLE_LAYER_3
			to_chat(user, "<span class='warning'>You toggle L3 connection.</span>")
		if("Machinery")
			machinery_layer ^= MACHINERY_LAYER_1
			to_chat(user, "<span class='warning'>You toggle machinery connection.</span>")

	cut_cable_from_powernet(FALSE)

	Disconnect_cable()

	cable_layer ^= CL

	Connect_cable(TRUE)

	Reload()

/obj/structure/cable/multilayer/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

///Reset powernet in this hub.
/obj/structure/cable/multilayer/proc/Reload()
	var/turf/T = get_turf(src)
	for(var/obj/structure/cable/C in T.contents - src)
		if(C.cable_layer & cable_layer)
			C.deconstruct()						// remove adversary cable
	auto_propagate_cut_cable(src)				// update the powernets

/obj/structure/cable/multilayer/CtrlClick(mob/living/user)
	to_chat(user, "<span class='warning'>You pust reset button.</span>")
	addtimer(CALLBACK(src, .proc/Reload), 10, TIMER_UNIQUE) //spam protect

