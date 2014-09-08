/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	force = 20
	layer = 2.4 //under wires with their 2.44
	use_power = 0
	can_unwrench = 1
	var/alert_pressure = 80*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called

/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null
	return 1

/obj/machinery/atmospherics/pipe/return_air()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.return_network()

/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.network_expand(new_network, reference)

/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)
	return parent.return_network(reference)

/obj/machinery/atmospherics/pipe/Destroy()
	del(parent)
	..()

/obj/machinery/atmospherics/pipe/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/analyzer))
		atmosanalyzer_scan(parent.air, user)
	else
		return ..()

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/pipes.dmi'
	icon_state = "intact-f"
	name = "pipe"
	desc = "A one meter section of regular pipe"
	volume = 70
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No
	var/maximum_pressure = 70*ONE_ATMOSPHERE
	var/fatigue_pressure = 55*ONE_ATMOSPHERE
	alert_pressure = 55*ONE_ATMOSPHERE
	level = 1

/obj/machinery/atmospherics/pipe/simple/New()
	..()
	switch(dir)
		if(SOUTH || NORTH)
			initialize_directions = SOUTH|NORTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST
		if(NORTHEAST)
			initialize_directions = NORTH|EAST
		if(NORTHWEST)
			initialize_directions = NORTH|WEST
		if(SOUTHEAST)
			initialize_directions = SOUTH|EAST
		if(SOUTHWEST)
			initialize_directions = SOUTH|WEST

/obj/machinery/atmospherics/pipe/simple/initialize()
	normalize_dir()
	var/N = 2
	for(var/D in cardinal)
		if(D & initialize_directions)
			N--
			for(var/obj/machinery/atmospherics/target in get_step(src, D))
				if(target.initialize_directions & get_dir(target,src))
					if(!node1 && N == 1)
						node1 = target
						break
					if(!node2 && N == 0)
						node2 = target
						break
	var/turf/T = loc			// hide if turf is not intact
	hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/simple/Destroy()
	if(node1)
		var/obj/machinery/atmospherics/A = node1
		node1.disconnect(src)
		A.build_network()
	if(node2)
		var/obj/machinery/atmospherics/A = node2
		node2.disconnect(src)
		A.build_network()
	if(parent)
		parent.removeLastMember(src)
	..()

/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null
	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null
	update_icon()

/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	var/datum/gas_mixture/environment = loc.return_air()
	var/pressure_difference = pressure - environment.return_pressure()
	if(pressure_difference > maximum_pressure)
		burst()
	else if(pressure_difference > fatigue_pressure)
		//TODO: leak to turf, doing pfshhhhh
		if(prob(5))
			burst()
	else return 1

/obj/machinery/atmospherics/pipe/simple/proc/burst()
	src.visible_message("<span class='userdanger'>[src] bursts!</span>");
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
	smoke.set_up(1,0, src.loc, 0)
	smoke.start()
	qdel(src)

/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==3)
		dir = 1
	else if(dir==12)
		dir = 4

/obj/machinery/atmospherics/pipe/simple/update_icon()
	if(node1&&node2)
		var/C = ""
		switch(pipe_color)
			if ("red") C = "-r"
			if ("blue") C = "-b"
			if ("cyan") C = "-c"
			if ("green") C = "-g"
			if ("yellow") C = "-y"
			if ("purple") C = "-p"
		icon_state = "intact[C][invisibility ? "-f" : "" ]"
	else
		var/have_node1 = node1?1:0
		var/have_node2 = node2?1:0
		icon_state = "exposed[have_node1][have_node2][invisibility ? "-f" : "" ]"

/obj/machinery/atmospherics/pipe/simple/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)

/obj/machinery/atmospherics/pipe/simple/insulated
	icon = 'icons/obj/atmospherics/red_pipe.dmi'
	icon_state = "intact"
	minimum_temperature_difference = 10000
	thermal_conductivity = 0
	maximum_pressure = 1000*ONE_ATMOSPHERE
	fatigue_pressure = 900*ONE_ATMOSPHERE
	alert_pressure = 900*ONE_ATMOSPHERE
	level = 2

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "manifold-f"
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes"
	volume = 105
	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	level = 1
	layer = 2.4 //under wires with their 2.44

/obj/machinery/atmospherics/pipe/manifold/New()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			initialize_directions = WEST|NORTH|EAST
		if(EAST)
			initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			initialize_directions = NORTH|EAST|SOUTH
	..()

/obj/machinery/atmospherics/pipe/manifold/initialize()
	for(var/D in cardinal)
		if(D == dir)
			continue
		for(var/obj/machinery/atmospherics/target in get_step(src, D))
			if(target.initialize_directions & get_dir(target,src))
				if(turn(dir, 90) == D)
					node1 = target
				if(turn(dir, 270) == D)
					node2 = target
				if(turn(dir, 180) == D)
					node3 = target
				break
	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/Destroy()
	if(node1)
		var/obj/machinery/atmospherics/A = node1
		node1.disconnect(src)
		A.build_network()
	if(node2)
		var/obj/machinery/atmospherics/A = node2
		node2.disconnect(src)
		A.build_network()
	if(node3)
		var/obj/machinery/atmospherics/A = node3
		node3.disconnect(src)
		A.build_network()
	if(parent)
		parent.removeLastMember(src)
	..()

/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null
	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node2 = null
	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node3 = null
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/manifold/update_icon()
	if(node1&&node2&&node3)
		var/C = ""
		switch(pipe_color)
			if ("red") C = "-r"
			if ("blue") C = "-b"
			if ("cyan") C = "-c"
			if ("green") C = "-g"
			if ("yellow") C = "-y"
			if ("purple") C = "-p"
		icon_state = "manifold[C][invisibility ? "-f" : ""]"
	else
		var/connected = 0
		var/unconnected = 0
		var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)
		if(node1)
			connected |= get_dir(src, node1)
		if(node2)
			connected |= get_dir(src, node2)
		if(node3)
			connected |= get_dir(src, node3)
		unconnected = (~connected)&(connect_directions)
		icon_state = "manifold_[connected]_[unconnected]"

/obj/machinery/atmospherics/pipe/manifold/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)



//coloured pipes
/obj/machinery/atmospherics/pipe/simple/scrubbers
	name="Scrubbers pipe"
	pipe_color="red"
	icon_state = ""

/obj/machinery/atmospherics/pipe/simple/supply
	name="Air supply pipe"
	pipe_color="blue"
	icon_state = ""

/obj/machinery/atmospherics/pipe/simple/supplymain
	name="Main air supply pipe"
	pipe_color="purple"
	icon_state = ""

/obj/machinery/atmospherics/pipe/simple/general
	name="Pipe"
	pipe_color=""
	icon_state = ""

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible
	level = 2
	icon_state = "intact-r"

/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden
	level = 1
	icon_state = "intact-r-f"

/obj/machinery/atmospherics/pipe/simple/supply/visible
	level = 2
	icon_state = "intact-b"

/obj/machinery/atmospherics/pipe/simple/supply/hidden
	level = 1
	icon_state = "intact-b-f"

/obj/machinery/atmospherics/pipe/simple/supplymain/visible
	level = 2
	icon_state = "intact-p"

/obj/machinery/atmospherics/pipe/simple/supplymain/hidden
	level = 1
	icon_state = "intact-p-f"

/obj/machinery/atmospherics/pipe/simple/general/visible
	level = 2
	icon_state = "intact"

/obj/machinery/atmospherics/pipe/simple/general/hidden
	level = 1
	icon_state = "intact-f"

/obj/machinery/atmospherics/pipe/simple/yellow
	name="Pipe"
	pipe_color="yellow"
	icon_state = ""

/obj/machinery/atmospherics/pipe/simple/yellow/visible
	level = 2
	icon_state = "intact-y"

/obj/machinery/atmospherics/pipe/simple/yellow/hidden
	level = 1
	icon_state = "intact-y-f"


//coloured manifolds
/obj/machinery/atmospherics/pipe/manifold/scrubbers
	name="Scrubbers pipe"
	pipe_color="red"
	icon_state = ""

/obj/machinery/atmospherics/pipe/manifold/supply
	name="Air supply pipe"
	pipe_color="blue"
	icon_state = ""

/obj/machinery/atmospherics/pipe/manifold/supplymain
	name="Main air supply pipe"
	pipe_color="purple"
	icon_state = ""

/obj/machinery/atmospherics/pipe/manifold/general
	name="Air supply pipe"
	pipe_color="gray"
	icon_state = ""

/obj/machinery/atmospherics/pipe/manifold/yellow
	name="Air supply pipe"
	pipe_color="yellow"
	icon_state = ""

/obj/machinery/atmospherics/pipe/manifold/scrubbers/visible
	level = 2
	icon_state = "manifold-r"

/obj/machinery/atmospherics/pipe/manifold/scrubbers/hidden
	level = 1
	icon_state = "manifold-r-f"

/obj/machinery/atmospherics/pipe/manifold/supply/visible
	level = 2
	icon_state = "manifold-b"

/obj/machinery/atmospherics/pipe/manifold/supply/hidden
	level = 1
	icon_state = "manifold-b-f"

/obj/machinery/atmospherics/pipe/manifold/supplymain/visible
	level = 2
	icon_state = "manifold-p"

/obj/machinery/atmospherics/pipe/manifold/supplymain/hidden
	level = 1
	icon_state = "manifold-p-f"

/obj/machinery/atmospherics/pipe/manifold/general/visible
	level = 2
	icon_state = "manifold"

/obj/machinery/atmospherics/pipe/manifold/general/hidden
	level = 1
	icon_state = "manifold-f"

/obj/machinery/atmospherics/pipe/manifold/yellow/visible
	level = 2
	icon_state = "manifold-y"

/obj/machinery/atmospherics/pipe/manifold/yellow/hidden
	level = 1
	icon_state = "manifold-y-f"

/obj/machinery/atmospherics/pipe/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "intact"

	name = "vent"
	desc = "A large air vent"

	level = 1

	volume = 250

	dir = SOUTH
	initialize_directions = SOUTH

	can_unwrench = 0

	var/build_killswitch = 1

	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/vent/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/pipe/vent/process()
	if(!parent)
		if(build_killswitch <= 0)
			. = PROCESS_KILL
		else
			build_killswitch--
		..()
		return
	else
		parent.mingle_with_turf(loc, 250)
/*
	if(!node1)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0
*/
/obj/machinery/atmospherics/pipe/vent/Destroy()
	if(node1)
		node1.disconnect(src)
	..()

/obj/machinery/atmospherics/pipe/vent/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/vent/update_icon()
	if(node1)
		icon_state = "intact"

		dir = get_dir(src, node1)

	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/vent/initialize()
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break

	update_icon()

/obj/machinery/atmospherics/pipe/vent/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	update_icon()

	return null

/obj/machinery/atmospherics/pipe/vent/hide(var/i) //to make the little pipe section invisible, the icon changes.
	if(node1)
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		dir = get_dir(src, node1)
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/tank
	icon = 'icons/obj/atmospherics/pipe_tank.dmi'
	icon_state = "intact"
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."
	volume = 10000 //in liters, 1 meters by 1 meters by 2 meters
	dir = SOUTH
	initialize_directions = SOUTH
	density = 1
	can_unwrench = 0
	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/tank/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide
	name = "pressure tank (Carbon Dioxide)"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C
	air_temporary.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	..()

/obj/machinery/atmospherics/pipe/tank/toxins
	icon = 'icons/obj/atmospherics/orange_pipe_tank.dmi'
	name = "pressure tank (Plasma)"

/obj/machinery/atmospherics/pipe/tank/toxins/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C
	air_temporary.toxins = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	..()

/obj/machinery/atmospherics/pipe/tank/oxygen_agent_b
	icon = 'icons/obj/atmospherics/red_orange_pipe_tank.dmi'
	name = "pressure tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/pipe/tank/oxygen_agent_b/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T0C
	var/datum/gas/oxygen_agent_b/trace_gas = new
	trace_gas.moles = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	air_temporary.trace_gases += trace_gas
	..()

/obj/machinery/atmospherics/pipe/tank/oxygen
	icon = 'icons/obj/atmospherics/blue_pipe_tank.dmi'
	name = "pressure tank (Oxygen)"

/obj/machinery/atmospherics/pipe/tank/oxygen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C
	air_temporary.oxygen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	..()

/obj/machinery/atmospherics/pipe/tank/nitrogen
	icon = 'icons/obj/atmospherics/red_pipe_tank.dmi'
	name = "pressure tank (Nitrogen)"

/obj/machinery/atmospherics/pipe/tank/nitrogen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C
	air_temporary.nitrogen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	..()

/obj/machinery/atmospherics/pipe/tank/air
	icon = 'icons/obj/atmospherics/red_pipe_tank.dmi'
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/pipe/tank/air/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C
	air_temporary.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	air_temporary.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
	..()

/obj/machinery/atmospherics/pipe/tank/Destroy()
	if(node1)
		node1.disconnect(src)
	..()

/obj/machinery/atmospherics/pipe/tank/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/tank/update_icon()
	if(node1)
		icon_state = "intact"
		dir = get_dir(src, node1)
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/tank/initialize()
	var/connect_direction = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break
	update_icon()

/obj/machinery/atmospherics/pipe/tank/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null
	update_icon()