// Regular pipe colors
//                         #RRGGBB
#define PIPE_COLOR_BLUE   "#0000B7"
#define PIPE_COLOR_CYAN   "#00B8B8"
#define PIPE_COLOR_GREEN  "#00B900"
#define PIPE_COLOR_GREY   "#B4B4B4"
#define PIPE_COLOR_PURPLE "#800080"
#define PIPE_COLOR_RED    "#B70000"
#define PIPE_COLOR_ORANGE "#B77900"

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

/obj/machinery/atmospherics/pipe/proc/mass_colouration(var/mass_colour)
	if (findtext(mass_colour,"#"))
		var/datum/pipeline/pipeline = parent
		var/list/update_later = list()
		for(var/obj/machinery/atmospherics/pipe in pipeline.members)
			pipe.color = mass_colour
			if(!pipe.can_be_coloured)
				pipe.default_colour = mass_colour
				update_later += pipe
		for(var/obj/machinery/atmospherics/pipe in pipeline.edges)
			pipe.update_icon()
		update_later -= pipeline.edges
		for(var/obj/machinery/atmospherics/pipe in update_later)
			pipe.update_icon(1)

/obj/machinery/atmospherics/pipe/singularity_pull(/obj/machinery/singularity/S, size)
	return
/obj/machinery/atmospherics/pipe/proc/pipeline_expansion()
	return null


/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return 1 if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null
	return 1

/obj/machinery/atmospherics/pipe/update_icon(var/adjacent_procd)
	if(color && centre_overlay)
		centre_overlay.color = color
		overlays.Cut()
		overlays += centre_overlay
	..()



/obj/machinery/atmospherics/pipe/return_air()
	if(!parent)
		parent = getFromPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.air


/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = getFromPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.return_network()


/obj/machinery/atmospherics/pipe/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(!parent)
		parent = getFromPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.network_expand(new_network, reference)


/obj/machinery/atmospherics/pipe/return_network(obj/machinery/atmospherics/reference)
	if(!parent)
		parent = getFromPool(/datum/pipeline)
		parent.build_pipeline(src)
	return parent.return_network(reference)


/obj/machinery/atmospherics/pipe/Destroy()
	if(parent)
		returnToPool(parent)
	for(var/obj/machinery/meter/M in src.loc)
		if(M.target == src)
			new /obj/item/pipe_meter(src.loc)
			qdel(M)
	if(air_temporary && loc)
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
	color = "#B4B4B4"
	var/maximum_pressure = 100*ONE_ATMOSPHERE // 10132.5 kPa
	var/fatigue_pressure = 80 *ONE_ATMOSPHERE //  8106   kPa
	alert_pressure       = 80 *ONE_ATMOSPHERE
	can_be_coloured = 1
	// Type of burstpipe to use on burst()
	var/burst_type = /obj/machinery/atmospherics/unary/vent/burstpipe

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
		to_chat(usr, "<span class='warning'>There's nothing to connect this pipe section to! A pipe segment must be connected to at least one other object!</span>")
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
		. = ..()
	atmos_machines.Remove(src)

	/*if(!node1)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = 1

	else if(!node2)
		parent.mingle_with_turf(loc, volume)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
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

	// Note: This checks the difference between atmospheric pressure and pressure in the pipe.
	// So, a pipe rated at 8,000 kPa in a 104kPa environment will explode at 8,104kPa.
	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	// Burst check first.
	if(pressure_difference > maximum_pressure && prob(1))
		burst()

	// Groan if that check failed and we're above fatigue pressure
	else if(pressure_difference > fatigue_pressure && prob(1)) // 5 was too often
		groan()

	// Otherwise, continue on.
	else
		return 1

/obj/machinery/atmospherics/pipe/simple/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>This [src.name] is rated up to [format_num(alert_pressure)] kPa.</span>")

/obj/machinery/atmospherics/pipe/simple/proc/groan()
	src.visible_message("<span class='warning'>\The [src] groans from the pressure!</span>");

	// Need SFX for groaning metal.
	//playsound(get_turf(src), 'sound/effects/groan.ogg', 25, 1)


/obj/machinery/atmospherics/pipe/simple/proc/burst()
	src.visible_message("<span class='danger'>\The [src] bursts!</span>");

	var/turf/T=get_turf(src)

	message_admins("Pipe burst in area [formatJumpTo(T)]")
	var/area/A=get_area_master(src)
	log_game("Pipe burst in area [A.name] ")

	// Disconnect first.
	for(var/obj/machinery/atmospherics/node in pipeline_expansion())
		if(node)
			node.disconnect(src)
			node = null

	// Move away from explosion
	loc=null

	if(prob(50))
		explosion(T, -1, 1, 2, adminlog=0)
	else
		explosion(T, 0, 1, 2, adminlog=0)

	// Now connect burstpipes.
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

			var/obj/machinery/atmospherics/unary/vent/burstpipe/BP = new burst_type(T, setdir=direction)
			BP.color=src.color
			BP.invisibility=src.invisibility
			BP.level=src.level
			BP.do_connect()

	del(src) // NOT qdel.


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

	node1 = null
	node2 = null

	..()


/obj/machinery/atmospherics/pipe/simple/pipeline_expansion()
	return list(node1, node2)


/obj/machinery/atmospherics/pipe/simple/update_icon(var/adjacent_procd)
	var/node_list = list(node1,node2)
	if(!node1||!node2)
		icon_state = "exposed"
		..(adjacent_procd,node_list)
	else
		underlays.Cut()
		icon_state = "intact"
		alpha = invisibility ? 128 : 255
		if(!adjacent_procd)
			for(var/obj/machinery/atmospherics/node in node_list)
				if(node.update_icon_ready && !(istype(node,/obj/machinery/atmospherics/pipe/simple)))
					node.update_icon(1)
	if(!node1&&!node2)
		qdel(src) //TODO: silent deleting looks weird

/obj/machinery/atmospherics/pipe/simple/initialize(var/suppress_icon_check=0)
	normalize_dir()

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!suppress_icon_check)
		update_icon()


/obj/machinery/atmospherics/pipe/simple/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node2 = null

	update_icon()
	return null

/obj/machinery/atmospherics/pipe/simple/scrubbers
	name = "Scrubbers pipe"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/supply
	name = "Air supply pipe"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/simple/supplymain
	name = "Main air supply pipe"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/simple/general
	name = "Pipe"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/simple/yellow
	name = "Pipe"
	color=PIPE_COLOR_ORANGE
/obj/machinery/atmospherics/pipe/simple/cyan
	name = "Pipe"
	color=PIPE_COLOR_CYAN
/obj/machinery/atmospherics/pipe/simple/filtering
	name = "Pipe"
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
	name = "\improper Insulated pipe"
	//icon = 'icons/obj/atmospherics/red_pipe.dmi'
	minimum_temperature_difference = 10000
	thermal_conductivity = 0

	maximum_pressure = 1000000 // 1M   kPa
	fatigue_pressure =  900000 // 900k kPa
	alert_pressure   =  900000

	can_be_coloured = 1
	color = IPIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/insulated/visible
	icon_state = "intact"
	level = 2
	color=IPIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/simple/insulated/hidden
	icon_state = "intact"
	alpha=128
	level = 1
	color=IPIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/simple/insulated/hidden/blue
	color= IPIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "map"
	baseicon = "manifold"
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes"
	volume = 105
	color = "#B4B4B4"
	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	level = 1
	layer = 2.4 //under wires with their 2.44
	var/global/image/manifold_centre = image('icons/obj/pipes.dmi',"manifold_centre")

/obj/machinery/atmospherics/pipe/manifold/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1&&!node2&&!node3)
		to_chat(usr, "<span class='warning'>There's nothing to connect this manifold to! A pipe segment must be connected to at least one other object!</span>")
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
	icon_state = "manifold"
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|SOUTH|WEST
		if(SOUTH)
			initialize_directions = WEST|NORTH|EAST
		if(EAST)
			initialize_directions = SOUTH|WEST|NORTH
		if(WEST)
			initialize_directions = NORTH|EAST|SOUTH
	centre_overlay = manifold_centre
	centre_overlay.color = color
	overlays += centre_overlay
	..()


/obj/machinery/atmospherics/pipe/manifold/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/manifold/pipeline_expansion()
	return list(node1, node2, node3)


/obj/machinery/atmospherics/pipe/manifold/process()
	if(!parent)
		. = ..()
	atmos_machines.Remove(src)
	/*
	if(!node1)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = 1
	else if(!node2)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = 1
	else if(!node3)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
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

	node1 = null
	node2 = null
	node3 = null

	..()


/obj/machinery/atmospherics/pipe/manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node3 = null

	update_icon()

	..()



/obj/machinery/atmospherics/pipe/manifold/update_icon(var/adjacent_procd)
	var/node_list = list(node1,node2,node3)
	..(adjacent_procd,node_list)
	if(!node1 && !node2 && !node3)
		qdel(src)


/obj/machinery/atmospherics/pipe/manifold/initialize(var/skip_icon_update=0)
	var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

	findAllConnections(connect_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_icon_update)
		update_icon()

/obj/machinery/atmospherics/pipe/manifold/scrubbers
	name = "\improper Scrubbers pipe"
	color = PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/manifold/supply
	name = "\improper Air supply pipe"
	color = PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold/supplymain
	name = "\improper Main air supply pipe"
	color = PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/manifold/general
	name = "\improper Gas pipe"
	color = PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold/yellow
	name = "\improper Air supply pipe"
	color = PIPE_COLOR_ORANGE
/obj/machinery/atmospherics/pipe/manifold/cyan
	name = "\improper Air supply pipe"
	color = PIPE_COLOR_CYAN
/obj/machinery/atmospherics/pipe/manifold/filtering
	name = "\improper Air filtering pipe"
	color = PIPE_COLOR_GREEN
/obj/machinery/atmospherics/pipe/manifold/insulated
	name = "\improper Insulated pipe"
	//icon = 'icons/obj/atmospherics/red_pipe.dmi'
	icon_state = "manifold"
	alert_pressure = 900*ONE_ATMOSPHERE
	color=IPIPE_COLOR_RED
	level = 2
	can_be_coloured = 1
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
/obj/machinery/atmospherics/pipe/manifold/insulated/visible/blue
	color=IPIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold/insulated/hidden
	level = 1
	color=IPIPE_COLOR_RED
	alpha=128
/obj/machinery/atmospherics/pipe/manifold/insulated/hidden/blue
	color=IPIPE_COLOR_BLUE
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
	icon_state = "map_4way"
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"
	volume = 140
	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST
	color = "#B4B4B4"
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3
	var/obj/machinery/atmospherics/node4
	level = 1
	layer = 2.4 //under wires with their 2.44
	baseicon="manifold4w"
	var/global/image/manifold4w_centre = image('icons/obj/pipes.dmi',"manifold4w_centre")


/obj/machinery/atmospherics/pipe/manifold4w/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!node1 && !node2 && !node3 && !node4)
		to_chat(usr, "<span class='warning'>There's nothing to connect this manifold to! A pipe segment must be connected to at least one other object!</span>")
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

/obj/machinery/atmospherics/pipe/manifold4w/New()
	icon_state = "manifold4w"
	..()
	centre_overlay = manifold4w_centre
	centre_overlay.color = color
	overlays += centre_overlay

/obj/machinery/atmospherics/pipe/manifold4w/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()


/obj/machinery/atmospherics/pipe/manifold4w/pipeline_expansion()
	return list(node1, node2, node3, node4)


/obj/machinery/atmospherics/pipe/manifold4w/process()
	if(!parent)
		. = ..()
	atmos_machines.Remove(src)
	/*
	if(!node1)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = 1
	else if(!node2)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
			nodealert = 1
	else if(!node3)
		parent.mingle_with_turf(loc, 70)
		if(!nodealert)
//			to_chat(world, "Missing node from [src] at [src.x],[src.y],[src.z]")
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

	node1 = null
	node2 = null
	node3 = null
	node4 = null

	..()


/obj/machinery/atmospherics/pipe/manifold4w/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node1 = null

	if(reference == node2)
		if(istype(node2, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node2 = null

	if(reference == node3)
		if(istype(node3, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node3 = null

	if(reference == node4)
		if(istype(node4, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		node4 = null

	update_icon()

	..()


/obj/machinery/atmospherics/pipe/manifold4w/update_icon(var/adjacent_procd)
	var/node_list = list(node1,node2,node3,node4)
	..(adjacent_procd,node_list)
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
	name = "\improper Scrubbers pipe"
	color = PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/manifold4w/supply
	name = "\improper Air supply pipe"
	color = PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/manifold4w/supplymain
	name = "\improper Main air supply pipe"
	color = PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/pipe/manifold4w/general
	name = "\improper Air supply pipe"
	color = PIPE_COLOR_GREY
/obj/machinery/atmospherics/pipe/manifold4w/yellow
	name = "\improper Air supply pipe"
	color = PIPE_COLOR_ORANGE
/obj/machinery/atmospherics/pipe/manifold4w/filtering
	name = "\improper Air filtering pipe"
	color = PIPE_COLOR_GREEN
/obj/machinery/atmospherics/pipe/manifold4w/insulated
	name = "\improper Insulated pipe"
	color = IPIPE_COLOR_RED
	alert_pressure = 900*ONE_ATMOSPHERE
	color=IPIPE_COLOR_RED
	level = 2
	can_be_coloured = 1

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
/obj/machinery/atmospherics/pipe/manifold4w/insulated/visible/blue
	color=IPIPE_COLOR_BLUE


/obj/machinery/atmospherics/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/device/rcd/rpd) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.

	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/red))
		src.color = PIPE_COLOR_RED
		to_chat(user, "<span class='notice'>You paint the pipe red.</span>")
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/blue))
		src.color = PIPE_COLOR_BLUE
		to_chat(user, "<span class='notice'>You paint the pipe blue.</span>")
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/green))
		src.color = PIPE_COLOR_GREEN
		to_chat(user, "<span class='notice'>You paint the pipe green.</span>")
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/yellow))
		src.color = PIPE_COLOR_ORANGE
		to_chat(user, "<span class='notice'>You paint the pipe yellow.</span>")
		update_icon()
		return 1

	if(istype(W, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = W
		user.drop_item(meter, src.loc)
		meter.setAttachLayer(src.piping_layer)

	if(istype(W,/obj/item/device/analyzer))
		var/obj/item/device/analyzer/A = W
		var/datum/gas_mixture/environment = src.return_air()
		user.show_message(A.output_gas_scan(environment,src,1))

	return ..()


/obj/machinery/atmospherics/pipe/layer_manifold
	name = "pipe-layer manifold"

	icon = 'icons/obj/atmospherics/pipe_manifold.dmi'
	icon_state = "manifoldlayer"
	baseicon = "manifoldlayer"

	dir = SOUTH
	initialize_directions = NORTH|SOUTH

	volume = 260 //6 averaged pipe segments

	pipe_flags = ALL_LAYER

	var/list/layer_nodes = list()
	var/obj/machinery/atmospherics/other_node = null

/obj/machinery/atmospherics/pipe/layer_manifold/New()
	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += PIPING_LAYER_INCREMENT)
		layer_nodes.Add(null)
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST
	..()

/obj/machinery/atmospherics/pipe/layer_manifold/setPipingLayer(var/new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!(locate(/obj/machinery/atmospherics) in layer_nodes) && !other_node)
		to_chat(usr, "<span class='warning'>There's nothing to connect this manifold to! A pipe segment must be connected to at least one other object!</span>")
		return 0
	update_icon()
	build_network()
	for(var/obj/machinery/atmospherics/node in layer_nodes)
		node.initialize()
		node.build_network()
	if (other_node)
		other_node.initialize()
		other_node.build_network()
	return 1

/obj/machinery/atmospherics/pipe/layer_manifold/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return layer_nodes + other_node


/obj/machinery/atmospherics/pipe/layer_manifold/process()
	if(!parent)
		. = ..()
	atmos_machines.Remove(src)

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	for(var/obj/machinery/atmospherics/node in layer_nodes)
		node.disconnect(src)
	if(other_node)
		other_node.disconnect(src)
	..()


/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(reference == other_node)
		if(istype(other_node, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		other_node = null

	else
		for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += PIPING_LAYER_INCREMENT)
			if(reference == layer_nodes[pipelayer])
				if(istype(layer_nodes[pipelayer], /obj/machinery/atmospherics/pipe) && !isnull(parent))
					returnToPool(parent)
				layer_nodes[pipelayer] = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/layer_manifold/update_icon()
	overlays.len = 0
	alpha = invisibility ? 128 : 255
	icon_state = baseicon
	if(other_node)
		var/icon/con = new/icon(icon,"manifoldl_other_con")

		overlays += new/image(con, dir = turn(src.dir, 180)) //adds the back connector

	for(var/pipelayer = PIPING_LAYER_MIN; pipelayer <= PIPING_LAYER_MAX; pipelayer += PIPING_LAYER_INCREMENT)
		if(layer_nodes[pipelayer]) //we are connected at this layer

			var/layer_diff = pipelayer - PIPING_LAYER_DEFAULT

			var/image/con = image(icon(src.icon,"manifoldl_con",src.dir))
			con.pixel_x = layer_diff * PIPING_LAYER_P_X
			con.pixel_y = layer_diff * PIPING_LAYER_P_Y

			overlays += con

	if(!other_node && !(locate(/obj/machinery/atmospherics) in layer_nodes))
		qdel(src)
	return


/obj/machinery/atmospherics/pipe/layer_manifold/initialize(var/skip_update_icon=0)

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_update_icon)
		update_icon()

/obj/machinery/atmospherics/pipe/layer_manifold/findAllConnections(var/connect_dirs)
	for(var/direction in cardinal)
		if(connect_dirs & direction)
			if(direction == dir) //we're facing this
				for(var/i = PIPING_LAYER_MIN; i <= PIPING_LAYER_MAX; i += PIPING_LAYER_INCREMENT)
					var/obj/machinery/atmospherics/found
					var/node_type=getNodeType(i)
					switch(node_type)
						if(PIPE_TYPE_STANDARD)
							found = findConnecting(direction, i) //we pass the layer to find the pipe
						if(PIPE_TYPE_HE)
							found = findConnectingHE(direction, i)
						else
							error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([i]): [node_type]")
							return
					if(!found)
						continue
					layer_nodes[i] = found //put it in the list
			else
				var/obj/machinery/atmospherics/found
				var/node_type=getNodeType(direction)
				switch(node_type)
					if(PIPE_TYPE_STANDARD)
						found = findConnecting(direction)
					if(PIPE_TYPE_HE)
						found = findConnectingHE(direction)
					else
						error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([direction]): [node_type]")
				if(!found)
					continue
				other_node = found

/obj/machinery/atmospherics/pipe/layer_manifold/isConnectable(var/obj/machinery/atmospherics/target, var/direction, var/given_layer)
	if(direction == turn(src.dir, 180))
		return (given_layer == PIPING_LAYER_DEFAULT)
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/getNodeType()
	return PIPE_TYPE_STANDARD

//We would normally set layer here, but I don't want to
/obj/machinery/atmospherics/pipe/layer_manifold/Entered()
	return

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, direction)
	if(!(direction & initialize_directions)) //can't go in a way we aren't connecting to
		var/layer_mod = 0

		if(dir & (NORTH|SOUTH))
			if(direction == EAST) //Going up in layers
				layer_mod = 1
			else
				layer_mod = -1
		else
			if(direction == SOUTH) //
				layer_mod = 1
			else
				layer_mod = -1

		user.ventcrawl_layer = Clamp(user.ventcrawl_layer + layer_mod, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
		to_chat(user, "You align yourself with the [user.ventcrawl_layer]\th output.")
		return 1
	else
		if(direction != dir && user.ventcrawl_layer != PIPING_LAYER_DEFAULT) // The mob is moving to the single pipe outlet, we need to align it if it's on a layer that's not the default layer
			user.ventcrawl_layer = PIPING_LAYER_DEFAULT
			to_chat(user, "You are redirected into the [user.ventcrawl_layer]\th piping layer.")
		
		return ..()


/obj/machinery/atmospherics/pipe/layer_adapter
	name = "pipe-layer adapter"

	icon = 'icons/obj/atmospherics/pipe_adapter.dmi'
	icon_state = "adapter_1"
	baseicon = "adapter"

	color = PIPE_COLOR_GREY

	dir = SOUTH
	initialize_directions = NORTH|SOUTH

	volume = 260 //6 averaged pipe segments

	pipe_flags = ALL_LAYER

	var/obj/machinery/atmospherics/layer_node = null
	var/obj/machinery/atmospherics/mid_node = null

/obj/machinery/atmospherics/pipe/layer_adapter/New()
	..()
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_adapter/setPipingLayer(var/new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer

/obj/machinery/atmospherics/pipe/layer_adapter/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize(1)
	if(!mid_node && !layer_node)
		to_chat(usr, "<span class='warning'>There's nothing to connect this adapter to! A pipe segment must be connected to at least one other object!</span>")
		return 0
	update_icon()
	build_network()
	if (mid_node)
		mid_node.initialize()
		mid_node.build_network()
	if (layer_node)
		layer_node.initialize()
		layer_node.build_network()
	return 1

/obj/machinery/atmospherics/pipe/layer_adapter/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/pipe/layer_adapter/pipeline_expansion()
	return list(layer_node, mid_node)


/obj/machinery/atmospherics/pipe/layer_adapter/process()
	if(!parent)
		. = ..()
	atmos_machines.Remove(src)

/obj/machinery/atmospherics/pipe/layer_adapter/Destroy()
	if(mid_node)
		mid_node.disconnect(src)
	if(layer_node)
		layer_node.disconnect(src)
	..()


/obj/machinery/atmospherics/pipe/layer_adapter/disconnect(var/obj/machinery/atmospherics/reference)
	if(reference == mid_node)
		if(istype(mid_node, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		mid_node = null
	if(reference == layer_node)
		if(istype(layer_node, /obj/machinery/atmospherics/pipe) && !isnull(parent))
			returnToPool(parent)
		layer_node = null

	update_icon()

	..()

/obj/machinery/atmospherics/pipe/layer_adapter/update_icon()
	overlays.len = 0
	alpha = invisibility ? 128 : 255
	icon_state = "[baseicon]_[piping_layer]"
	if(layer_node)
		var/layer_diff = piping_layer - PIPING_LAYER_DEFAULT

		var/image/con = image(icon(src.icon,"layer_con",turn(src.dir,180)))
		con.pixel_x = layer_diff * PIPING_LAYER_P_X
		con.pixel_y = layer_diff * PIPING_LAYER_P_Y

		overlays += con
	if(!mid_node && !layer_node)
		qdel(src)
	return


/obj/machinery/atmospherics/pipe/layer_adapter/initialize(var/skip_update_icon=0)

	findAllConnections(initialize_directions)

	var/turf/T = src.loc			// hide if turf is not intact
	hide(T.intact)
	if(!skip_update_icon)
		update_icon()

/obj/machinery/atmospherics/pipe/layer_adapter/findAllConnections(var/connect_dirs)
	for(var/direction in cardinal)
		if(connect_dirs & direction)
			if(direction == dir) //we're facing this
				var/obj/machinery/atmospherics/found
				var/node_type=getNodeType(direction)
				switch(node_type)
					if(PIPE_TYPE_STANDARD)
						found = findConnecting(direction, PIPING_LAYER_DEFAULT)
					if(PIPE_TYPE_HE)
						found = findConnectingHE(direction, PIPING_LAYER_DEFAULT)
					else
						error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([direction]): [node_type]")
				if(!found)
					continue
				mid_node = found
			else
				var/obj/machinery/atmospherics/found
				var/node_type=getNodeType(direction)
				switch(node_type)
					if(PIPE_TYPE_STANDARD)
						found = findConnecting(direction, piping_layer) //we pass the layer to find the pipe
					if(PIPE_TYPE_HE)
						found = findConnectingHE(direction, piping_layer)
					else
						error("UNKNOWN RESPONSE FROM [src.type]/getNodeType([piping_layer]): [node_type]")
						return
				if(!found)
					continue
				layer_node = found

/obj/machinery/atmospherics/pipe/layer_adapter/isConnectable(var/obj/machinery/atmospherics/target, var/direction, var/given_layer)
	if(direction == dir)
		return (given_layer == PIPING_LAYER_DEFAULT)
	return ..()

/obj/machinery/atmospherics/pipe/layer_adapter/getNodeType()
	return PIPE_TYPE_STANDARD

//We would normally set layer here, but I don't want to
/obj/machinery/atmospherics/pipe/layer_adapter/Entered()
	return

/obj/machinery/atmospherics/pipe/layer_adapter/relaymove(mob/living/user, direction)
	// Autoset layer
	if(direction & initialize_directions)
		user.ventcrawl_layer = (direction == dir) ? PIPING_LAYER_DEFAULT : piping_layer
		to_chat(user, "You are redirected into the [user.ventcrawl_layer]\th piping layer.")
		return ..()