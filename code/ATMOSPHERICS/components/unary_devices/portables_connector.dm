/obj/machinery/atmospherics/components/unary/portables_connector
	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	icon_state = "connector_map" //Only for mapping purposes, so mappers can see direction
	can_unwrench = 1
	var/obj/machinery/portable_atmospherics/connected_device
	use_power = 0
	level = 0

/obj/machinery/atmospherics/components/unary/portables_connector/visible
	level = 2

/obj/machinery/atmospherics/components/unary/portables_connector/process_atmos()
	if(!connected_device)
		return
	update_parents()

/obj/machinery/atmospherics/components/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	..()

/obj/machinery/atmospherics/components/unary/portables_connector/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(connected_device)
			user << "<span class='warning'>You cannot unwrench this [src], dettach [connected_device] first!</span>"
			return 1
	return ..()

/obj/machinery/atmospherics/components/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
