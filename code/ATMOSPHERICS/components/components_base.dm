/*
So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
On top of that, now people can add component-speciic procs/vars if they want!
*/

#define UNARY	1
#define BINARY 	2
#define TRINARY	3

/obj/machinery/atmospherics/components/
	var/welded = 0 //Used on pumps and scrubbers
	var/showpipe = 0

	var/list/nodes = new/list()
	var/list/parents = new/list()
	var/list/airs = new/list()

	var/device_type //used for initialization stuff
		//UNARY = 1
		//BINARY = 2
		//TRINARY = 3

/obj/machinery/atmospherics/components/New() //it's workiiiing
	..()
	for(var/I = 1; I <= device_type; I++)
		var/datum/gas_mixture/A
		A = new
		A.volume = 200
		airs["a[I]"] = A
/*
Iconnery
*/

/obj/machinery/atmospherics/components/proc/icon_addintact(var/obj/machinery/atmospherics/node)
	var/image/img = getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_intact", get_dir(src,node), node.pipe_color)
	underlays += img

	return img.dir

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

	for(var/obj/machinery/atmospherics/N in nodes) //adds intact pieces
		if(N)
			connected |= icon_addintact(N)

	icon_addbroken(connected) //adds broken pieces

/*
Pipenet stuff; housekeeping
*/
/obj/machinery/atmospherics/components/Destroy() //works somewhat
	var/I = 1
	for(var/obj/machinery/atmospherics/N in nodes)
		if(N)
			N.disconnect(src)
			N = null
			nullifyPipenet(parents["p[I]"])
			nodes["n[I]"] = N
	I++
	..()

/obj/machinery/atmospherics/components/atmosinit(var/list/node_connects) //doesn't get called properly
	var/I = 1
	for(var/N in node_connects)
		for(var/obj/machinery/atmospherics/target in get_step(src,N))
			if(target.initialize_directions & get_dir(target,src))
				nodes["n[I]"] = target
				break
		I++
	if(level == 2)
		showpipe = 1
	update_icon()

/obj/machinery/atmospherics/components/construction()
	..()
	for(var/I = 1; I <= device_type; I++)
		var/datum/pipeline/P = new
		P.update = 1
		parents["p[I]"] = P
		I++

/obj/machinery/atmospherics/components/build_network() //doesn't work
	for(var/I = 1; I <= device_type; I++)
		var/datum/pipeline/P = parents["p[I]"]
		if(P)
			return
		P = new /datum/pipeline()
		P.build_pipeline(src)
		parents["p[I]"] = P

/obj/machinery/atmospherics/components/disconnect(obj/machinery/atmospherics/reference) //works
	var/I = 1
	for(var/obj/machinery/atmospherics/N in nodes)
		if(reference == N)
			if(istype(N, /obj/machinery/atmospherics/pipe))
				qdel(parents["p[I]"])
			parents["p[I]"] = null
		I++
	update_icon()

/obj/machinery/atmospherics/components/nullifyPipenet(datum/pipeline/reference) //untestable
	..()
	var/I = 1
	for(var/datum/pipeline/P in parents)
		if(reference == P)
			P.other_airs -= airs[I]
			P = null
			parents["p[I]"] = P
		I++

/obj/machinery/atmospherics/components/returnPipenetAir(datum/pipeline/reference) //untestable; should work
	var/I = 1
	for(var/datum/pipeline/P in parents)
		if(reference == parent)
			return airs["a[I]"]
		I++

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(!reference)
		return nodes
	var/I = 1
	for(var/obj/machinery/atmospherics/N in nodes)
		if(parents["p[I]"] == reference)
			return list(N) //untestable; should work
		I++

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/pipeline, obj/machinery/atmospherics/A)
	var/I = 1
	for(var/obj/machinery/atmospherics/N in nodes)
		if(A == N)
			parents["p[I]"] = pipeline
		I++

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A)
	var/I = 1
	for(var/obj/machinery/atmospherics/N in nodes)
		if(A == N)
			return parents["p[I]"] //probably works
		I++

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	var/I
	for(var/datum/pipeline/P in parents)
		if(Old == P)
			P = New
		parents["p[I]"] = P
		I++

/obj/machinery/atmospherics/components/unsafe_pressure_release(var/mob/user, var/pressures) //untestable; I'll fix this last
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/A = 1; A <= device_type; A++)
			var/datum/gas_mixture/air = airs[A]
			lost += pressures*environment.volume/(air.temperature * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		var/datum/gas_mixture/to_release
		for(var/A = 1; A <= device_type; A++)
			var/datum/gas_mixture/air = airs[A]
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
/obj/machinery/atmospherics/components/proc/update_airs(var/list/L)
	var/I = 1
	for(var/datum/gas_mixture/air in L)
		airs["a[I]"] = air
		I++

/obj/machinery/atmospherics/components/proc/update_parents(var/list/L = parents)
	var/I = 1
	for(var/datum/pipeline/parent in L)
		if(!parent)
			continue
		parent.update = 1
		parents["p[I]"] = parent
		I++
/obj/machinery/atmospherics/components/proc/init_airs()
	return
/obj/machinery/atmospherics/components/proc/init_nodes()
	return
/obj/machinery/atmospherics/components/proc/init_parents()
	return