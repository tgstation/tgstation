/obj/machinery/atmospherics/pipe/heat_exchanging/
	icon = 'icons/obj/atmospherics/pipes/heat.dmi'
	level = 2
	var/initialize_directions_he
	var/minimum_temperature_difference = 20
	var/thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT
	color = "#404040"
	buckle_lying = 1
	var/icon_temperature = T20C //stop small changes in temperature causing icon refresh

/obj/machinery/atmospherics/pipe/heat_exchanging/New()
	..()
	color = "#404040"

/obj/machinery/atmospherics/pipe/heat_exchanging/can_be_node(obj/machinery/atmospherics/pipe/heat_exchanging/target)
	if(!istype(target))
		return 0
	if(target.initialize_directions_he & get_dir(target,src))
		return 1

/obj/machinery/atmospherics/pipe/heat_exchanging/hide()
	return

/obj/machinery/atmospherics/pipe/heat_exchanging/GetInitDirections()
	return ..() | initialize_directions_he

/obj/machinery/atmospherics/pipe/heat_exchanging/process_atmos()
	var/environment_temperature = 0
	var/datum/gas_mixture/pipe_air = return_air()

	var/turf/simulated/T = loc
	if(istype(T))
		if(T.blocks_air)
			environment_temperature = T.temperature
		else
			var/datum/gas_mixture/environment = T.return_air()
			environment_temperature = environment.temperature
	else
		environment_temperature = T.temperature

	if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
		parent.temperature_interact(T, volume, thermal_conductivity)


	//heatup/cooldown any mobs buckled to ourselves based on our temperature
	if(buckled_mob)
		var/hc = pipe_air.heat_capacity()
		var/avg_temp = (pipe_air.temperature * hc + buckled_mob.bodytemperature * 3500) / (hc + 3500)
		pipe_air.temperature = avg_temp
		buckled_mob.bodytemperature = avg_temp

/obj/machinery/atmospherics/pipe/heat_exchanging/process()
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