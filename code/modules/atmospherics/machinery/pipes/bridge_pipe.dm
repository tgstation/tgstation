/obj/machinery/atmospherics/pipe/bridge_pipe
	icon = 'icons/obj/pipes_n_cables/bridge_pipe.dmi'
	icon_state = "bridge_center"

	name = "bridge pipe"
	desc = "A one meter section of regular pipe used to connect pipenets over pipes."

	dir = SOUTH
	initialize_directions = NORTH | SOUTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE | PIPING_BRIDGE
	device_type = BINARY

	construction_type = /obj/item/pipe/binary
	pipe_state = "bridge_center"

	has_gas_visuals = FALSE

/obj/machinery/atmospherics/pipe/bridge_pipe/set_init_directions()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/bridge_pipe/update_overlays()
	. = ..()
	var/mutable_appearance/center = mutable_appearance('icons/obj/pipes_n_cables/bridge_pipe.dmi', "bridge_center")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	. += center

	layer = HIGH_PIPE_LAYER //to stay above all sorts of pipes
