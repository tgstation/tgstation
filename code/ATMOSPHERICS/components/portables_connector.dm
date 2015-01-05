/obj/machinery/atmospherics/unary/portables_connector
	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	icon_state = "connector_map" //Only for mapping purposes, so mappers can see direction
	can_unwrench = 1
	var/obj/machinery/portable_atmospherics/connected_device
	use_power = 0

/obj/machinery/atmospherics/unary/portables_connector/update_icon()
	icon_state = "connector"
	underlays.Cut()
	var/state
	var/col
	var/lay
	if(node)
		state = "pipe_intact"
		col = node.pipe_color
		lay = node.layer
	else
		state = "pipe_exposed"
		lay = layer

	underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', state, initialize_directions, col, lay)

/obj/machinery/atmospherics/unary/portables_connector/process()
	if(!connected_device)
		return
	parent.update = 1

/obj/machinery/atmospherics/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	..()

/obj/machinery/atmospherics/unary/portables_connector/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(connected_device)
			user << "<span class='danger'>You cannot unwrench this [src], dettach [connected_device] first.</span>"
			return 1
	return ..()

/obj/machinery/atmospherics/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
