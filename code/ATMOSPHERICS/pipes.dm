
// Regular pipe colors
//                         #RRGGBB
#define PIPE_COLOR_BLUE   "#0000FF"
#define PIPE_COLOR_CYAN   "#00FFFF"
#define PIPE_COLOR_GREEN  "#00FF00"
#define PIPE_COLOR_GREY   "#FFFFFF" // White
#define PIPE_COLOR_PURPLE "#800080"
#define PIPE_COLOR_RED    "#FF0000"
#define PIPE_COLOR_YELLOW "#FFA800" // Orange, actually. Yellow looked awful.

// Insulated pipes
#define IPIPE_COLOR_RED   PIPE_COLOR_RED
#define IPIPE_COLOR_BLUE  "#4285F4"

/obj/machinery/atmospherics/pipe
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	force = 20
	layer = 2.4 //under wires with their 2.44
	use_power = 0
	var/alert_pressure = 80*ONE_ATMOSPHERE
	var/baseicon=""

	available_colors = list(
		"grey"=PIPE_COLOR_GREY,
		"red"=PIPE_COLOR_RED,
		"blue"=PIPE_COLOR_BLUE,
		"cyan"=PIPE_COLOR_CYAN,
		"green"=PIPE_COLOR_GREEN,
		"yellow"=PIPE_COLOR_YELLOW,
		"purple"=PIPE_COLOR_PURPLE
	)

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
	if(air_temporary)
		loc.assume_air(air_temporary)

	..()

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/pipes.dmi'
	icon_state = "intact"
	name = "pipe"
	desc = "A one meter section of regular pipe"
	volume = 70
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	var/maximum_pressure = 100*ONE_ATMOSPHERE // 10132.5 kPa
	var/fatigue_pressure = 80 *ONE_ATMOSPHERE //  8106   kPa
	alert_pressure       = 80 *ONE_ATMOSPHERE

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


/obj/machinery/atmospherics/pipe/simple/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1&&!node2)
		usr << "\red There's nothing to connect this pipe section to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
		return 0
	update_icon()
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	return 1


/obj/machinery/atmospherics/pipe/simple/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/simple/process()
	if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
		..()
	else
		. = PROCESS_KILL

	/*if(!node1)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1

	else if(!node2)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0


	else if(parent)
		var/environment_temperature = 0

		if(istype(loc, /turf/simulated/))
			if(loc:blocks_air)
				environment_temperature = loc:temperature
			else
				var/datum/gas_mixture/environment = loc.return_air()
				environment_temperature = environment.temperature

		else
			environment_temperature = loc:temperature

		var/datum/gas_mixture/pipe_air = return_air()

		if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
			parent.temperature_interact(loc, volume, thermal_conductivity)
	*/


/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	if(!loc)
		return
	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	if(pressure_difference > maximum_pressure && prob(25))
		burst()
	else if(pressure_difference > fatigue_pressure && prob(5))
		groan()
	else
		return 1

/obj/machinery/atmospherics/pipe/simple/examine()
	..()
	usr << "<span class='info'>This [src.name] is rated up to [format_num(alert_pressure)] kPa.</span>"

/obj/machinery/atmospherics/pipe/simple/proc/groan()
	src.visible_message("<span class='warning'>\The [src] groans from the pressure!</span>");

	// Need SFX for groaning metal.
	//playsound(get_turf(src), 'sound/effects/groan.ogg', 25, 1)


/obj/machinery/atmospherics/pipe/simple/proc/burst()
	src.visible_message("<span class='danger'>\The [src] bursts!</span>");

	message_admins("Pipe burst in area [formatJumpTo(src.loc)]")
	var/area/A=get_area_master(src)
	log_game("Pipe burst in area [A.name] ")

	var/node_id=0
	for(var/direction in cardinal)
		if(initialize_directions & direction)
			node_id++
			var/obj/machinery/atmospherics/found
			var/node_type=getNodeType(node_id)
			switch(node_type)
				if(PIPE_TYPE_STANDARD)
					found = findConnecting(direction)
				if(PIPE_TYPE_HE)
					found = findConnectingHE(direction)
				else
					error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([node_id]): [node_type]")
					return
			if(!found) continue
			//var/node_var="node[node_id]" // For debugging.
			var/obj/machinery/atmospherics/pipe/vent/burstpipe/BP = new (loc, setdir=direction)
			BP.color=src.color
			BP.invisibility=src.invisibility
			BP.level=src.level
			BP.initialize()
			BP.update_icon()
			BP.build_network()

	if(prob(50))
		explosion(get_turf(src), -1, 1, 2, adminlog=0)
	else
		explosion(get_turf(src), 0, 1, 2, adminlog=0)

	if(src && src.loc!=null)
		qdel(src)
	/*
	playsound(get_turf(src), 'sound/effects/bang.ogg', 25, 1)
	var/datum/effect/effect/system/smoke_spread/smoke = new
	smoke.set_up(1,0, src.loc, 0)
	smoke.start()
	qdel(src)
	*/


/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==3)
		dir = 1
	else if(dir==12)
		dir = 4


/obj/machinery/atmospherics/pipe/simple/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)

	..()


/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)


/obj/machinery/atmospherics/pipe/simple/update_icon()
	alpha = invisibility ? 128 : 255
	color = available_colors[_color]
	if(node1&&node2)
		icon_state = "intact"

	else
		if(!node1&&!node2)
			qdel(src) //TODO: silent deleting looks weird
		var/have_node1 = node1?1:0
		var/have_node2 = node2?1:0
		icon_state = "exposed[have_node1][have_node2]"


/obj/machinery/atmospherics/pipe/simple/initialize(var/suppress_icon_check=0)
	normalize_dir()

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!suppress_icon_check)
		update_icon()


/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			del(parent)
		node2 = null

	update_icon()
	return null

/obj/machinery/atmospherics/pipe/simple/scrubbers
	name = "Scrubbers pipe"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/supply
	name = "Air supply pipe"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/simple/supplymain
	name = "Main air supply pipe"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/simple/general
	name = "Pipe"
	_color = "grey"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/simple/yellow
	name = "Pipe"
	_color="yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/pipe/simple/cyan
	name = "Pipe"
	_color="cyan"
	color=PIPE_COLOR_CYAN
/obj/machinery/atmospherics/pipe/simple/filtering
	name = "Pipe"
	_color = "green"
	color=PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/supply/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/supplymain/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/supplymain/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/general/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/general/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/yellow/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/yellow/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/cyan/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/cyan/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/filtering/visible
	level = 2
/obj/machinery/atmospherics/pipe/simple/filtering/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/simple/insulated
	name = "Insulated pipe"
	//icon = 'icons/obj/atmospherics/red_pipe.dmi'
	icon = 'icons/obj/atmospherics/insulated.dmi'
	minimum_temperature_difference = 10000
	thermal_conductivity = 0

	maximum_pressure = 1000000 // 1M   kPa
	fatigue_pressure =  900000 // 900k kPa
	alert_pressure   =  900000

	available_colors = list(
		"red"=IPIPE_COLOR_RED,
		"blue"=IPIPE_COLOR_BLUE
	)
	_color = "red"
/obj/machinery/atmospherics/pipe/simple/insulated/visible
	icon_state = "intact"
	level = 2
	color=IPIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/simple/insulated/hidden
	icon_state = "intact"
	alpha=128
	level = 1
	color=IPIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/insulated/hidden/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"

/obj/machinery/atmospherics/pipe/tank
	icon = 'icons/obj/atmospherics/pipe_tank.dmi'
	icon_state = "intact"
	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."
	volume = 2000 //in liters, 1 meters by 1 meters by 2 meters
	dir = SOUTH
	initialize_directions = SOUTH
	density = 1
	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/tank/New()
	initialize_directions = dir
	..()


/obj/machinery/atmospherics/pipe/tank/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL
	/*			if(!node1)
		parent.mingle_with_turf(loc, 200)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0
	*/

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/obj/machinery/atmospherics/pipe/tank/toxins
	icon = 'icons/obj/atmospherics/orange_pipe_tank.dmi'
	name = "Pressure Tank (Plasma)"

/obj/machinery/atmospherics/pipe/tank/toxins/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.toxins = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/obj/machinery/atmospherics/pipe/tank/oxygen_agent_b
	icon = 'icons/obj/atmospherics/red_orange_pipe_tank.dmi'
	name = "Pressure Tank (Oxygen + Plasma)"

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
	name = "Pressure Tank (Oxygen)"

/obj/machinery/atmospherics/pipe/tank/oxygen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.oxygen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/obj/machinery/atmospherics/pipe/tank/nitrogen
	icon = 'icons/obj/atmospherics/red_pipe_tank.dmi'
	name = "Pressure Tank (Nitrogen)"

/obj/machinery/atmospherics/pipe/tank/nitrogen/New()
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.nitrogen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

	..()

/obj/machinery/atmospherics/pipe/tank/air
	icon = 'icons/obj/atmospherics/red_pipe_tank.dmi'
	name = "Pressure Tank (Air)"

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

	node1=findConnecting(connect_direction)

	update_icon()


/obj/machinery/atmospherics/pipe/tank/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	update_icon()

	return null


/obj/machinery/atmospherics/pipe/tank/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/pipe_dispenser) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.
	if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1)
		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used the analyzer on \icon[icon]"

		var/pressure = parent.air.return_pressure()
		var/total_moles = parent.air.total_moles()

		user << "\blue Results of analysis of \icon[icon]"
		if (total_moles>0)
			var/o2_concentration = parent.air.oxygen/total_moles
			var/n2_concentration = parent.air.nitrogen/total_moles
			var/co2_concentration = parent.air.carbon_dioxide/total_moles
			var/plasma_concentration = parent.air.toxins/total_moles

			var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

			user << "\blue Pressure: [round(pressure,0.1)] kPa"
			user << "\blue Nitrogen: [round(n2_concentration*100)]%"
			user << "\blue Oxygen: [round(o2_concentration*100)]%"
			user << "\blue CO2: [round(co2_concentration*100)]%"
			user << "\blue Plasma: [round(plasma_concentration*100)]%"
			if(unknown_concentration>0.01)
				user << "\red Unknown: [round(unknown_concentration*100)]%"
			user << "\blue Temperature: [round(parent.air.temperature-T0C)]&deg;C"
		else
			user << "\blue Tank is empty!"

/obj/machinery/atmospherics/pipe/vent
	icon = 'icons/obj/atmospherics/pipe_vent.dmi'
	icon_state = "intact"
	name = "Vent"
	desc = "A large air vent"
	level = 1
	volume = 250
	dir = SOUTH
	initialize_directions = SOUTH
	var/build_killswitch = 1
	var/obj/machinery/atmospherics/node1

/obj/machinery/atmospherics/pipe/vent/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/pipe/vent/high_volume
	name = "Larger vent"
	volume = 1000

/obj/machinery/atmospherics/pipe/vent/process()
	if(!parent)
		if(build_killswitch <= 0)
			. = PROCESS_KILL
		else
			build_killswitch--
		..()
		return
	else
		parent.mingle_with_turf(loc, volume)
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

	node1=findConnecting(connect_direction)

	update_icon()


/obj/machinery/atmospherics/pipe/vent/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	update_icon()

	return null


/obj/machinery/atmospherics/pipe/vent/hide(var/i)
	if(node1)
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
		dir = get_dir(src, node1)
	else
		icon_state = "exposed"

/obj/machinery/atmospherics/pipe/vent/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	if (pipe.pipename)
		name = pipe.pipename
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize()
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	return 1

/obj/machinery/atmospherics/pipe/vent/attackby(var/obj/item/weapon/W, var/mob/user)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = T.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
		add_fingerprint(user)
		return 1
	playsound(T, 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You begin to unfasten \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"\blue You have unfastened \the [src].", \
			"You hear ratchet.")
		new /obj/item/pipe(T, make_from=src)
		del(src)

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "manifold"
	baseicon = "manifold"
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

/obj/machinery/atmospherics/pipe/manifold/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1&&!node2&&!node3)
		usr << "\red There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
		return 0
	update_icon() // Skipped in initialize()!
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	if (node3)
		node3.initialize()
		node3.build_network()
	return 1


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


/obj/machinery/atmospherics/pipe/manifold/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)


/obj/machinery/atmospherics/pipe/manifold/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL
	/*
	if(!node1)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node2)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node3)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0
	*/


/obj/machinery/atmospherics/pipe/manifold/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	if(node3)
		node3.disconnect(src)

	..()


/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			del(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			del(parent)
		node3 = null

	update_icon()

	..()


/obj/machinery/atmospherics/pipe/manifold/update_icon()
	alpha = invisibility ? 128 : 255
	color = available_colors[_color]
	overlays = 0
	if(node1&&node2&&node3)
		icon_state="manifold"
	else
		icon_state = "[baseicon]_ex"
		var/icon/con = new/icon(icon,"[baseicon]_con") //Since 4-ways are supposed to be directionless, they need an overlay instead it seems.

		if(node1)
			overlays += new/image(con,dir=get_dir(src, node1))
		if(node2)
			overlays += new/image(con,dir=get_dir(src, node2))
		if(node3)
			overlays += new/image(con,dir=get_dir(src, node3))

		if(!node1 && !node2 && !node3)
			qdel(src)

	return


/obj/machinery/atmospherics/pipe/manifold/initialize(var/skip_icon_update=0)
	var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

	findAllConnections(connect_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_icon_update)
		update_icon()

/obj/machinery/atmospherics/pipe/manifold/scrubbers
	name = "Scrubbers pipe"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/manifold/supply
	name = "Air supply pipe"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold/supplymain
	name = "Main air supply pipe"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/manifold/general
	name = "Gas pipe"
	_color = "gray"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/manifold/yellow
	name = "Air supply pipe"
	_color = "yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/pipe/manifold/cyan
	name = "Air supply pipe"
	_color = "cyan"
	color=PIPE_COLOR_CYAN
/obj/machinery/atmospherics/pipe/manifold/filtering
	name = "Air filtering pipe"
	_color = "green"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/pipe/manifold/insulated
	name = "Insulated pipe"
	//icon = 'icons/obj/atmospherics/red_pipe.dmi'
	icon = 'icons/obj/atmospherics/insulated.dmi'
	icon_state = "manifold"
	alert_pressure = 900*ONE_ATMOSPHERE
	level = 2
	available_colors = list(
		"red"=IPIPE_COLOR_RED,
		"blue"=IPIPE_COLOR_BLUE
	)
/obj/machinery/atmospherics/pipe/manifold/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/scrubbers/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/supply/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/supplymain/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/supplymain/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/general/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/general/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/insulated/visible
	level = 2
	color=IPIPE_COLOR_RED
	_color = "red"
/obj/machinery/atmospherics/pipe/manifold/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/manifold/insulated/hidden
	level = 1
	color=IPIPE_COLOR_RED
	alpha=128
	_color = "red"
/obj/machinery/atmospherics/pipe/manifold/insulated/hidden/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/manifold/yellow/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/yellow/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/cyan/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/cyan/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/filtering/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold/filtering/hidden
	level = 1
	alpha=128

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "manifold4w"
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"
	volume = 140
	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4
	level = 1
	layer = 2.4 //under wires with their 2.44
	baseicon="manifold4w"

/obj/machinery/atmospherics/pipe/manifold4w/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1 && !node2 && !node3 && !node4)
		usr << "\red There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
		return 0
	update_icon()
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	if (node2)
		node2.initialize()
		node2.build_network()
	if (node3)
		node3.initialize()
		node3.build_network()
	if (node4)
		node4.initialize()
		node4.build_network()
	return 1


/obj/machinery/atmospherics/pipe/manifold4w/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)


/obj/machinery/atmospherics/pipe/manifold4w/process()
	if(!parent)
		..()
	else
		. = PROCESS_KILL
	/*
	if(!node1)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node2)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if(!node3)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
			//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
			nodealert = 1
	else if (nodealert)
		nodealert = 0
	*/


/obj/machinery/atmospherics/pipe/manifold4w/Destroy()
	if(node1)
		node1.disconnect(src)
	if(node2)
		node2.disconnect(src)
	if(node3)
		node3.disconnect(src)
	if(node4)
		node4.disconnect(src)

	..()


/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			del(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe))
			del(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe))
			del(parent)
		node3 = null

	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe))
			del(parent)
		node4 = null

	update_icon()

	..()


/obj/machinery/atmospherics/pipe/manifold4w/update_icon()
	overlays=0
	alpha = invisibility ? 128 : 255
	color = available_colors[_color]
	if(node1&&node2&&node3&&node4)
		icon_state = "[baseicon]"
	else
		icon_state = "[baseicon]_ex"
		var/icon/con = new/icon(icon,"[baseicon]_con") //Since 4-ways are supposed to be directionless, they need an overlay instead it seems.

		if(node1)
			overlays += new/image(con,dir=1)
		if(node2)
			overlays += new/image(con,dir=2)
		if(node3)
			overlays += new/image(con,dir=4)
		if(node4)
			overlays += new/image(con,dir=8)

		if(!node1 && !node2 && !node3 && !node4)
			qdel(src)
	return


/obj/machinery/atmospherics/pipe/manifold4w/initialize(var/skip_update_icon=0)

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_update_icon)
		update_icon()

/obj/machinery/atmospherics/pipe/manifold4w/scrubbers
	name = "Scrubbers pipe"
	_color = "red"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/manifold4w/supply
	name = "Air supply pipe"
	_color = "blue"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold4w/supplymain
	name = "Main air supply pipe"
	_color = "purple"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/manifold4w/general
	name = "Air supply pipe"
	_color = "gray"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/manifold4w/yellow
	name = "Air supply pipe"
	_color = "yellow"
	color=PIPE_COLOR_YELLOW
/obj/machinery/atmospherics/pipe/manifold4w/filtering
	name = "Air filtering pipe"
	_color = "green"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/pipe/manifold4w/insulated
	icon = 'icons/obj/atmospherics/insulated.dmi'
	name = "Insulated pipe"
	_color = "red"
	alert_pressure = 900*ONE_ATMOSPHERE
	color=IPIPE_COLOR_RED
	level = 2
	available_colors = list(
		"red"=IPIPE_COLOR_RED,
		"blue"=IPIPE_COLOR_BLUE
	)
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/supplymain/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/supplymain/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/general/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/general/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/filtering/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/filtering/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/yellow/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/yellow/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/insulated/hidden
	level = 1
	alpha=128
/obj/machinery/atmospherics/pipe/manifold4w/insulated/visible
	level = 2
/obj/machinery/atmospherics/pipe/manifold4w/insulated/hidden/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"
/obj/machinery/atmospherics/pipe/manifold4w/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
	_color = "blue"


/obj/machinery/atmospherics/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/pipe_dispenser) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.
	if (istype(src, /obj/machinery/atmospherics/pipe/tank))
		return ..()
	if (istype(src, /obj/machinery/atmospherics/pipe/vent))
		return ..()

	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/red))
		src._color = "red"
		src.color = PIPE_COLOR_RED
		user << "\red You paint the pipe red."
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/blue))
		src._color = "blue"
		src.color = PIPE_COLOR_BLUE
		user << "\red You paint the pipe blue."
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/green))
		src._color = "green"
		src.color = PIPE_COLOR_GREEN
		user << "\red You paint the pipe green."
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/yellow))
		src._color = "yellow"
		src.color = PIPE_COLOR_YELLOW
		user << "\red You paint the pipe yellow."
		update_icon()
		return 1

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = src.loc
	if (level==1 && isturf(T) && T.intact)
		user << "<span class='warning'>You must remove the plating first.</span>"
		return 1
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	add_fingerprint(user)
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		if(istype(W, /obj/item/weapon/wrench/socket))
			user << "<span class='warning'>You begin to open the pressure release valve on the pipe...</span>"
			if(do_after(user, 50))
				playsound(get_turf(src), 'sound/machines/hiss.ogg', 50, 1)
				user.visible_message("[user] vents \the [src].",
									"You have vented \the [src].",
									"You hear a ratchet.")
				var/datum/gas_mixture/transit = new
				transit.add(int_air)
				transit.divide(parent.members.len) //we get the total pressure over the number of pipes to find gas per pipe
				env_air.add(transit) //put it in the air
				del(transit) //remove the carrier
		else
			user << "<span class='warning'>You cannot unwrench this [src], it too exerted due to internal pressure.</span>"
			return 1
	playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
	user << "<span class='notice'>You begin to unfasten \the [src]...</span>"
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear a ratchet.")
		new /obj/item/pipe(loc, make_from=src)
		for (var/obj/machinery/meter/meter in T)
			if (meter.target == src)
				new /obj/item/pipe_meter(T)
				del(meter)
		qdel(src)
