// Simple Pipe
// The regular pipe you see everywhere, including bent ones.

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	device_type = BINARY

	construction_type = /obj/item/pipe/binary/bendable
	pipe_state = "simple"

	var/max_pressure = 35000
	var/dangerous_pressure = 25000
	var/burst_type = /obj/machinery/atmospherics/components/unary/burstpipe

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(ISDIAGONALDIR(dir))
		initialize_directions = dir
		return
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/simple/update_icon()
	icon_state = "pipe[nodes[1] ? "1" : "0"][nodes[2] ? "1" : "0"]-[piping_layer]"
	update_layer()

/obj/machinery/atmospherics/pipe/simple/process()
	if(!parent)
		return //machines subsystem fires before atmos is initialized so this prevents race condition runtimes
	check_pressure()

/obj/machinery/atmospherics/pipe/simple/proc/check_pressure()
	var/datum/gas_mixture/int_air = return_air()
	var/internal_pressure = int_air.return_pressure()
	if(int_air.total_moles() < 50)
		return
	if(internal_pressure > max_pressure && prob(1))
		burst()
	if(internal_pressure > dangerous_pressure && prob(1))
		warn()

/obj/machinery/atmospherics/pipe/simple/proc/warn()
	message_admins("Pipe hiss in area [ADMIN_JMP(src)]")

/obj/machinery/atmospherics/pipe/simple/proc/burst()
	message_admins("Pipe burst in area [ADMIN_JMP(src)]")
	investigate_log("Pipe burst in area", INVESTIGATE_ATMOS)
	for(var/i in 1 to device_type)
		nullifyNode(i)

	for(var/direction in GLOB.cardinals)
		var/found
		if(initialize_directions & direction)
			found = findConnecting(direction)
		if(!found)
			continue

		new burst_type(loc, direction, piping_layer)

	qdel(src)
