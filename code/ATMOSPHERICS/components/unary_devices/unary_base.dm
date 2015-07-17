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

/obj/machinery/atmospherics/components/unary/hide(var/intact)
	showpipe = !intact
	update_icon()

	..(intact)

/*
Housekeeping and pipe network stuff below
*/

/obj/machinery/atmospherics/components/unary/atmosinit()
	var/list/node_connects = new/list()
	node_connects.Add(dir)
	..(node_connects)

/obj/machinery/atmospherics/components/unary/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(!..())
		return
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[NODE1]
	if(node)
		node.disconnect(src)
	node = null
	nullifyPipenet(parents[PARENT1])
	atmosinit()
	node = nodes[NODE1]
	initialize()
	if(node)
		node.atmosinit()
		node.initialize()
		node.addMember(src)
	build_network()
	. = 1