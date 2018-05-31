/obj/machinery/atmospherics/components/unary/portables_connector
	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	icon_state = "connector_map" //Only for mapping purposes, so mappers can see direction
	can_unwrench = TRUE
	var/obj/machinery/portable_atmospherics/connected_device
	use_power = NO_POWER_USE
	level = 0
	layer = GAS_FILTER_LAYER
	pipe_flags = PIPING_ONE_PER_TURF
	pipe_state = "connector"
	
/obj/machinery/atmospherics/components/unary/portables_connector/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/components/unary/portables_connector/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/components/unary/portables_connector/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]

	air_contents.volume = 0

/obj/machinery/atmospherics/components/unary/portables_connector/visible
	level = 2

/obj/machinery/atmospherics/components/unary/portables_connector/visible/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/components/unary/portables_connector/visible/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y
	
/obj/machinery/atmospherics/components/unary/portables_connector/process_atmos()
	if(!connected_device)
		return
	update_parents()

/obj/machinery/atmospherics/components/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	return ..()

/obj/machinery/atmospherics/components/unary/portables_connector/can_unwrench(mob/user)
	. = ..()
	if(. && connected_device)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], detach [connected_device] first!</span>")
		return FALSE

/obj/machinery/atmospherics/components/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
