GLOBAL_LIST_INIT(atmos_components, typecacheof(list(/obj/machinery/atmospherics)))
//Smart pipes... or are they?
/obj/machinery/atmospherics/pipe/smart
	icon = 'icons/obj/pipes_n_cables/simple.dmi'
	icon_state = "pipe11-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	device_type = QUATERNARY
	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"
	has_cap_visuals = TRUE

	///Current active connections
	var/connections = NONE

/obj/machinery/atmospherics/pipe/smart/update_pipe_icon()
	icon = 'icons/obj/pipes_n_cables/!pipes_bitmask.dmi'

	//find all directions this pipe is connected with other nodes
	connections = NONE
	var/new_volume = 0
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/connected_dir = get_dir(src, node)
		connections |= connected_dir
		new_volume += UNARY_PIPE_VOLUME
	new_volume = max(new_volume, UNARY_PIPE_VOLUME * 2)

	if(parent && parent.air && parent.air.volume)
		parent.air.volume = parent.air.volume + new_volume - volume // Update associate pipenet with new volume.
	volume = new_volume

	//set the correct direction for this node in case of binary directions
	switch(connections)
		if(EAST | WEST)
			dir = EAST
		if(SOUTH | NORTH)
			dir = SOUTH
		else
			dir = connections

	// Smart pipe icons differ from classic pipe icons in that we stop adding
	// short pipe directions as soon as we find a valid sprite, rather than
	// adding in all connectable directions.
	// This prevents a lot of visual clutter, though it does make it harder to
	// notice completely disconnected pipes.
	var/bitfield = CARDINAL_TO_FULLPIPES(connections)
	if(ISSTUB(connections))
		var/bits_to_add = NONE
		if(connections != NONE)
			bits_to_add |= REVERSE_DIR(connections) & initialize_directions

		var/candidate = 0
		var/shift = 0

		// Note that candidates "should" never reach 0, as stub pipes are not allowed and break things
		while (ISSTUB(connections | bits_to_add) && (initialize_directions >> shift)!=0)
			//lets see if this direction is eligable to be added
			candidate = initialize_directions & (1 << shift)
			//we dont want to add connections again else it creates wrong values & its also redundant[bitfield was already initialized with connections so we shoudnt append it again]
			if(!(candidate & connections))
				bits_to_add |= candidate
			shift += 1
		bitfield |= CARDINAL_TO_SHORTPIPES(bits_to_add)
	icon_state = "[bitfield]_[piping_layer]"

/obj/machinery/atmospherics/pipe/smart/set_init_directions(init_dir)
	if(init_dir)
		initialize_directions = init_dir
		var/j = 1
		for (var/i in 1 to 4)
			if (init_dir & j)
				volume += UNARY_PIPE_VOLUME
			j << 1
		volume = max(volume, UNARY_PIPE_VOLUME * 2) // Minimum 2 directions
	else
		initialize_directions = ALL_CARDINALS
		volume = UNARY_PIPE_VOLUME * 4

//mapping helpers
/obj/machinery/atmospherics/pipe/smart/simple
	icon = 'icons/obj/pipes_n_cables/simple.dmi'
	icon_state = "pipe11-3"

/obj/machinery/atmospherics/pipe/smart/manifold
	icon = 'icons/obj/pipes_n_cables/manifold.dmi'
	icon_state = "manifold-3"

/obj/machinery/atmospherics/pipe/smart/manifold4w
	icon = 'icons/obj/pipes_n_cables/manifold.dmi'
	icon_state = "manifold4w-3"
