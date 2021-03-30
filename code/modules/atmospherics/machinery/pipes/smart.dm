/obj/machinery/atmospherics/pipe/smart
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_ICON_STATE | VIS_INHERIT_DIR | VIS_INHERIT_ID

	device_type = QUATERNARY
	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"
	var/connection_num = 0
	var/list/connections
	var/static/list/mutable_appearance/center_cache = list()
	var/mutable_appearance/pipe_appearance

/obj/machinery/atmospherics/pipe/smart/New()
	icon_state = ""
	connections = new/list(dir2text(NORTH) = FALSE, dir2text(SOUTH) = FALSE , dir2text(EAST) = FALSE , dir2text(WEST) = FALSE)
	return ..()

/obj/machinery/atmospherics/pipe/smart/SetInitDirections()
	initialize_directions = ALL_CARDINALS

/obj/machinery/atmospherics/pipe/smart/proc/check_connections()
	var/mutable_appearance/center
	connection_num = 0
	connections = list(dir2text(NORTH) = FALSE, dir2text(SOUTH) = FALSE , dir2text(EAST) = FALSE , dir2text(WEST) = FALSE)
	var/list/valid_connectors = typecacheof(/obj/machinery/atmospherics)
	for(var/direction in connections)
		var/turf/T = get_step(src,  text2dir(direction))
		if(!T)
			return
		for(var/machine_type in T.contents)
			if(!is_type_in_typecache(machine_type,valid_connectors))
				continue
			var/obj/machinery/atmospherics/machine = machine_type

			if(connection_check(machine, piping_layer))
				connections[direction] = TRUE
				connection_num++
				break

	switch(connection_num)
		if(0)
			center = mutable_appearance('icons/obj/atmospherics/pipes/simple.dmi', "pipe00-3")
		if(1)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue
				center = mutable_appearance('icons/obj/atmospherics/pipes/simple.dmi', "pipe00-3")
				src.dir = text2dir(direction)
		if(2)
			for(var/direction in connections)
				if(connections[direction] != TRUE)
					continue
				//Detects straight pipes connected from east to west , north to south etc.
				if(connections[dir2text(angle2dir(dir2angle(text2dir(direction))+180))] == TRUE)
					center = mutable_appearance('icons/obj/atmospherics/pipes/simple.dmi', "pipe00-3")
					src.dir = text2dir(direction)
					break

				for(var/direction2 in connections - direction)
					if(connections[direction2] != TRUE)
						continue
					center = mutable_appearance('icons/obj/atmospherics/pipes/simple.dmi', "pipe00-3")
					src.dir = text2dir(dir2text(text2dir(direction)+text2dir(direction2)))
		if(3)
			for(var/direction in connections)
				if(connections[direction] == FALSE)
					center = mutable_appearance('icons/obj/atmospherics/pipes/manifold.dmi', "manifold_center")
					src.dir = text2dir(direction)
		if(4)
			center = mutable_appearance('icons/obj/atmospherics/pipes/manifold.dmi', "manifold4w_center")
			src.dir = dir2text(NORTH)
	return center

/obj/machinery/atmospherics/pipe/smart/update_overlays()
	. = ..()
	var/mutable_appearance/center = center_cache["[piping_layer]"]
	center = check_connections()
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	center_cache["[piping_layer]"] = center
	pipe_appearance = center
	. +=center

	update_layer()

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			var/image/pipe = getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i]))
			pipe.layer = layer + 0.01
			. += pipe
