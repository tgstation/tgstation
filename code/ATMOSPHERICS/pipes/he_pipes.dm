////////////
//HE Pipes
////////////

/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/obj/atmospherics/pipes/heat.dmi'
	icon_state = "intact"
	level = 2
	var/initialize_directions_he
	var/minimum_temperature_difference = 20
	var/thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT
	color = "#404040"
	buckle_lying = 1
	var/icon_temperature = T20C //stop small changes in temperature causing icon refresh

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/New()
	..()
	color = "#404040"

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/SetInitDirections()
	switch(dir)
		if(SOUTH)
			initialize_directions_he = SOUTH|NORTH
		if(NORTH)
			initialize_directions_he = SOUTH|NORTH
		if(EAST)
			initialize_directions_he = EAST|WEST
		if(WEST)
			initialize_directions_he = WEST|EAST
		if(NORTHEAST)
			initialize_directions_he = NORTH|EAST
		if(NORTHWEST)
			initialize_directions_he = NORTH|WEST
		if(SOUTHEAST)
			initialize_directions_he = SOUTH|EAST
		if(SOUTHWEST)
			initialize_directions_he = SOUTH|WEST

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/atmosinit()
	normalize_dir()
	var/N = 2
	for(var/D in cardinal)
		if(D & initialize_directions_he)
			N--
			for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src, D))
				if(target.initialize_directions_he & get_dir(target,src))
					if(!node1 && N == 1)
						node1 = target
						break
					if(!node2 && N == 0)
						node2 = target
						break
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process_atmos()
	var/environment_temperature = 0
	var/datum/gas_mixture/pipe_air = return_air()

	if(istype(loc, /turf/simulated))
		if(loc:blocks_air)
			environment_temperature = loc:temperature
		else
			var/datum/gas_mixture/environment = loc.return_air()
			environment_temperature = environment.temperature
	else
		environment_temperature = loc:temperature

	if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
		parent.temperature_interact(loc, volume, thermal_conductivity)


	//heatup/cooldown any mobs buckled to ourselves based on our temperature
	if(buckled_mob)
		var/hc = pipe_air.heat_capacity()
		var/avg_temp = (pipe_air.temperature * hc + buckled_mob.bodytemperature * 3500) / (hc + 3500)
		pipe_air.temperature = avg_temp
		buckled_mob.bodytemperature = avg_temp

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process()
	var/datum/gas_mixture/pipe_air = return_air()
	//Burn any mobs buckled to ourselves based on our temperature
	if(buckled_mob)
		var/heat_limit = 1000
		if(pipe_air.temperature > heat_limit + 1)
			buckled_mob.apply_damage(4 * log(pipe_air.temperature - heat_limit), BURN, "chest")

	//Heat causes pipe to glow
	if(pipe_air.temperature && (icon_temperature > 500 || pipe_air.temperature > 500)) //glow starts at 500K
		if(abs(pipe_air.temperature - icon_temperature) > 10)
			icon_temperature = pipe_air.temperature

			var/h_r = heat2colour_r(icon_temperature)
			var/h_g = heat2colour_g(icon_temperature)
			var/h_b = heat2colour_b(icon_temperature)

			if(icon_temperature < 2000)//scale glow until 2000K
				var/scale = (icon_temperature - 500) / 1500
				h_r = 64 + (h_r - 64) * scale
				h_g = 64 + (h_g - 64) * scale
				h_b = 64 + (h_b - 64) * scale

			animate(src, color = rgb(h_r, h_g, h_b), time = 20, easing = SINE_EASING)

////////////////
//HE Junctions
////////////////
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/obj/atmospherics/pipes/junction.dmi'
	icon_state = "intact"
	level = 2
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/SetInitDirections()
	switch(dir)
		if(SOUTH)
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if(NORTH)
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if(EAST)
			initialize_directions = WEST
			initialize_directions_he = EAST
		if(WEST)
			initialize_directions = EAST
			initialize_directions_he = WEST

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/update_icon()
	if(node1&&node2)
		icon_state = "intact"
	else
		var/have_node1 = node1?1:0
		var/have_node2 = node2?1:0
		icon_state = "exposed[have_node1][have_node2]"

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/atmosinit()
	for(var/obj/machinery/atmospherics/target in get_step(src,initialize_directions))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,initialize_directions_he))
		if(target.initialize_directions_he & get_dir(target,src))
			node2 = target
			break
	update_icon()
	..()