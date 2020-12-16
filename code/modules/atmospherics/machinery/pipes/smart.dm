/obj/machinery/atmospherics/pipe/smart
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	device_type = QUATERNARY
	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"
	var/mutable_appearance/center
	var/connection_num = 0
	var/list/connections

/obj/machinery/atmospherics/pipe/smart/New()
	icon_state = ""
	center = mutable_appearance(icon, "manifold4w_center")
	connections = new/list(dir2text(NORTH) = FALSE, dir2text(SOUTH) = FALSE , dir2text(EAST) = FALSE , dir2text(WEST) = FALSE)
	return ..()

/obj/machinery/atmospherics/pipe/smart/SetInitDirections()
	initialize_directions = ALL_CARDINALS

/obj/machinery/atmospherics/pipe/smart/proc/check_connections()
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

			if((machine.piping_layer != piping_layer || machine.pipe_color != pipe_color) && !(machine.pipe_flags & PIPING_ALL_COLORS))
				continue

			if(angle2dir(dir2angle(text2dir(direction))+180) & machine.initialize_directions)
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

/obj/machinery/atmospherics/pipe/smart/update_icon()
	cut_overlays()
	check_connections()
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	add_overlay(center)

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			add_overlay( getpipeimage(icon, "pipe-[piping_layer]", get_dir(src, nodes[i])) )

	update_layer()
