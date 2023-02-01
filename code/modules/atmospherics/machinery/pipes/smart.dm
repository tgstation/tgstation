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
	///Was this pipe created during map load
	var/map_loaded_pipe = FALSE

/obj/machinery/atmospherics/pipe/smart/Initialize(mapload)
	map_loaded_pipe = mapload
	return ..()

///helper function to append all directions into an single bit flag
/obj/machinery/atmospherics/pipe/smart/proc/append_directions(list/spanning_directions)
	var/bit_flag = NONE
	for(var/i in 1 to length(spanning_directions))
		var/spanning_direction = spanning_directions[i]
		if(!spanning_direction)
			continue
		bit_flag |= spanning_direction
	return bit_flag

/obj/machinery/atmospherics/pipe/smart/update_pipe_icon()
	icon = 'icons/obj/atmospherics/pipes/pipes_bitmask.dmi'

	//find all directions this pipe is connected with other nodes
	connections = NONE
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/connected_dir = get_dir(src, node)
		connections |= connected_dir
	//set the correct direction for this node in case of binary directions
	switch(connections)
		if(EAST | WEST)
			dir = EAST
		if(SOUTH | NORTH)
			dir = SOUTH
		else
			dir = connections

	//same as connections but used for spriting
	var/sprite_bits = NONE
	//the directions this pipe stretches out in e.g. T pipe is EAST,WEST & SOUTH, L pipe is NORTH,EAST & so on
	var/list/spanning_directions = get_node_connects()
	/**
	 *For pipes created during mapload we draw the pipes sprite only in directions where its connected to a machine
	 *so for example if an T shaped pipe is connected only in its EAST & WEST directions then only those ends are drawn
	 *but the SOUTH end is not drawn
	 *this will allow mappers to use whatever pipes but the end result has no visual clutter.
	 *This is actually just an bandage for lazy mappers using + pipes all over the place without carying about directions so hopefully when they map pipes correctly we can remove this
	 */
	if(map_loaded_pipe)
		sprite_bits = connections
		/**
		 * if pipe is connected in only one direction[e.g. after disconnecting its neighbour] then to avoid a broken sprite append the reverse direction of its one connected end.
		 * this wont work for L pipes because if one of its ends is broken then the opposite direction of any of its last connected end is invalid
		 * e.g. for an L pipe if the top[NORTH] end is broken the opposite of its one remaining connected end[i.e EAST END] is WEST but thats not an valid direction for this pipe
		 * so we have to again check one last time after this to make sure the pipe isnt broken
		 */
		if(ISSTUB(sprite_bits))
			// & initialize_directions will yield 0 if the reversed direction is not valid
			sprite_bits |= REVERSE_DIR(sprite_bits) & get_init_directions()
			//if its still broken after the above patch then screw it we make the pipe an normal non mapload type and do the usual stuff with player created pipes
			if(ISSTUB(sprite_bits))
				sprite_bits = append_directions(spanning_directions)
	/**
	 *for pipes created by players during the round we draw the pipe in all directions so they
	 *can visually see what ends are free.
	*/
	else
		sprite_bits = append_directions(spanning_directions)

	icon_state = "[sprite_bits]_[piping_layer]"

/obj/machinery/atmospherics/pipe/smart/set_init_directions(init_dir)
	if(init_dir)
		initialize_directions = init_dir
	else
		initialize_directions = ALL_CARDINALS

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
