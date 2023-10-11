/obj/machinery/atmospherics/pipe/heat_exchanging
	var/minimum_temperature_difference = 20
	var/thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT
	color = "#404040"
	buckle_lying = NO_BUCKLE_LYING
	var/icon_temperature = T20C //stop small changes in temperature causing icon refresh
	resistance_flags = LAVA_PROOF | FIRE_PROOF

	hide = FALSE

	has_gas_visuals = FALSE

/obj/machinery/atmospherics/pipe/heat_exchanging/Initialize(mapload)
	. = ..()

	add_atom_colour("#404040", FIXED_COLOUR_PRIORITY)

/obj/machinery/atmospherics/pipe/heat_exchanging/is_connectable(obj/machinery/atmospherics/pipe/heat_exchanging/target, given_layer, HE_type_check = TRUE)
	if(istype(target, /obj/machinery/atmospherics/pipe/heat_exchanging) != HE_type_check)
		return FALSE
	. = ..()

/obj/machinery/atmospherics/pipe/heat_exchanging/process_atmos()
	var/environment_temperature = 0
	var/datum/gas_mixture/pipe_air = return_air()

	var/turf/local_turf = loc
	if(istype(local_turf))
		if(islava(local_turf))
			environment_temperature = 5000 //Yuck
		else if(local_turf.blocks_air)
			environment_temperature = local_turf.temperature
		else
			var/turf/open/open_local = local_turf
			environment_temperature = open_local.GetTemperature()
	else
		environment_temperature = local_turf.temperature
	if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
		parent.temperature_interact(local_turf, volume, thermal_conductivity)


	//heatup/cooldown any mobs buckled to ourselves based on our temperature
	if(has_buckled_mobs())
		var/hc = pipe_air.heat_capacity()
		var/mob/living/heat_source = buckled_mobs[1]
		//Best guess-estimate of the total bodytemperature of all the mobs, since they share the same environment it's ~ok~ to guess like this
		var/avg_temp = (pipe_air.temperature * hc + (heat_source.bodytemperature * buckled_mobs.len) * 3500) / (hc + (buckled_mobs ? buckled_mobs.len * 3500 : 0))
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.bodytemperature = avg_temp
		pipe_air.temperature = avg_temp

/obj/machinery/atmospherics/pipe/heat_exchanging/process(seconds_per_tick)
	if(!parent)
		return //machines subsystem fires before atmos is initialized so this prevents race condition runtimes

	var/datum/gas_mixture/pipe_air = return_air()

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

	//burn any mobs buckled based on temperature
	if(!has_buckled_mobs())
		return
	var/heat_limit = 1000
	if(pipe_air.temperature > heat_limit + 1)
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.apply_damage(seconds_per_tick * 2 * log(pipe_air.temperature - heat_limit), BURN, BODY_ZONE_CHEST)

/obj/machinery/atmospherics/pipe/heat_exchanging/update_pipe_icon()
	return
