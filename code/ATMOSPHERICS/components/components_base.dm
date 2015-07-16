/*
So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
On top of that, now people can add component-speciic procs/vars if they want!
*/

#define UNARY	1
#define BINARY 	2
#define TRINARY	3

#define AIR1	"a1"
#define AIR2	"a2"
#define AIR3	"a3"

#define PARENT1	"p1"
#define PARENT2	"p2"
#define PARENT3	"p3"

#define NODE1	"n1"
#define	NODE2	"n2"
#define NODE3	"n3"

/obj/machinery/atmospherics/components/
	var/welded //Used on pumps and scrubbers
	var/showpipe = 0

	var/device_type = 0//used for initialization stuff
		//UNARY = 1
		//BINARY = 2
		//TRINARY = 3

	var/list/obj/machinery/atmospherics/nodes = list()
	var/list/datum/pipeline/parents = list()
	var/list/datum/gas_mixture/airs = list()

/obj/machinery/atmospherics/components/New()
	..()
	for(var/I = 1; I <= device_type; I++)
		var/datum/gas_mixture/A = new
		A.volume = 200
		airs["a[I]"] = A
/*
Iconnery
*/

/obj/machinery/atmospherics/components/proc/icon_addintact(var/obj/machinery/atmospherics/node, var/connected = 0)
	var/image/img = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', "pipe_intact", get_dir(src,node), node.pipe_color)
	underlays += img

	return connected | img.dir

/obj/machinery/atmospherics/components/proc/icon_addbroken(var/connected = 0)
	var/unconnected = (~connected) & initialize_directions
	for(var/direction in cardinal)
		if(unconnected & direction)
			underlays += getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', "pipe_exposed", direction)

/obj/machinery/atmospherics/components/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/components/update_icon() //not working
	update_icon_nopipes()

	underlays.Cut()
	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0

	for(var/I = 1; I <= device_type; I++) //adds intact pieces
		if(nodes["n[I]"])
			connected = icon_addintact(nodes["n[I]"], connected)

	icon_addbroken(connected) //adds broken pieces


/*
Pipenet stuff; housekeeping
*/
/obj/machinery/atmospherics/components/Destroy()
	for(var/I = 1; I <= device_type; I++)
		var/obj/machinery/atmospherics/N = nodes["n[I]"]
		if(N)
			N.disconnect(src)
			N = null
			nullifyPipenet(parents["p[I]"])
	..()

/obj/machinery/atmospherics/components/atmosinit(var/list/node_connects)
	for(var/I = 1; I <= device_type; I++)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[I]))
			if(target.initialize_directions & get_dir(target,src))
				nodes["n[I]"] = target
				break
	if(level == 2)
		showpipe = 1
	update_icon()

/obj/machinery/atmospherics/components/construction()
	..()
	update_parents()

/obj/machinery/atmospherics/components/build_network()
	for(var/I = 1; I <= device_type; I++)
		if(!parents["p[I]"])
			parents["p[I]"] = new /datum/pipeline()
			var/datum/pipeline/P = parents["p[I]"]
			P.build_pipeline(src)

/obj/machinery/atmospherics/components/disconnect(obj/machinery/atmospherics/reference)
	for(var/I = 1; I <= device_type; I++)
		if(reference == nodes["n[I]"])
			if(istype(nodes["n[I]"], /obj/machinery/atmospherics/pipe))
				qdel(parents["p[I]"])
			parents["p[I]"] = null
			break
	update_icon()

/obj/machinery/atmospherics/components/nullifyPipenet(datum/pipeline/reference)
	..()
	for(var/I = 1; I <= device_type; I++)
		if(reference == parents["p[I]"])
			var/datum/pipeline/P = parents["p[I]"]
			P.other_airs -= airs["a[I]"]
			P = null
			break

/obj/machinery/atmospherics/components/returnPipenetAir(datum/pipeline/reference)
	for(var/I = 1; I <= device_type; I++)
		if(reference == parents["p[I]"])
			return airs["a[I]"]

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		for(var/I = 1; I <= device_type; I++)
			if(nodes["n[I]"])
				if(parents["p[I]"] == reference)
					return list("n" = nodes["n[I]"])

	var/list/obj/machinery/atmospherics/return_nodes = list()
	for(var/I = 1; I <= device_type; I++)
		return_nodes += nodes["n[I]"]

	return return_nodes

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	for(var/I = 1; I <= device_type; I++)
		if(A == nodes["n[I]"])
			parents["p[I]"] = reference
			break

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A)
	for(var/I = 1; I <= device_type; I++)
		if(A == nodes["n[I]"])
			return parents["p[I]"]

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	for(var/datum/pipeline/P in parents)
		if(Old == P)
			P = New
			break

/obj/machinery/atmospherics/components/unsafe_pressure_release(var/mob/user, var/pressures) //untestable; I'll fix this last
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/I = 1; I <= device_type; I++)
			var/datum/gas_mixture/air = airs["a[I]"]
			lost += pressures*environment.volume/(air.temperature * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		var/datum/gas_mixture/to_release
		for(var/I = 1; I <= device_type; I++)
			var/datum/gas_mixture/air = airs["a[I]"]
			if(!to_release)
				to_release = air.remove(shared_loss)
				continue
			to_release.merge(air.remove(shared_loss))
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

/obj/machinery/atmospherics/components/proc/update_parents()
	for(var/I = 1; I <= device_type; I++)
		var/datum/pipeline/parent = parents["p[I]"]
		parent.update = 1