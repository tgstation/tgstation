/obj/machinery/atmospherics/components/unary/passive_vent
	icon_state = "passive_vent_map-2"

	name = "passive vent"
	desc = "It is an open vent."
	can_unwrench = TRUE

	level = 1
	layer = GAS_SCRUBBER_LAYER

	pipe_state = "pvent"

/obj/machinery/atmospherics/components/unary/passive_vent/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = getpipeimage(icon, "vent_cap", initialize_directions, piping_layer = piping_layer)
		add_overlay(cap)
	icon_state = "passive_vent"

/obj/machinery/atmospherics/components/unary/passive_vent/process_atmos()
	..()

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()
	var/pressure_delta = abs(environment_pressure - airs[1].return_pressure())

	if((environment.temperature || airs[1].temperature) && pressure_delta > 0.5)
		if(environment_pressure < airs[1].return_pressure())
			var/air_temperature = (environment.temperature > 0) ? environment.temperature : airs[1].temperature
			var/transfer_moles = (pressure_delta * environment.volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = airs[1].remove(transfer_moles)
			loc.assume_air(removed)
			air_update_turf()
		else
			var/air_temperature = (airs[1].temperature > 0) ? airs[1].temperature : environment.temperature
			var/output_volume = airs[1].volume
			var/transfer_moles = (pressure_delta * output_volume) / (air_temperature * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, environment.total_moles()*airs[1].volume/environment.volume)
			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			if(isnull(removed))
				return
			airs[1].merge(removed)
			air_update_turf()
	update_parents()

/obj/machinery/atmospherics/components/unary/passive_vent/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/components/unary/passive_vent/layer1
	piping_layer = 1
	icon_state = "passive_vent_map-1"

/obj/machinery/atmospherics/components/unary/passive_vent/layer3
	piping_layer = 3
	icon_state = "passive_vent_map-3"
