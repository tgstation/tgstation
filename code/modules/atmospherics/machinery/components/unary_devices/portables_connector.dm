/obj/machinery/atmospherics/components/unary/portables_connector
	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	icon_state = "connector_map" //Only for mapping purposes, so mappers can see direction
	can_unwrench = 1
	var/obj/machinery/portable_atmospherics/connected_device
	use_power = 0
	level = 0

/obj/machinery/atmospherics/components/unary/portables_connector/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1

	air_contents.volume = 0

/obj/machinery/atmospherics/components/unary/portables_connector/visible
	level = 2

/obj/machinery/atmospherics/components/unary/portables_connector/process_atmos()
	if(!connected_device)
		return
	update_parents()

/obj/machinery/atmospherics/components/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	return ..()

/obj/machinery/atmospherics/components/unary/portables_connector/can_unwrench(mob/user)
	if(..())
		if(connected_device)
			to_chat(user, "<span class='warning'>You cannot unwrench this [src], detach [connected_device] first!</span>")
		else
			return 1

/obj/machinery/atmospherics/components/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
