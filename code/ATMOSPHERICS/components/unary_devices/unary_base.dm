/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1
	nodes = 1

	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/node

/obj/machinery/atmospherics/components/unary/New()
	var/airs[] = ..()
	set_airs(airs)

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

/obj/machinery/atmospherics/components/unary/get_airs()
	return list(air_contents)

/obj/machinery/atmospherics/components/unary/get_nodes()
	return list(node)

/obj/machinery/atmospherics/components/unary/get_parents()
	return list(parent)

/obj/machinery/atmospherics/components/unary/set_airs(var/list/L)
	var/datum/gas_mixture/a1 = L[1]
	air_contents = a1

/obj/machinery/atmospherics/components/unary/set_nodes(var/list/L)
	var/obj/machinery/atmospherics/n1 = L[1]
	node = n1

/obj/machinery/atmospherics/components/unary/set_parents(var/list/L)
	var/datum/pipeline/p1 = L[1]
	parent = p1

/*
Housekeeping and pipe network stuff below
*/

/obj/machinery/atmospherics/components/unary/atmosinit()
	//var/node_connects = list(dir)
	for(var/obj/machinery/atmospherics/target in get_step(src,dir))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	..(/*node_connects*/)

/obj/machinery/atmospherics/components/unary/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(..())
		initialize_directions = dir
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

/obj/machinery/atmospherics/components/unary/construction()
	var/parents[] = ..()
	set_parents(parents)

/obj/machinery/atmospherics/components/unary/build_network()
	var/parents[] = ..()
	set_parents(parents)

/obj/machinery/atmospherics/components/unary/disconnect(obj/machinery/atmospherics/reference)
	var/parents[] = ..(reference)
	set_parents(parents)

/obj/machinery/atmospherics/components/unary/nullifyPipenet(datum/pipeline/P)
	var/parents[] = ..(P)
	set_parents(parents)

/obj/machinery/atmospherics/components/unary/setPipenet(datum/pipeline/P, obj/machinery/atmospherics/A)
	var/parents[] = ..(P, A)
	set_parents(parents)

/obj/machinery/atmospherics/components/unary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	var/parents[] = ..(Old, New)
	set_parents(parents)

/obj/machinery/atmospherics/components/unary/unsafe_pressure_release(var/mob/user, var/pressures)
	var/airs[] = ..(user, pressures)
	set_airs(airs)

//This sure looks like a lot of copypaste... It's already way better though, so it works for now
//TODO: make it even more OOP - duncathan