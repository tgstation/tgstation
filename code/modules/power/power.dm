//////////////////////////////
// POWER MACHINERY BASE CLASS
//////////////////////////////

/////////////////////////////
// Definitions
/////////////////////////////

/obj/machinery/power
	name = null
	icon = 'icons/obj/power.dmi'
	anchored = 1.0
	var/datum/powernet/powernet = null
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0

	//For powernet rebuilding
	var/build_status = 0 //1 means it needs rebuilding during the next tick or on usage

	var/obj/machinery/power/terminal/terminal = null //not strictly used on all machines - a placeholder
	var/starting_terminal = 0

/obj/machinery/power/New()
	. = ..()
	machines -= src
	power_machines |= src
	return .

/obj/machinery/power/initialize()
	..()
	if(starting_terminal)
		for(var/d in cardinal)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break
			if(terminal)
				break
		if(terminal)
			terminal.master = src
			update_icon()

/obj/machinery/power/Destroy()
	disconnect_from_network()
	power_machines -= src

	if (terminal)
		terminal.master = null
		terminal = null

	..()

///////////////////////////////
// General procedures
//////////////////////////////

// common helper procs for all power machines
/obj/machinery/power/proc/add_avail(var/amount)
	if(get_powernet())
		powernet.newavail += amount

/obj/machinery/power/proc/add_load(var/amount)
	if(get_powernet())
		powernet.load += amount

/obj/machinery/power/proc/surplus()
	if(get_powernet())
		return powernet.avail-powernet.load
	else
		return 0

/obj/machinery/power/proc/avail()
	if(get_powernet())
		return powernet.avail
	else
		return 0

/obj/machinery/power/proc/load()
	if(get_powernet())
		return powernet.load
	else
		return 0
		
/obj/machinery/power/proc/get_powernet()
	check_rebuild()
	return powernet

/obj/machinery/power/check_rebuild()
	if(!build_status)
		return 0
	for(var/obj/structure/cable/C in src.loc)
		if(C.check_rebuild())
			return 1

/obj/machinery/power/proc/getPowernetNodes()
	if(!get_powernet())
		return list()
	return powernet.nodes

/obj/machinery/power/proc/disconnect_terminal() // machines without a terminal will just return, no harm no fowl.
	return

// returns true if the area has power on given channel (or doesn't require power)
// defaults to power_channel
/obj/machinery/proc/powered(chan = power_channel)
	if(!src.loc)
		return 0

	if(!use_power)
		return 1

	if(isnull(src.areaMaster) || !src.areaMaster)
		return 0						// if not, then not powered.

	if((machine_flags & FIXED2WORK) && !anchored)
		return 0

	return areaMaster.powered(chan)		// return power status of the area.

// increment the power usage stats for an area
// defaults to power_channel
/obj/machinery/proc/use_power(amount, chan = power_channel)
	if(isnull(src.areaMaster) || !src.areaMaster)
		return 0						// if not, then not powered.

	if(!powered(chan)) //no point in trying if we don't have power
		return 0

	src.areaMaster.use_power(amount, chan)

// called whenever the power settings of the containing area change
// by default, check equipment channel & set flag
// can override if needed
/obj/machinery/proc/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER

		if(!use_auto_lights)
			return
		set_light(light_range_on, light_power_on)

	else
		stat |= NOPOWER

		if(!use_auto_lights)
			return
		set_light(0)


// connect the machine to a powernet if a node cable is present on the turf
/obj/machinery/power/proc/connect_to_network()
	var/turf/T = get_turf(src)

	var/obj/structure/cable/C = T.get_cable_node() // check if we have a node cable on the machine turf, the first found is picked

	if(!C || !C.get_powernet())
		return 0

	C.powernet.add_machine(src)
	return 1

// remove and disconnect the machine from its current powernet
/obj/machinery/power/proc/disconnect_from_network()
	if(!get_powernet())
		build_status = 0
		return 0

	powernet.remove_machine(src)
	return 1

///////////////////////////////////////////
// Powernet handling helpers
//////////////////////////////////////////

// returns all the cables WITHOUT a powernet in neighbors turfs,
// pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(loc, card)
		cdir = get_dir(T, loc)

		for(var/obj/structure/cable/C in T)
			if(C.get_powernet())
				continue

			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the cables in neighbors turfs,
// pointing towards the turf the machine is located at
/obj/machinery/power/proc/get_marked_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(loc, card)
		cdir = get_dir(T, loc)

		for(var/obj/structure/cable/C in T)
			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the NODES (O-X) cables WITHOUT a powernet in the turf the machine is located at
/obj/machinery/power/proc/get_indirect_connections()
	. = list()

	for(var/obj/structure/cable/C in loc)
		if(C.get_powernet())
			continue

		if(C.d1 == 0) // the cable is a node cable
			. += C

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////

// return a knot cable (O-X) if one is present in the turf
// null if there's none
/turf/proc/get_cable_node()
	for(var/obj/structure/cable/C in src)
		if(C.d1 == 0)
			return C

/obj/machinery/proc/addStaticPower(value, powerchannel)
	if(!areaMaster)
		return
	areaMaster.addStaticPower(value, powerchannel)
/obj/machinery/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)
