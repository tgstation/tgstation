/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1
	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/node

/obj/machinery/atmospherics/components/unary/New()
	..()
	air_contents = new
	air_contents.volume = 200


/obj/machinery/atmospherics/components/unary/SetInitDirections()
	initialize_directions = dir
/*
Iconnery
*/

/obj/machinery/atmospherics/components/unary/update_icon()
	nodes = list(node)
	..()
/* /obj/machinery/atmospherics/components/unary/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	if(!showpipe)
		return //no need to continue if we're not showing pipes
	if(node)
		icon_addintact(node)
		return
	icon_addbroken() */

/obj/machinery/atmospherics/components/unary/hide(var/intact)
	showpipe = !intact
	update_icon()

	..(intact)

/*
Housekeeping and pipe network stuff below
*/

/obj/machinery/atmospherics/components/unary/Destroy()
	if(node)
		node.disconnect(src)
		node = null
		nullifyPipenet(parent)
	..()


/obj/machinery/atmospherics/components/unary/atmosinit()
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	if(level == 2)
		showpipe = 1
	update_icon()
	..()

/obj/machinery/atmospherics/components/unary/construction()
	..()
	parent.update = 1

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

/obj/machinery/atmospherics/components/unary/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

/obj/machinery/atmospherics/components/unary/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node)
		if(istype(node, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node = null
	update_icon()

/obj/machinery/atmospherics/components/unary/nullifyPipenet()
	..()
	parent.other_airs -= air_contents
	parent = null

/obj/machinery/atmospherics/components/unary/returnPipenetAir()
	return air_contents

/obj/machinery/atmospherics/components/unary/pipeline_expansion()
	return list(node)

/obj/machinery/atmospherics/components/unary/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/components/unary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	if(Old == parent)
		parent = New


/obj/machinery/atmospherics/components/unary/unsafe_pressure_release(var/mob/user,var/pressures)
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from air_contents and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = pressures*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/to_release = air_contents.remove(lost)
		T.assume_air(to_release)
		air_update_turf(1)


