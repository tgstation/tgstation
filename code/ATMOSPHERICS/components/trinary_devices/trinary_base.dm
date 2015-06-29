/obj/machinery/atmospherics/trinary
	icon = 'icons/obj/atmospherics/trinary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = 1

	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2
	var/datum/gas_mixture/air3

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipeline/parent1
	var/datum/pipeline/parent2
	var/datum/pipeline/parent3

	var/flipped = 0

/obj/machinery/atmospherics/trinary/New()
	..()

	air1 = new
	air2 = new
	air3 = new

	air1.volume = 200
	air2.volume = 200
	air3.volume = 200

/obj/machinery/atmospherics/trinary/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|WEST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|EAST
/*
Iconnery
*/
/obj/machinery/atmospherics/trinary/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/trinary/update_icon()
	update_icon_nopipes()

	var/connected = 0
	underlays.Cut()

	//Add non-broken pieces
	if(node1)
		connected = icon_addintact(node1, connected)

	if(node2)
		connected = icon_addintact(node2, connected)

	if(node3)
		connected = icon_addintact(node3, connected)

	//Add broken pieces
	icon_addbroken(connected)

/*
Housekeeping and pipe network stuff below
*/
/obj/machinery/atmospherics/trinary/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null
		nullifyPipenet(parent1)
	if(node2)
		node2.disconnect(src)
		node2 = null
		nullifyPipenet(parent2)
	if(node3)
		node3.disconnect(src)
		node3 = null
		nullifyPipenet(parent3)
	..()

/obj/machinery/atmospherics/trinary/atmosinit()

	//Mixer:
	//1 and 2 is input
	//Node 3 is output
	//If we flip the mixer, 1 and 3 shall exchange positions

	//Filter:
	//Node 1 is input
	//Node 2 is filtered output
	//Node 3 is rest output
	//If we flip the filter, 1 and 3 shall exchange positions

	var/node1_connect = turn(dir, -180)
	var/node2_connect = turn(dir, -90)
	var/node3_connect = dir

	if(flipped)
		node1_connect = turn(node1_connect, 180)
		node3_connect = turn(node3_connect, 180)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			node2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			node3 = target
			break

	update_icon()
	..()

/obj/machinery/atmospherics/trinary/construction()
	..()
	parent1.update = 1
	parent2.update = 1
	parent3.update = 1

/obj/machinery/atmospherics/trinary/build_network()
	if(!parent1)
		parent1 = new /datum/pipeline()
		parent1.build_pipeline(src)

	if(!parent2)
		parent2 = new /datum/pipeline()
		parent2.build_pipeline(src)

	if(!parent3)
		parent3 = new /datum/pipeline()
		parent3.build_pipeline(src)

/obj/machinery/atmospherics/trinary/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent1)
		node1 = null
	else if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent2)
		node2 = null
	else if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent3)
		node3 = null
	update_icon()

/obj/machinery/atmospherics/trinary/nullifyPipenet(datum/pipeline/P)
	..()
	if(P == parent1)
		parent1.other_airs -= air1
		parent1 = null
	else if(P == parent2)
		parent2.other_airs -= air2
		parent2 = null
	else if(P == parent3)
		parent3.other_airs -= air3
		parent3 = null

/obj/machinery/atmospherics/trinary/returnPipenetAir(datum/pipeline/P)
	if(P == parent1)
		return air1
	else if(P == parent2)
		return air2
	else if(P == parent3)
		return air3

/obj/machinery/atmospherics/trinary/pipeline_expansion(datum/pipeline/P)
	if(P)
		if(parent1 == P)
			return list(node1)
		else if(parent2 == P)
			return list(node2)
		else if(parent3 == P)
			return list(node3)
	return list(node1, node2, node3)

/obj/machinery/atmospherics/trinary/setPipenet(datum/pipeline/P, obj/machinery/atmospherics/A)
	if(A == node1)
		parent1 = P
	else if(A == node2)
		parent2 = P
	else if(A == node3)
		parent3 = P

/obj/machinery/atmospherics/trinary/returnPipenet(obj/machinery/atmospherics/A)
	if(A == node1)
		return parent1
	else if(A == node2)
		return parent2
	else if(A == node3)
		return parent3

/obj/machinery/atmospherics/trinary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	if(Old == parent1)
		parent1 = New
	else if(Old == parent2)
		parent2 = New
	else if(Old == parent3)
		parent3 = New


/obj/machinery/atmospherics/trinary/unsafe_pressure_release(var/mob/user,var/pressures)
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from air1+air2+air3 and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = pressures*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)
		lost += pressures*environment.volume/(air2.temperature * R_IDEAL_GAS_EQUATION)
		lost += pressures*environment.volume/(air3.temperature * R_IDEAL_GAS_EQUATION)
		var/shared_loss = lost/3

		var/datum/gas_mixture/to_release = air1.remove(shared_loss)
		to_release.merge(air2.remove(shared_loss))
		to_release.merge(air3.remove(shared_loss))
		T.assume_air(to_release)
		air_update_turf(1)
