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

	max_pressure = 35000
	var/mutable_appearance/reinforced

/obj/machinery/atmospherics/pipe/simple/New()
	. = ..()
	reinforced = mutable_appearance(icon, "reinforced")

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


/obj/machinery/atmospherics/pipe/simple/reinforced
	name = "reinforced pipe"
	desc = "A one meter section of reinforced pipe."
	can_burst = FALSE

/obj/machinery/atmospherics/pipe/simple/reinforced/update_icon()
	. = ..()
	cut_overlays()
	if(!reinforced)
		reinforced = mutable_appearance(icon, "reinforced")
	PIPING_LAYER_SHIFT(reinforced, piping_layer)
	add_overlay(reinforced)

