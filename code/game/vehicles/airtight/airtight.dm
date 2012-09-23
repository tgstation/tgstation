
/obj/vehicle/airtight
	//inner atmos
	var/use_internal_tank = 0
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/portables_connector/connected_port = null

	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin


/obj/vehicle/airtight/New()
	..()
	src.add_airtank()
	src.add_cabin()
	src.add_airtight_iterators()




//######################################### Helpers for airtight vehicles #########################################

/obj/vehicle/airtight/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/vehicle/airtight/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/vehicle/airtight/proc/add_airtight_iterators()
	pr_int_temp_processor = new /datum/global_iterator/vehicle_preserve_temp(list(src))
	pr_give_air = new /datum/global_iterator/vehicle_tank_give_air(list(src))


//######################################### Specific datums for airtight vehicles #################################


/datum/global_iterator/vehicle_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium
	delay = 20

	process(var/obj/vehicle/airtight/V)
		if(V.cabin_air && V.cabin_air.return_volume() > 0)
			var/delta = V.cabin_air.temperature - T20C
			V.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
		return


/datum/global_iterator/vehicle_tank_give_air
	delay = 15

	process(var/obj/vehicle/airtight/V)
		if(V.internal_tank)
			var/datum/gas_mixture/tank_air = V.internal_tank.return_air()
			var/datum/gas_mixture/cabin_air = V.cabin_air

			var/release_pressure = V.internal_tank_valve
			var/cabin_pressure = cabin_air.return_pressure()
			var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
			var/transfer_moles = 0
			if(pressure_delta > 0) //cabin pressure lower than release pressure
				if(tank_air.return_temperature() > 0)
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					cabin_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = V.get_turf_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						del(removed)
		else
			return stop()
		return


//######################################### Atmospherics for vehicles #############################################


/obj/vehicle/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/vehicle/airtight/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/vehicle/airtight/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/vehicle/airtight/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return


/obj/vehicle/airtight/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()
	return

/obj/vehicle/airtight/proc/connect(obj/machinery/atmospherics/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != src.loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src

	//Actually enforce the air sharing
	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network && !(internal_tank.return_air() in network.gases))
		network.gases += internal_tank.return_air()
		network.update = 1
	log_message("Vehicle airtank connected to external port.")
	return 1

/obj/vehicle/airtight/proc/disconnect()
	if(!connected_port)
		return 0

	var/datum/pipe_network/network = connected_port.return_network(src)
	if(network)
		network.gases -= internal_tank.return_air()

	connected_port.connected_device = null
	connected_port = null
	src.log_message("Vehicle airtank disconnected from external port.")
	return 1