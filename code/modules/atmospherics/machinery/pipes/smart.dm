GLOBAL_LIST_INIT(atmos_components, typecacheof(list(/obj/machinery/atmospherics)))
//Smart pipes... or are they?
/obj/machinery/atmospherics/pipe/smart
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	device_type = QUATERNARY
	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"
	///Current active connections
	var/connections = NONE

/obj/machinery/atmospherics/pipe/smart/update_pipe_icon()
	icon = 'icons/obj/atmospherics/pipes/pipes_bitmask.dmi'
	connections = NONE

	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/connected_dir = get_dir(src, node)
		connections |= connected_dir
	var/bitfield = CARDINAL_TO_FULLPIPES(connections)
	dir = check_binary_direction(connections)

	// If we dont have enough bits to make a proper sprite, add some shortpipe bits

	// Smart pipe icons differ from classic pipe icons in that we stop adding
	// short pipe directions as soon as we find a valid sprite, rather than
	// adding in all connectable directions.
	// This prevents a lot of visual clutter, though it does make it harder to
	// notice completely disconnected pipes.
	if(ISSTUB(connections))
		var/bits_to_add = NONE
		if(connections != NONE)
			bits_to_add |= REVERSE_DIR(connections) & initialize_directions
		var/candidates = initialize_directions
		var/shift = 0
		// Note that candidates "should" never reach 0, as stub pipes are not allowed and break things
		while (ISSTUB(connections | bits_to_add) && (candidates >> shift) != 0)
			bits_to_add |= candidates & (1 << shift)
			shift += 1
		bitfield |= CARDINAL_TO_SHORTPIPES(bits_to_add)

	icon_state = "[bitfield]_[piping_layer]"

/obj/machinery/atmospherics/pipe/smart/set_init_directions(init_dir)
	if(init_dir)
		initialize_directions = init_dir
	else
		initialize_directions = ALL_CARDINALS

/obj/machinery/atmospherics/pipe/smart/proc/check_binary_direction(direction)
	switch(direction)
		if(EAST|WEST)
			return EAST
		if(SOUTH|NORTH)
			return SOUTH
		else
			return direction

/obj/machinery/atmospherics/pipe/smart/proc/check_manifold_direction(direction)
	switch(direction)
		if(NORTH|SOUTH|EAST)
			return WEST
		if(NORTH|SOUTH|WEST)
			return EAST
		if(NORTH|WEST|EAST)
			return SOUTH
		if(SOUTH|WEST|EAST)
			return NORTH
		else
			return null

//mapping helpers
/obj/machinery/atmospherics/pipe/smart/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

/obj/machinery/atmospherics/pipe/smart/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-3"

/obj/machinery/atmospherics/pipe/smart/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"
