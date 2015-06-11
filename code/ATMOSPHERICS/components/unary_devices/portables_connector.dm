/obj/machinery/atmospherics/unary/portables_connector
	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	icon_state = "connector_map" //Only for mapping purposes, so mappers can see direction
	can_unwrench = 1
	var/obj/machinery/portable_atmospherics/connected_device
	use_power = 0
	level = 0

/obj/machinery/atmospherics/unary/portables_connector/visible
	level = 2

/obj/machinery/atmospherics/unary/portables_connector/update_icon()
	icon_state = "connector"
	underlays.Cut()
	if(showpipe)
		var/state
		var/col
		if(node)
			state = "pipe_intact"
			col = node.pipe_color
		else
			state = "pipe_exposed"
		underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', state, initialize_directions, col)

/obj/machinery/atmospherics/unary/portables_connector/process_atmos()
	if(!connected_device)
		return
	parent.update = 1

/obj/machinery/atmospherics/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	..()

/obj/machinery/atmospherics/unary/portables_connector/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(connected_device)
			user << "<span class='warning'>You cannot unwrench this [src], dettach [connected_device] first!</span>"
			return 1
	return ..()

/obj/machinery/atmospherics/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
