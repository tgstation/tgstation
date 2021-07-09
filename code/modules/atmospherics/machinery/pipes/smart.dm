GLOBAL_LIST_INIT(atmos_components, typecacheof(list(/obj/machinery/atmospherics)))
//Smart pipes... or are they?
/obj/machinery/atmospherics/pipe/smart
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR | VIS_INHERIT_ID

	device_type = QUATERNARY
	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"
	connection_num = 0
	var/list/connections
	var/static/list/mutable_appearance/center_cache = list()
	var/mutable_appearance/pipe_appearance

/* We use New() instead of Initialize() because these values are used in update_icon()
 * in the mapping subsystem init before Initialize() is called in the atoms subsystem init.
 */
/obj/machinery/atmospherics/pipe/smart/Initialize()
	icon_state = ""
	. = ..()

/obj/machinery/atmospherics/pipe/smart/SetInitDirections(init_dir)
	if(init_dir)
		initialize_directions =	init_dir
	else
		initialize_directions = ALL_CARDINALS

/obj/machinery/atmospherics/pipe/smart/proc/check_connections()
	var/mutable_appearance/center
	connection_num = 0
	connections = NONE
	for(var/direction in GLOB.cardinals)
		var/turf/turf = get_step(src, direction)
		if(!turf)
			continue
		for(var/obj/machinery/atmospherics/machine in turf)
			if(connection_check(machine, piping_layer))
				connections |= direction
				connection_num++
				break

	switch(connection_num)
		if(0)
			center = mutable_appearance('icons/obj/atmospherics/pipes/manifold.dmi', "manifold4w_center")
			dir = SOUTH
		if(1)
			center = mutable_appearance('icons/obj/atmospherics/pipes/simple.dmi', "pipe00-3")
			dir = connections
		if(2)
			center = mutable_appearance('icons/obj/atmospherics/pipes/simple.dmi', "pipe00-3")
			dir = check_binary_direction(connections)
		if(3)
			center = mutable_appearance('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_center")
			dir = check_manifold_direction(connections)

		if(4)
			center = mutable_appearance('icons/obj/atmospherics/pipes/manifold.dmi', "manifold4w_center")
			dir = NORTH
	return center

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

/obj/machinery/atmospherics/pipe/smart/update_overlays()
	. = ..()
	var/mutable_appearance/center = center_cache["[piping_layer]"]
	center = check_connections()
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	center_cache["[piping_layer]"] = center
	pipe_appearance = center
	. += center

	update_layer()

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		. += pipe_overlay('icons/obj/atmospherics/pipes/manifold.dmi', "pipe-[piping_layer]", get_dir(src, nodes[i]), set_layer = (layer + 0.01))


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
