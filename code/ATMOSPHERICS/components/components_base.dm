/*
So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
On top of that, now people can add component-speciic procs/vars if they want!
*/
/obj/machinery/atmospherics/components/
	var/welded = 0 //Used on pumps and scrubbers
	var/showpipe = 0
	var/list/nodes
	var/list/parents
	var/list/airs
	var/node_amount

/obj/machinery/atmospherics/components/New() //doesn't work properly
	..()
	for(var/A = 1; A <= node_amount; A++)
		var/datum/gas_mixture/air = A

		air = new
		air.volume = 200
		airs[A] = air
/*
Iconnery
*/

/obj/machinery/atmospherics/components/proc/icon_addintact(var/obj/machinery/atmospherics/node, var/connected = 0)
	var/image/img = getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_intact", get_dir(src,node), node.pipe_color)
	underlays += img

	return connected | img.dir

/obj/machinery/atmospherics/components/proc/icon_addbroken(var/connected = 0)
	var/unconnected = (~connected) & initialize_directions
	for(var/direction in cardinal)
		if(unconnected & direction)
			underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_exposed", direction)

/obj/machinery/atmospherics/components/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/components/update_icon() //works
	update_icon_nopipes()

	underlays.Cut()
	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0

	for(var/N in nodes) //adds intact pieces
		var/obj/machinery/atmospherics/node = N
		if(node)
			connected = icon_addintact(node, connected)

	icon_addbroken(connected) //adds broken pieces

/*
Pipenet stuff; housekeeping
*/
/obj/machinery/atmospherics/components/Destroy() //works somewhat
	for(var/N in nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = parents[N]

		if(node)
			node.disconnect(src)
			node = null
			nullifyPipenet(parent)
			nodes[N] = node
			parents[N] = parent
	..()

/obj/machinery/atmospherics/components/atmosinit(var/list/node_connects) //doesn't work for another reason
	for(var/N = 1; N <= node_amount; N++)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[N]))
			if(target.initialize_directions & get_dir(target,src))
				nodes[N] = target
	if(level == 2)
		showpipe = 1
	update_icon()
	return

/obj/machinery/atmospherics/components/construction() //doesn't work
	..()
	for(var/P in parents)
		var/datum/pipeline/parent = P
		parent.update = 1
		parents[P] = parent

/obj/machinery/atmospherics/components/build_network() //doesn't work
	for(var/P in parents)
		var/datum/pipeline/parent = P

		if(parent)
			return
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
		parents[P] = parent

/obj/machinery/atmospherics/components/disconnect(obj/machinery/atmospherics/reference) //works
	for(var/N in nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = parents[N]

		if(reference == node)
			if(istype(node, /obj/machinery/atmospherics/pipe))
				qdel(parent)
			parent = null
			parents[N] = parent
	update_icon()

/obj/machinery/atmospherics/components/nullifyPipenet(datum/pipeline/pipeline) //untestable
	..()
	for(var/P in parents)
		var/datum/pipeline/parent = P
		var/datum/gas_mixture/air = airs[P]

		if(pipeline == parent)
			parent.other_airs -= air
			parent = null
			parents[P] = parent

/obj/machinery/atmospherics/components/returnPipenetAir(datum/pipeline/pipeline) //untestable; should work
	for(var/P in parents)
		var/datum/pipeline/parent = P
		var/datum/gas_mixture/air = airs[P]

		if(pipeline == parent)
			return air

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/pipeline)
	if(!pipeline)
		return nodes //works
	for(var/N in nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = parents[N]

		if(parent == pipeline)
			return list(node) //untestable; should work

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/pipeline, obj/machinery/atmospherics/A)
	for(var/N in nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = parents[N]

		if(A == node)
			parent = pipeline
			parents[N] = parent

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A)
	for(var/N in nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = parents[N]

		if(A == node)
			return parent //probably works

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	for(var/P in parents)
		var/datum/pipeline/parent = P

		if(Old == parent)
			parent = New
		parents[P] = parent

/obj/machinery/atmospherics/components/unsafe_pressure_release(var/mob/user, var/pressures) //untestable; I'll fix this last
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/A in airs)
			var/datum/gas_mixture/air = A
			lost += pressures*environment.volume/(air.temperature * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		var/datum/gas_mixture/to_release
		for(var/A in airs)
			var/datum/gas_mixture/air = A
			if(!to_release)
				to_release = air.remove(shared_loss)
				continue
			to_release.merge(air.remove(shared_loss))
			airs[A] = air
		T.assume_air(to_release)
		air_update_turf(1)

/*
I think this is NanoUI?
*/

/obj/machinery/atmospherics/components/proc/safe_input(var/title, var/text, var/default_set)
	var/new_value = input(usr,text,title,default_set) as num
	if(usr.canUseTopic(src))
		return new_value
	return default_set

/*
Helpers
*/
/obj/machinery/atmospherics/components/proc/get_airs()
	return
/obj/machinery/atmospherics/components/proc/get_nodes()
	return
/obj/machinery/atmospherics/components/proc/get_parents()
	return

/obj/machinery/atmospherics/components/proc/update_airs(var/list/L)
	for(var/N in L)
		var/datum/gas_mixture/air = L[N]
		airs[N] = air

/obj/machinery/atmospherics/components/proc/update_parents(var/list/L = parents)
	for(var/N in L)
		if(!N)
			continue
		var/datum/pipeline/parent = N ; parent.update = 1
		parents[N] = parent