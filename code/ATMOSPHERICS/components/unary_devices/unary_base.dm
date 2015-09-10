/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1
	device_type = UNARY

/obj/machinery/atmospherics/components/unary/SetInitDirections()
	initialize_directions = dir

/*
Iconnery
*/

/obj/machinery/atmospherics/components/unary/hide(intact)
	update_icon()

	..(intact)

/obj/machinery/atmospherics/components/unary/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(!..())
		return
	SetInitDirections()
	var/obj/machinery/atmospherics/node = NODE1
	if(node)
		node.disconnect(src)
	node = null
	nullifyPipenet(PARENT1)
	atmosinit()
	node = NODE1
	if(node)
		node.atmosinit()
		node.addMember(src)
	build_network()
	. = 1