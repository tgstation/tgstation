/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1
	node_amount = 1

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
Helpers
*/

/obj/machinery/atmospherics/components/unary/update_airs(var/a1)
	..(list(1 = a1))

/*
Housekeeping and pipe network stuff below
*/

/obj/machinery/atmospherics/components/unary/atmosinit()
	var/node_connects = list(1 = dir)
	/*for(var/obj/machinery/atmospherics/target in get_step(src,dir))
		if(target.initialize_directions & get_dir(target,src))
			nodes[1] = target
			break*/
	..(node_connects)

/obj/machinery/atmospherics/components/unary/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(..())
		return 0
	initialize_directions = dir
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		node.disconnect(src)
	node = null
	nullifyPipenet(parent)
	atmosinit()
	initialize()
	if(node)
		node.atmosinit()
		node.initialize()
		node.addMember(src)
	build_network()
	. = 1
	nodes[1] = node