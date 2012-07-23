
obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/obj/pipes/heat.dmi'
	icon_state = "intact"
	level = 2
	var/initialize_directions_he

	minimum_temperature_difference = 20
	thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
	New()
		..()
		initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	// BubbleWrap END

	initialize()
		normalize_dir()
		var/node1_dir
		var/node2_dir

		for(var/direction in cardinal)
			if(direction&initialize_directions_he)
				if (!node1_dir)
					node1_dir = direction
				else if (!node2_dir)
					node2_dir = direction

		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node1_dir))
			if(target.initialize_directions_he & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node2_dir))
			if(target.initialize_directions_he & get_dir(target,src))
				node2 = target
				break
		update_icon()
		return


	process()
		if(!parent)
			..()
		else
			var/environment_temperature = 0
			if(istype(loc, /turf/simulated/))
				if(loc:blocks_air)
					environment_temperature = loc:temperature
				else
					var/datum/gas_mixture/environment = loc.return_air()
					environment_temperature = environment.temperature
			else
				environment_temperature = loc:temperature
			var/datum/gas_mixture/pipe_air = return_air()
			if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
				parent.temperature_interact(loc, volume, thermal_conductivity)



obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/obj/pipes/junction.dmi'
	icon_state = "intact"
	level = 2
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	// BubbleWrap
	New()
		.. ()
		switch ( dir )
			if ( SOUTH )
				initialize_directions = NORTH
				initialize_directions_he = SOUTH
			if ( NORTH )
				initialize_directions = SOUTH
				initialize_directions_he = NORTH
			if ( EAST )
				initialize_directions = WEST
				initialize_directions_he = EAST
			if ( WEST )
				initialize_directions = EAST
				initialize_directions_he = WEST
	// BubbleWrap END

	update_icon()
		if(node1&&node2)
			icon_state = "intact"
		else
			var/have_node1 = node1?1:0
			var/have_node2 = node2?1:0
			icon_state = "exposed[have_node1][have_node2]"
		if(!node1&&!node2)
			del(src)

	initialize()
		for(var/obj/machinery/atmospherics/target in get_step(src,initialize_directions))
			if(target.initialize_directions & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,initialize_directions_he))
			if(target.initialize_directions_he & get_dir(target,src))
				node2 = target
				break

		update_icon()
		return
