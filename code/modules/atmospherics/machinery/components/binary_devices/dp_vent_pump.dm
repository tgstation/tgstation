//Acts like a normal vent, but has an input AND output.
///pressure_checks defines for external_pressure_bound and input_pressure_min
#define OUTPUT_MAX 4

/obj/machinery/atmospherics/components/binary/dp_vent_pump
	icon = 'icons/obj/machines/atmospherics/unary_devices.dmi' //We reuse the normal vent icons!
	icon_state = "dpvent_map-3"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	hide = TRUE

	///Indicates that the direction of the pump, if ATMOS_DIRECTION_SIPHONING is siphoning, if ATMOS_DIRECTION_RELEASING is releasing
	var/pump_direction = ATMOS_DIRECTION_RELEASING
	///Set the maximum allowed external pressure
	var/external_pressure_bound = ONE_ATMOSPHERE
	///Set the maximum pressure at the input port
	var/input_pressure_min = 0
	///Set the maximum pressure at the output port
	var/output_pressure_max = 0
	///Set the flag for the pressure bound
	var/pressure_checks = ATMOS_EXTERNAL_BOUND

/obj/machinery/atmospherics/components/binary/dp_vent_pump/update_icon_nopipes()
	cut_overlays()
	if(underfloor_state)
		var/image/cap = get_pipe_image(icon, "dpvent_cap", dir, pipe_color, piping_layer = piping_layer)
		cap.appearance_flags |= RESET_COLOR|KEEP_APART
		add_overlay(cap)

	if(!on || !is_operational)
		icon_state = "vent_off"
	else
		icon_state = pump_direction ? "vent_out" : "vent_in"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/process_atmos()
	if(!on)
		return

	var/turf/location = get_turf(loc)
	if(isclosedturf(location))
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	if(pump_direction) //input -> external
		var/pressure_delta = 10000

		if(pressure_checks&ATMOS_EXTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&ATMOS_INTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (air1.return_pressure() - input_pressure_min))

		if(pressure_delta <= 0)
			return
		if(air1.temperature <= 0)
			return
		var/transfer_moles = (pressure_delta*environment.volume)/(air1.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		//Removed can be null if there is no atmosphere in air1
		if(!removed)
			return

		loc.assume_air(removed)

		var/datum/pipeline/parent1 = parents[1]
		parent1.update = TRUE

	else //external -> output
		var/pressure_delta = 10000

		if(pressure_checks&ATMOS_EXTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks&ATMOS_INTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (output_pressure_max - air2.return_pressure()))

		if(pressure_delta <= 0)
			return
		if(environment.temperature <= 0)
			return
		var/transfer_moles = (pressure_delta*air2.volume)/(environment.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
		//removed can be null if there is no air in the location
		if(!removed)
			return

		air2.merge(removed)

		var/datum/pipeline/parent2 = parents[2]
		parent2.update = TRUE

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume
	name = "large dual-port air vent"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/New()
	..()
	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]
	air1.volume = 1000
	air2.volume = 1000

// Mapping

/obj/machinery/atmospherics/components/binary/dp_vent_pump/layer2
	piping_layer = 2
	icon_state = "dpvent_map-2"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/layer4
	piping_layer = 4
	icon_state = "dpvent_map-4"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/on
	on = TRUE
	icon_state = "dpvent_map_on-3"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/on/layer2
	piping_layer = 2
	icon_state = "dpvent_map_on-2"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/on/layer4
	piping_layer = 4
	icon_state = "dpvent_map_on-4"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/incinerator_ordmix
	id_tag = INCINERATOR_ORDMIX_DP_VENTPUMP

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/incinerator_atmos
	id_tag = INCINERATOR_ATMOS_DP_VENTPUMP

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/incinerator_syndicatelava
	id_tag = INCINERATOR_SYNDICATELAVA_DP_VENTPUMP

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/layer2
	piping_layer = 2
	icon_state = "dpvent_map-2"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/layer4
	piping_layer = 4
	icon_state = "dpvent_map-4"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on
	on = TRUE
	icon_state = "dpvent_map_on-3"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on/layer2
	piping_layer = 2
	icon_state = "dpvent_map_on-2"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on/layer4
	piping_layer = 4
	icon_state = "dpvent_map_on-4"

#undef OUTPUT_MAX
