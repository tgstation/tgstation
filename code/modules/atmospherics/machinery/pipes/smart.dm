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
	. = ..()
	map_loaded_pipe = mapload

/obj/machinery/atmospherics/pipe/smart/update_pipe_icon()
	icon = 'icons/obj/atmospherics/pipes/pipes_bitmask.dmi'
	connections = NONE

	//the directions this pipe stretches out in e.g. T pipe is EAST,WEST & SOUTH, L pipe is NORTH,EAST & so on
	var/list/spanning_directions = get_node_connects()

	/**
	 *For pipes created during mapload we draw the pipes sprite only in directions where its connected to a machine
	 *so for example if an T shaped pipe is connected only in its EAST & WEST directions then only those ends are drawn
	 *but the SOUTH end is not drawn
	 *this will allow mappers to use whatever pipes but the end result has no visual clutter.
	 */
	if(map_loaded_pipe)
		var/draw_sprite_in_this_direction = FALSE
		for(var/spanning_direction in spanning_directions)
			//find atleast one machine connected in spanning_direction
			draw_sprite_in_this_direction = FALSE
			for(var/i in 1 to device_type)
				if(!nodes[i])
					continue
				var/obj/machinery/atmospherics/node = nodes[i]
				var/target_direction = get_dir(src, node)
				//we found a machine connected in this direction so lets draw the sprite this way
				if(spanning_direction == target_direction)
					draw_sprite_in_this_direction = TRUE
					break
			if(draw_sprite_in_this_direction)
				connections |= spanning_direction
	/**
	 *for pipes created by players during the round we draw the pipe in all directions so they
	 *can visually see what ends are free.
	*/
	else
		for(var/spanning_direction in spanning_directions)
			connections |= spanning_direction
	icon_state = "[connections]_[piping_layer]"

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
