/obj/machinery/atmospherics/components/unary/passive_vent
	icon_state = "passive_vent_map-2"

	name = "passive vent"
	desc = "It is an open vent."

	can_unwrench = TRUE
	hide = TRUE
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

	var/active = FALSE

	var/datum/gas_mixture/external = loc.return_air()
	var/datum/gas_mixture/internal = airs[1]

	//is there a better way to do this in byond i.e. get the keys?
	var/list/gas_list = new()
	for(var/gas_id in internal.gases)
		gas_list += gas_id
	for(var/gas_id in external.gases)
		gas_list += gas_id
	gas_list = uniqueList(gas_list)

	//calculate delta of partial pressure for each gas, and do transfer for each gas individually
	var/internal_pp_coeff = R_IDEAL_GAS_EQUATION * internal.temperature / internal.volume
	var/external_pp_coeff = R_IDEAL_GAS_EQUATION * external.temperature / external.volume
	for(var/gas_id in gas_list)
		internal.assert_gas(gas_id)
		external.assert_gas(gas_id)
		var/internal_pp = internal.gases[gas_id][MOLES] * internal_pp_coeff
		var/external_pp = external.gases[gas_id][MOLES] * external_pp_coeff
		var/delta_pp = abs(internal_pp - external_pp)
		if(delta_pp > 0.5)
			active = TRUE
			//use the volume of the receiving mixture for mole calculation
			//use the temperature of the sending mixture
			if(internal_pp > external_pp)
				var/moles_to_move = (delta_pp * external.volume)/ (internal.temperature * R_IDEAL_GAS_EQUATION)
				external.merge(internal.remove_specific(gas_id, moles_to_move))
			else
				var/moles_to_move = (delta_pp * internal.volume) / (external.temperature * R_IDEAL_GAS_EQUATION)
				internal.merge(external.remove_specific(gas_id, moles_to_move))


	active = internal.temperature_share(external, OPEN_HEAT_TRANSFER_COEFFICIENT) ? TRUE : active

	if(active)
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
