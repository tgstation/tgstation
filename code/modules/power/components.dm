/**
 * A desperate attempt at component-izing power transmission shit.
 *
 * The idea being that objects that aren't /obj/machinery/power can hook into power systems.
 */

/datum/power_connection
	var/obj/parent=null

	//For powernet rebuilding
	var/channel = EQUIP // EQUIP, ENVIRON or LIGHT.
	var/build_status = 0 //1 means it needs rebuilding during the next tick or on usage
	var/connected = 0
	var/datum/powernet/powernet = null

	var/machine_flags = 0 // Emulate machinery flags.
	var/inMachineList = 0

	var/parentMoveKey = null
	var/turf/turf = null // Updated in addToTurf()/removeFromTurf()

/datum/power_connection/New(var/obj/parent)
	src.parent = parent
	power_machines |= src

	// Used for updating turf power_connection lists when moved.
	parentMoveKey = parent.on_moved.Add(src, "parent_moved")
	addToTurf()

/datum/power_connection/Destroy()
	disconnect()
	power_machines -= parent

	// Remember to tell our turf that we're gone.
	removeFromTurf()
	parent.on_moved.Remove(parentMoveKey)

	..()

// CALLBACK from parent.on_moved.
// This should never happen, except when Singuloth is doing its shenanigans, as rebuilding
//  powernets is extremely slow.
/datum/power_connection/proc/parent_moved(var/list/args)
	removeFromTurf() // Removes old ref
	addToTurf() // Adds new one

// Powernets need to know what power equipment is on a turf when adding a cable to it.
// So, we tell the turf to tell the powernet about us, since we don't have a loc.
/datum/power_connection/proc/addToTurf()
	// Get AND REMEMBER the turf that's going to hold the ref.
	turf = get_turf(parent)
	if(!turf)
		// We've been sucked into a black hole, god help us
		return
	if(turf.power_connections == null)
		turf.power_connections = list(src)
	else
		turf.power_connections += src

/datum/power_connection/proc/removeFromTurf()
	if(!turf)
		return
	// We don't grab the current turf here because we're removing the reference from the turf that has it.
	turf.power_connections -= src

	// Clean up after ourselves.
	if(turf.power_connections.len == 0)
		turf.power_connections = null

	// Tell the rest of the code that we're turfless.
	// EVEN THOUGH THE REST OF THE CODE SHOULDN'T CARE.
	turf=null

// Called when powernet reports excess watts.
/datum/power_connection/proc/excess(var/netexcess)
	return

/datum/power_connection/proc/process()
	return // auto_use_power() :^)

// common helper procs for all power machines
/datum/power_connection/proc/add_avail(var/amount)
	if(get_powernet())
		powernet.newavail += amount

/datum/power_connection/proc/add_load(var/amount)
	if(get_powernet())
		powernet.load += amount

/datum/power_connection/proc/get_surplus()
	if(get_powernet())
		return powernet.avail-powernet.load
	else
		return 0

/datum/power_connection/proc/get_avail()
	if(get_powernet())
		return powernet.avail
	else
		return 0

/datum/power_connection/proc/get_powernet()
	check_rebuild()
	return powernet

/datum/power_connection/proc/check_rebuild()
	if(!build_status)
		return 0
	for(var/obj/structure/cable/C in parent.loc)
		if(C.check_rebuild())
			return 1

/datum/power_connection/proc/getPowernetNodes()
	if(!get_powernet())
		return list()
	return powernet.nodes


// returns true if the area has power on given channel (or doesn't require power)
// defaults to power_channel
/datum/power_connection/proc/powered(chan = channel)
	if(!parent || !parent.loc)
		return 0

	// If you're using a consumer, you need power.
	//if(!use_power)
	//	return 1

	if(isnull(parent.areaMaster) || !parent.areaMaster)
		return 0						// if not, then not powered.

	if((machine_flags & FIXED2WORK) && !parent.anchored)
		return 0

	return parent.areaMaster.powered(chan)		// return power status of the area.

// increment the power usage stats for an area
// defaults to power_channel
/datum/power_connection/proc/use_power(amount, chan = channel)
	if(isnull(parent.areaMaster) || !parent.areaMaster)
		return 0						// if not, then not powered.

	if(!powered(chan)) //no point in trying if we don't have power
		return 0

	parent.areaMaster.use_power(amount, chan)

// called whenever the power settings of the containing area change
// by default, check equipment channel & set flag
// can override if needed
/datum/power_connection/proc/power_change()
	//parent.power_change()
	return

// connect the machine to a powernet if a node cable is present on the turf
/datum/power_connection/proc/connect()
	var/turf/T = get_turf(parent)

	var/obj/structure/cable/C = T.get_cable_node() // check if we have a node cable on the machine turf, the first found is picked

	if(!C || !C.get_powernet())
		return 0

	C.powernet.add_component(src)
	connected=1
	return 1

// remove and disconnect the machine from its current powernet
/datum/power_connection/proc/disconnect()
	connected=0
	if(!get_powernet())
		build_status = 0
		return 0

	powernet.remove_component(src)
	return 1

// returns all the cables WITHOUT a powernet in neighbors turfs,
// pointing towards the turf the machine is located at
/datum/power_connection/proc/get_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(parent.loc, card)
		cdir = get_dir(T, parent.loc)

		for(var/obj/structure/cable/C in T)
			if(C.get_powernet())
				continue

			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the cables in neighbors turfs,
// pointing towards the turf the machine is located at
/datum/power_connection/proc/get_marked_connections()
	. = list()

	var/cdir
	var/turf/T

	for(var/card in cardinal)
		T = get_step(parent.loc, card)
		cdir = get_dir(T, parent.loc)

		for(var/obj/structure/cable/C in T)
			if(C.d1 == cdir || C.d2 == cdir)
				. += C

// returns all the NODES (O-X) cables WITHOUT a powernet in the turf the machine is located at
/datum/power_connection/proc/get_indirect_connections()
	. = list()

	for(var/obj/structure/cable/C in parent.loc)
		if(C.get_powernet())
			continue

		if(C.d1 == 0) // the cable is a node cable
			. += C

////////////////////////////////////////////////
// Misc.
///////////////////////////////////////////////

/datum/power_connection/proc/addStaticPower(value, powerchannel)
	if(!parent.areaMaster)
		return
	parent.areaMaster.addStaticPower(value, powerchannel)

/datum/power_connection/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

///////////////////////////
// POWER CONSUMERS
///////////////////////////

/datum/power_connection/consumer
	var/enabled=0

	var/use=0 // 1=idle, 2=active
	var/idle_usage=1 // watts
	var/active_usage=2

	var/event/power_changed = null

/datum/power_connection/consumer/New(var/loc,var/obj/parent)
	..(loc,parent)
	power_changed = new ("owner"=src)

/datum/power_connection/consumer/power_change()
	INVOKE_EVENT(power_changed,list("consumer"=src))

/datum/power_connection/consumer/process()
	if(use)
		auto_use_power()

/datum/power_connection/consumer/proc/auto_use_power()
	if(!powered(channel))
		return 0

	switch (use)
		if (1)
			use_power(idle_usage, channel)
		if (2)
			use_power(active_usage, channel)

	return 1

/datum/power_connection/consumer/proc/set_enabled(var/value)
	enabled=value
	power_change()


//////////////////////
/// TERMINAL RECEIVER
//////////////////////
/datum/power_connection/consumer/terminal
	var/obj/machinery/power/terminal/terminal=null

/datum/power_connection/consumer/terminal/use_power(var/watts, var/_channel_NOT_USED)
	add_load(watts)

/datum/power_connection/consumer/terminal/connect()
	..()

	for(var/d in cardinal)
		var/turf/T = get_step(parent, d)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(d, 180))
				terminal = term
				break
		if(terminal)
			break
	if(terminal)
		terminal.master = parent
		//parent.update_icon()

/datum/power_connection/consumer/terminal/Destroy()
	if (terminal)
		terminal.master = null
		terminal = null

	..()
////////////////////////////////
/// DIRECT CONNECTION RECEIVER
////////////////////////////////
/datum/power_connection/consumer/cable
	var/obj/structure/cable/cable=null

/datum/power_connection/consumer/cable/use_power(var/watts, var/_channel_NOT_USED)
	add_load(watts)

// connect the machine to a powernet if a node cable is present on the turf
/datum/power_connection/consumer/cable/connect()
	// OVERRIDES!
	var/turf/T = get_turf(parent)

	cable = T.get_cable_node() // check if we have a node cable on the machine turf, the first found is picked

	if(!cable || !cable.get_powernet())
		return 0

	cable.powernet.add_component(src)
	connected=1
	return 1


// returns true if the area has power on given channel (or doesn't require power)
// defaults to power_channel
/datum/power_connection/consumer/cable/powered(chan = channel)
	if(!parent || !parent.loc)
		return 0

	// If you're using a consumer, you need power.
	//if(!use_power)
	//	return 1

	if(isnull(powernet) || !powernet || !cable)
		return 0						// if not, then not powered.

	if((machine_flags & FIXED2WORK) && !parent.anchored)
		return 0

	return 1 // We have a powernet and a cable, so we're okay.