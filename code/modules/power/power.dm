//////////////////////////////
// POWER MACHINERY BASE CLASS
//////////////////////////////

/////////////////////////////
// Definitions
/////////////////////////////

/obj/machinery/power
	name = null
	icon = 'icons/obj/machines/engine/other.dmi'
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	///The powernet our machine is connected to.
	var/datum/powernet/powernet
	///Cable layer to which the machine is connected.
	var/cable_layer = CABLE_LAYER_2
	///Can the cable_layer be tweked with a multi tool
	var/can_change_cable_layer = FALSE

/obj/machinery/power/Initialize(mapload)
	. = ..()
	if(isturf(loc))
		var/turf/turf_loc = loc
		turf_loc.add_blueprints_preround(src)

/obj/machinery/power/Destroy()
	disconnect_from_network()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(update_cable_icons_on_turf), get_turf(src)), 0.3 SECONDS)
	return ..()

///////////////////////////////
// General procedures
//////////////////////////////

// common helper procs for all power machines
// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

//override this if the machine needs special functionality for making wire nodes appear, ie emitters, generators, etc.
/obj/machinery/power/proc/should_have_node()
	return FALSE

/obj/machinery/power/examine(mob/user)
	. = ..()
	if(can_change_cable_layer)
		if(!QDELETED(powernet))
			. += span_notice("It's operating on the [LOWER_TEXT(GLOB.cable_layer_to_name["[cable_layer]"])].")
		else
			. += span_warning("It's disconnected from the [LOWER_TEXT(GLOB.cable_layer_to_name["[cable_layer]"])].")
		. += span_notice("It's power line can be changed with a [EXAMINE_HINT("multitool")].")

/obj/machinery/power/multitool_act(mob/living/user, obj/item/tool)
	if(can_change_cable_layer)
		return cable_layer_act(user, tool)

/obj/machinery/power/multitool_act_secondary(mob/living/user, obj/item/tool)
	return multitool_act(user, tool)

/// Called on multitool_act when we can change cable layers, override to add more conditions
/obj/machinery/power/proc/cable_layer_act(mob/living/user, obj/item/tool)
	var/choice = tgui_input_list(user, "Select Power Line For Operation", "Select Cable Layer", GLOB.cable_name_to_layer)
	if(isnull(choice) || QDELETED(src) || QDELETED(user) || QDELETED(tool) || !user.Adjacent(src) || !user.is_holding(tool))
		return ITEM_INTERACT_BLOCKING

	cable_layer = GLOB.cable_name_to_layer[choice]
	balloon_alert(user, "now operating on the [choice]")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount
		return TRUE
	else
		return FALSE

/obj/machinery/power/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/machinery/power/proc/surplus()
	if(powernet)
		return clamp(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/machinery/power/proc/avail(amount)
	if(powernet)
		return amount ? powernet.avail >= amount : powernet.avail
	else
		return 0

/obj/machinery/power/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/machinery/power/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/machinery/power/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return

// returns true if the area has power on given channel (or doesn't require power).
// defaults to power_channel
/obj/machinery/proc/powered(chan = power_channel, ignore_use_power = FALSE)
	if(!use_power && !ignore_use_power)
		return TRUE

	var/area/A = get_area(src) // make sure it's in an area
	if(!A)
		return FALSE // if not, then not powered

	return A.powered(chan) // return power status of the area

/**
 * Returns the available energy from the apc's cell and grid that can be used.
 * Args:
 * - consider_cell: Whether to count the energy from the APC's cell or not.
 * Returns: The available energy the machine can access from the APC.
 */
/obj/machinery/proc/available_energy(consider_cell = TRUE)
	var/area/home = get_area(src)

	if(isnull(home))
		return FALSE
	if(!home.requires_power)
		return INFINITY

	var/obj/machinery/power/apc/local_apc = home.apc
	if(isnull(local_apc))
		return FALSE

	return consider_cell ? local_apc.available_energy() : local_apc.surplus()

/**
 * Draws energy from the APC. Will use excess energy from the APC's connected grid,
 * then use energy from the APC's cell if there wasn't enough energy from the grid, unless ignore_apc is true.
 * Args:
 * - amount: The amount of energy to use.
 * - channel: The power channel to use.
 * - ignore_apc: If true, do not consider the APC's cell when demanding energy.
 * - force: If true and if there isn't enough energy, consume the remaining energy. Returns 0 if false and there isn't enough energy.
 * Returns: The amount of energy used.
 */
/obj/machinery/proc/use_energy(amount, channel = power_channel, ignore_apc = FALSE, force = TRUE)
	if(amount <= 0) //just in case
		return FALSE
	var/area/home = get_area(src)

	if(isnull(home))
		return FALSE //apparently space isn't an area
	if(!home.requires_power)
		return amount //Shuttles get free power, don't ask why

	var/obj/machinery/power/apc/local_apc = home.apc
	if(isnull(local_apc))
		return FALSE

	// Surplus from the grid.
	var/surplus = local_apc.surplus()
	var/grid_used = min(surplus, amount)
	var/apc_used = 0
	if((amount > grid_used) && !ignore_apc && !QDELETED(local_apc.cell)) // Use from the APC's cell if there isn't enough energy from the grid.
		apc_used = local_apc.cell.use(amount - grid_used, force = force)

	if(!force && (amount < grid_used + apc_used)) // If we aren't forcing it and there isn't enough energy to supply demand, return nothing.
		return FALSE

	// Use the grid's and APC's energy.
	amount = grid_used + apc_used
	local_apc.add_load(grid_used JOULES)
	home.use_energy(amount JOULES, channel)
	return amount

/**
 * An alternative to 'use_power', this proc directly costs the APC in direct charge, as opposed to prioritising the grid.
 * Args:
 * - amount: How much energy the APC's cell is to be costed.
 * - force: If true, consumes the remaining energy of the cell if there isn't enough energy to supply the demand.
 * Returns: The amount of energy that got used by the cell.
 */
/obj/machinery/proc/directly_use_energy(amount, force = FALSE)
	var/area/my_area = get_area(src)
	if(isnull(my_area))
		stack_trace("machinery is somehow not in an area, nullspace?")
		return FALSE
	if(!my_area.requires_power)
		return amount

	var/obj/machinery/power/apc/my_apc = my_area.apc
	if(isnull(my_apc) || QDELETED(my_apc.cell))
		return FALSE
	return my_apc.cell.use(amount, force = force)

/**
 * Attempts to draw power directly from the APC's Powernet rather than the APC's battery. For high-draw machines, like the cell charger
 *
 * Checks the surplus power on the APC's powernet, and compares to the requested amount. If the requested amount is available, this proc
 * will add the amount to the APC's usage and return that amount. Otherwise, this proc will return FALSE.
 * If the take_any var arg is set to true, this proc will use and return any surplus that is under the requested amount, assuming that
 * the surplus is above zero.
 * Args:
 * - amount, the amount of power requested from the powernet. In joules.
 * - take_any, a bool of whether any amount of power is acceptable, instead of all or nothing. Defaults to FALSE
 */
/obj/machinery/proc/use_power_from_net(amount, take_any = FALSE)
	if(amount <= 0) //just in case
		return FALSE
	var/area/home = get_area(src)

	if(!home)
		return FALSE //apparently space isn't an area
	if(!home.requires_power)
		return amount //Shuttles get free power, don't ask why

	var/obj/machinery/power/apc/local_apc = home.apc
	if(!local_apc)
		return FALSE
	var/surplus = local_apc.surplus()
	if(surplus <= 0) //I don't know if powernet surplus can ever end up negative, but I'm just gonna failsafe it
		return FALSE
	if(surplus < amount)
		if(!take_any)
			return FALSE
		amount = surplus
	local_apc.add_load(amount)
	return amount

/**
 * Draws power from the apc's powernet and cell to charge a power cell.
 * Args:
 * - amount: The amount of energy given to the cell.
 * - cell: The cell to charge.
 * - grid_only: If true, only draw from the grid and ignore the APC's cell.
 * - channel: The power channel to use.
 * Returns: The amount of energy the cell received.
 */
/obj/machinery/proc/charge_cell(amount, obj/item/stock_parts/power_store/cell, grid_only = FALSE, channel = AREA_USAGE_EQUIP)
	var/demand = use_energy(min(amount, cell.used_charge()), channel = channel, ignore_apc = grid_only)
	var/power_given = cell.give(demand)
	return power_given


/obj/machinery/proc/addStaticPower(value, powerchannel)
	var/area/A = get_area(src)
	A?.addStaticPower(value, powerchannel)

/obj/machinery/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

/**
 * Called whenever the power settings of the containing area change
 *
 * by default, check equipment channel & set flag, can override if needed
 *
 * Returns TRUE if the NOPOWER flag was toggled
 */
/obj/machinery/proc/power_change()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	if(machine_stat & BROKEN)
		update_appearance()
		return
	var/initial_stat = machine_stat
	if(powered(power_channel))
		set_machine_stat(machine_stat & ~NOPOWER)
		if(initial_stat & NOPOWER)
			SEND_SIGNAL(src, COMSIG_MACHINERY_POWER_RESTORED)
			. = TRUE
	else
		set_machine_stat(machine_stat | NOPOWER)
		if(!(initial_stat & NOPOWER))
			SEND_SIGNAL(src, COMSIG_MACHINERY_POWER_LOST)
			. = TRUE

	if(appearance_power_state != (machine_stat & NOPOWER))
		update_appearance()

// Saves like 300ms of init by not duping calls in the above proc
/obj/machinery/update_appearance(updates)
	. = ..()
	appearance_power_state = machine_stat & NOPOWER

// connect the machine to a powernet if a node cable or a terminal is present on the turf
/obj/machinery/power/proc/connect_to_network()
	var/turf/T = src.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node(cable_layer) //check if we have a node cable on the machine turf, the first found is picked
	if(!C || !C.powernet)
		var/obj/machinery/power/terminal/term = locate(/obj/machinery/power/terminal) in T
		if(!term || !term.powernet)
			return FALSE
		else
			term.powernet.add_machine(src)
			return TRUE

	C.powernet.add_machine(src)
	return TRUE

// remove and disconnect the machine from its current powernet
/obj/machinery/power/proc/disconnect_from_network()
	if(!powernet)
		return FALSE
	powernet.remove_machine(src)
	return TRUE

// attach a wire to a power machine - leads from the turf you are standing on
//almost never called, overwritten by all power machines but terminal and generator
/obj/machinery/power/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		var/turf/T = user.loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE || !isfloorturf(T))
			return
		if(get_dist(src, user) > 1)
			return
		coil.place_turf(T, user)
	else
		return ..()


///////////////////////////////////////////
// Powernet handling helpers
//////////////////////////////////////////

//returns all the cables WITHOUT a powernet in neighbors turfs,
//pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_connections()
	. = list()
	var/turf/T

	for(var/card in GLOB.cardinals)
		T = get_step(loc,card)

		for(var/obj/structure/cable/C in T)
			if(C.powernet)
				continue
			. += C
	return .

//returns all the cables in neighbors turfs,
//pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_marked_connections()
	. = list()
	var/turf/T

	for(var/card in GLOB.cardinals)
		T = get_step(loc,card)

		for(var/obj/structure/cable/C in T)
			. += C
	return .

//returns all the NODES (O-X) cables WITHOUT a powernet in the turf the machine is located at
/obj/machinery/power/proc/get_indirect_connections()
	. = list()
	for(var/obj/structure/cable/C in loc)
		if(C.powernet)
			continue
		. += C
	return .

/proc/update_cable_icons_on_turf(turf/T)
	for(var/obj/structure/cable/C in T.contents)
		C.update_appearance()

///////////////////////////////////////////
// GLOBAL PROCS for powernets handling
//////////////////////////////////////////

///remove the old powernet and replace it with a new one throughout the network.
/proc/propagate_network(obj/structure/cable/C, datum/powernet/PN, skip_assigned_powernets = FALSE)
	var/list/found_machines = list()
	var/list/cables = list()
	var/index = 1
	var/obj/structure/cable/working_cable

	cables[C] = TRUE //associated list for performance reasons

	while(index <= length(cables))
		working_cable = cables[index]
		index++

		var/list/connections = working_cable.get_cable_connections(skip_assigned_powernets)

		for(var/obj/structure/cable/cable_entry in connections)
			if(!cables[cable_entry]) //Since it's an associated list, we can just do an access and check it's null before adding; prevents duplicate entries
				cables[cable_entry] = TRUE

	for(var/obj/structure/cable/cable_entry in cables)
		PN.add_cable(cable_entry)
		found_machines += cable_entry.get_machine_connections(skip_assigned_powernets)

	//now that the powernet is set, connect found machines to it
	for(var/obj/machinery/power/PM in found_machines)
		if(!PM.connect_to_network()) //couldn't find a node on its turf...
			PM.disconnect_from_network() //... so disconnect if already on a powernet


//Merge two powernets, the bigger (in cable length term) absorbing the other
/proc/merge_powernets(datum/powernet/net1, datum/powernet/net2)
	if(!net1 || !net2) //if one of the powernet doesn't exist, return
		return

	if(net1 == net2) //don't merge same powernets
		return

	//We assume net1 is larger. If net2 is in fact larger we are just going to make them switch places to reduce on code.
	if(net1.cables.len < net2.cables.len) //net2 is larger than net1. Let's switch them around
		var/temp = net1
		net1 = net2
		net2 = temp

	//merge net2 into net1
	for(var/obj/structure/cable/Cable in net2.cables) //merge cables
		net1.add_cable(Cable)

	for(var/obj/machinery/power/Node in net2.nodes) //merge power machines
		if(!Node.connect_to_network())
			Node.disconnect_from_network() //if somehow we can't connect the machine to the new powernet, disconnect it from the old nonetheless

	return net1

/// Extracts the powernet and cell of the provided power source
/proc/get_powernet_info_from_source(power_source)
	var/area/source_area
	if (isarea(power_source))
		source_area = power_source
		power_source = source_area.apc
	else if (istype(power_source, /obj/structure/cable))
		var/obj/structure/cable/Cable = power_source
		power_source = Cable.powernet

	var/datum/powernet/PN
	var/obj/item/stock_parts/power_store/cell

	if (istype(power_source, /datum/powernet))
		PN = power_source
	else if (istype(power_source, /obj/item/stock_parts/power_store))
		cell = power_source
	else if (istype(power_source, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = power_source
		cell = apc.cell
		if (apc.terminal)
			PN = apc.terminal.powernet
	else
		return FALSE

	if (!cell && !PN)
		return

	return list("powernet" = PN, "cell" = cell)

//Determines how strong could be shock, deals damage to mob, uses power.
//M is a mob who touched wire/whatever
//power_source is a source of electricity, can be power cell, area, apc, cable, powernet or null
//source is an object caused electrocuting (airlock, grille, etc)
//siemens_coeff - layman's terms, conductivity
//dist_check - set to only shock mobs within 1 of source (vendors, airlocks, etc.)
//No animations will be performed by this proc.
/proc/electrocute_mob(mob/living/carbon/victim, power_source, obj/source, siemens_coeff = 1, dist_check = FALSE)
	if(!istype(victim) || ismecha(victim.loc))
		return FALSE //feckin mechs are dumb

	if(dist_check)
		if(!in_range(source, victim))
			return FALSE

	if(victim.wearing_shock_proof_gloves())
		SEND_SIGNAL(victim, COMSIG_LIVING_SHOCK_PREVENTED, power_source, source, siemens_coeff, dist_check)
		return FALSE //to avoid spamming with insulated gloves on

	var/list/powernet_info = get_powernet_info_from_source(power_source)
	if (!powernet_info)
		return FALSE

	var/datum/powernet/PN = powernet_info["powernet"]
	var/obj/item/stock_parts/power_store/cell = powernet_info["cell"]

	var/PN_damage = 0
	var/cell_damage = 0
	if (PN)
		PN_damage = PN.get_electrocute_damage()
	if (cell)
		cell_damage = cell.get_electrocute_damage()
	var/shock_damage = 0
	if (PN_damage >= cell_damage)
		power_source = PN
		shock_damage = PN_damage
	else
		power_source = cell
		shock_damage = cell_damage
	var/drained_hp = victim.electrocute_act(shock_damage, source, siemens_coeff) //zzzzzzap!
	log_combat(source, victim, "electrocuted")

	var/drained_energy = drained_hp*20

	if (isarea(power_source))
		var/area/source_area = power_source
		source_area.apc?.terminal?.use_energy(drained_energy)
	else if (istype(power_source, /datum/powernet))
		PN.delayedload += (min(drained_energy, max(PN.newavail - PN.delayedload, 0)))
	else if (istype(power_source, /obj/item/stock_parts/power_store))
		cell.use(drained_energy)
	return drained_energy

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////

// return a cable able connect to machinery on layer if there's one on the turf, null if there isn't one
/turf/proc/get_cable_node(cable_layer = CABLE_LAYER_ALL)
	if(!can_have_cabling())
		return null
	for(var/obj/structure/cable/C in src)
		if(C.cable_layer & cable_layer)
			C.update_appearance() // I hate this. it's here because update_icon_state SCANS nearby turfs for objects to connect to. Wastes cpu time
			return C
	return null
