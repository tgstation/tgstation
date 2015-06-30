/*
So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
On top of that, now people can add component-speciic procs/vars if they want!
*/
/obj/machinery/atmospherics/components/
	var/welded = 0 //Used on pumps and scrubbers
	var/showpipe = 0
	var/nodes = 0

/obj/machinery/atmospherics/components/New(var/new_airs[] = get_airs()) //doesn't work properly
	..()
	for(var/A in new_airs)
		var/datum/gas_mixture/air = A

		air = new
		air.volume = 200
		new_airs[A] = air
	return new_airs
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

/obj/machinery/atmospherics/components/update_icon(var/update_nodes[] = nodes) //works
	update_icon_nopipes()

	underlays.Cut()
	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0

	for(var/N in update_nodes) //adds intact pieces
		var/obj/machinery/atmospherics/node = N
		if(node)
			connected = icon_addintact(node, connected)

	icon_addbroken(connected) //adds broken pieces

/*
Pipenet stuff; housekeeping
*/
/obj/machinery/atmospherics/components/Destroy(var/dest_nodes[] = get_nodes(), var/dest_parents[] = get_parents()) //works somewhat
	for(var/N in dest_nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = dest_parents[N]

		if(node)
			node.disconnect(src)
			node = null
			nullifyPipenet(parent)
			dest_nodes[N] = node
			dest_parents[N] = parent
	..()
	return list(nodes = dest_nodes, parents = dest_parents)

/obj/machinery/atmospherics/components/atmosinit(var/node_connects[], var/init_nodes[] = get_nodes()) //doesn't work for another reason
	/*for(var/N in nodes)
		var/obj/machinery/atmospherics/node = N
		var/dir/node_connect = node_connects[N]

		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break*/
	if(level == 2)
		showpipe = 1
	update_icon()
	return

/obj/machinery/atmospherics/components/construction(var/constr_parents[] = get_parents()) //doesn't work
	..()
	for(var/P in constr_parents)
		var/datum/pipeline/parent = P
		parent.update = 1
		constr_parents[P] = parent
	return constr_parents

/obj/machinery/atmospherics/components/build_network(var/build_parents[] = get_parents()) //doesn't work
	for(var/P in build_parents)
		var/datum/pipeline/parent = P

		if(parent)
			return
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
		build_parents[P] = parent
	return build_parents

/obj/machinery/atmospherics/components/disconnect(obj/machinery/atmospherics/reference, var/disc_nodes[] = get_nodes(), var/disc_parents[] = get_parents()) //works
	for(var/N in disc_nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = disc_parents[N]

		if(reference == node)
			if(istype(node, /obj/machinery/atmospherics/pipe))
				qdel(parent)
			parent = null
			disc_parents[N] = parent
	update_icon()
	return disc_parents

/obj/machinery/atmospherics/components/nullifyPipenet(datum/pipeline/pipeline, var/null_parents[] = get_parents(), var/null_airs[] = get_airs()) //untestable
	..()
	for(var/P in null_parents)
		var/datum/pipeline/parent = P
		var/datum/gas_mixture/air = null_airs[P]

		if(pipeline == parent)
			parent.other_airs -= air
			parent = null
			null_parents[P] = parent
	return null_parents

/obj/machinery/atmospherics/components/returnPipenetAir(datum/pipeline/pipeline, var/return_parents[] = get_parents(), var/return_airs[] = get_airs()) //untestable; should work
	for(var/P in return_parents)
		var/datum/pipeline/parent = P
		var/datum/gas_mixture/air = return_airs[P]

		if(pipeline == parent)
			return air

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/pipeline, var/expand_parents[] = get_parents(), var/expand_nodes[] = get_nodes()) //TODO: dong
	if(!pipeline)
		return expand_nodes //works
	for(var/N in expand_nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = expand_parents[N]

		if(parent == pipeline)
			return list(node) //untestable; should work

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/pipeline, obj/machinery/atmospherics/A, var/set_parents[] = get_parents(), var/set_nodes[] = get_nodes())
	for(var/N in set_nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = set_parents[N]

		if(A == node)
			parent = pipeline
			set_parents[N] = parent
	return set_parents

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A, var/return_parents[] = get_parents(), var/return_nodes = get_nodes())
	for(var/N in return_nodes)
		var/obj/machinery/atmospherics/node = N
		var/datum/pipeline/parent = return_parents[N]

		if(A == node)
			return parent //probably works

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New, var/replace_parents[] = get_parents())
	for(var/P in replace_parents)
		var/datum/pipeline/parent = P

		if(Old == parent)
			parent = New
			replace_parents[P] = parent
	return replace_parents

/obj/machinery/atmospherics/components/unsafe_pressure_release(var/mob/user, var/pressures, var/unsafe_airs[] = get_airs()) //untestable; I'll fix this last
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/A in unsafe_airs)
			var/datum/gas_mixture/air = A
			lost += pressures*environment.volume/(air.temperature * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		var/datum/gas_mixture/to_release
		for(var/A in unsafe_airs)
			var/datum/gas_mixture/air = A
			if(!to_release)
				to_release = air.remove(shared_loss)
				continue
			to_release.merge(air.remove(shared_loss))
			unsafe_airs[A] = air
		T.assume_air(to_release)
		air_update_turf(1)
	return unsafe_airs

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

/obj/machinery/atmospherics/components/proc/set_airs()
	return
/obj/machinery/atmospherics/components/proc/set_nodes()
	return
/obj/machinery/atmospherics/components/proc/set_parents()
	return