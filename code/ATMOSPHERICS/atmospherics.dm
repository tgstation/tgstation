/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

/obj/machinery/atmospherics
	anchored = 1
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/nodealert = 0
	var/can_unwrench = 0
	var/initialize_directions = 0
	var/pipe_color
	var/obj/item/pipe/stored

	var/global/list/iconsetids = list()
	var/global/list/pipeimages = list()
	var/datum/pipeline/parent = null

/obj/machinery/atmospherics/New()
	..()
	SSair.atmos_machinery += src
	SetInitDirections()
	if(can_unwrench)
		stored = new(src, make_from=src)

/obj/machinery/atmospherics/Destroy()
	SSair.atmos_machinery -= src
	if (stored)
		qdel(stored)
	stored = null
	..()

//this is called just after the air controller sets up turfs
/obj/machinery/atmospherics/proc/atmosinit()
	return

//object initializion. done well after air is setup (build_network needs all pipes to be init'ed with atmosinit before hand)
/obj/machinery/atmospherics/initialize()
	..()
	build_network() //make sure to build our pipe nets


/obj/machinery/atmospherics/proc/SetInitDirections()
	return

/obj/machinery/atmospherics/proc/safe_input(var/title, var/text, var/default_set)
	var/new_value = input(usr,text,title,default_set) as num
	if(usr.canUseTopic(src))
		return new_value
	return default_set

/obj/machinery/atmospherics/proc/returnPipenet()
	return parent

/obj/machinery/atmospherics/proc/returnPipenetAir()
	return

/obj/machinery/atmospherics/proc/setPipenet()
	return

/obj/machinery/atmospherics/proc/replacePipenet()
	return

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node
	return

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	return

/obj/machinery/atmospherics/proc/icon_addintact(var/obj/machinery/atmospherics/node, var/connected)
	var/image/img = getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_intact", get_dir(src,node), node.pipe_color)
	underlays += img

	return connected | img.dir

/obj/machinery/atmospherics/proc/icon_addbroken(var/connected)
	var/unconnected = (~connected) & initialize_directions
	for(var/direction in cardinal)
		if(unconnected & direction)
			underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', "pipe_exposed", direction)

/obj/machinery/atmospherics/update_icon()
	return null

/obj/machinery/atmospherics/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob, params)
	if(can_unwrench && istype(W, /obj/item/weapon/wrench))
		var/turf/T = get_turf(src)
		if (level==1 && isturf(T) && T.intact)
			user << "<span class='warning'>You must remove the plating first!</span>"
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		add_fingerprint(user)
		var/unsafe_wrenching = FALSE
		var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user << "<span class='notice'>You begin to unfasten \the [src]...</span>"
		if (internal_pressure > 2*ONE_ATMOSPHERE)
			user << "<span class='warning'>As you begin unwrenching \the [src] a gush of air blows in your face... maybe you should reconsider?</span>"
			unsafe_wrenching = TRUE //Oh dear oh dear
		if (do_after(user, 40) && !gc_destroyed)
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"<span class='notice'>You unfasten \the [src].</span>", \
				"<span class='italics'>You hear ratchet.</span>")
			investigate_log("was <span class='warning'>REMOVED</span> by [key_name(usr)]", "atmos")
			if(unsafe_wrenching)
				unsafe_pressure_release(user,internal_pressure)
			Deconstruct()
	else
		return ..()

/obj/machinery/atmospherics/Deconstruct()
	if(can_unwrench)
		var/turf/T = loc
		stored.loc = T
		transfer_fingerprints_to(stored)
		stored = null

	qdel(src)

/obj/machinery/atmospherics/proc/nullifyPipenet(datum/pipeline/P)
	if(!P)
		return
	P.other_atmosmch -= src

/obj/machinery/atmospherics/proc/getpipeimage(var/iconset, var/iconstate, var/direction, var/col=rgb(255,255,255))

	//Add identifiers for the iconset
	if(iconsetids[iconset] == null)
		iconsetids[iconset] = num2text(iconsetids.len + 1)

	//Generate a unique identifier for this image combination
	var/identifier = iconsetids[iconset] + "_[iconstate]_[direction]_[col]"

	var/image/img
	if(pipeimages[identifier] == null)
		img = image(iconset, icon_state=iconstate, dir=direction)
		img.color = col

		pipeimages[identifier] = img

	else
		img = pipeimages[identifier]

	return img

/obj/machinery/atmospherics/construction(D, P, var/pipe_type, var/obj_color)
	dir = D
	initialize_directions = P
	if(can_unwrench)
		color = obj_color
		pipe_color = obj_color
		stored.dir = D				  //need to define them here, because the obj directions...
		stored.pipe_type = pipe_type  //... were not set at the time the stored pipe was created
		stored.color = obj_color
	var/turf/T = loc
	level = T.intact ? 2 : 1
	atmosinit()
	//initialize()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmosinit()
//		A.initialize()
		A.addMember(src)
	build_network()


//Find a connecting /obj/machinery/atmospherics in specified direction
/obj/machinery/atmospherics/proc/findConnecting(var/direction)
	for(var/obj/machinery/atmospherics/target in get_step(src, direction))
		if(target.initialize_directions & get_dir(target,src))
			return target

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		Deconstruct()


//Called when an atmospherics object is unwrenched while having a large pressure difference
//with it's locs air contents.
/obj/machinery/atmospherics/proc/unsafe_pressure_release(var/mob/user,var/pressures)
	if(!user)
		return

	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure()-env_air.return_pressure()

	var/fuck_you_dir = get_dir(src,user)
	var/turf/general_direction = get_edge_target_turf(user,fuck_you_dir)
	user.visible_message("<span class='danger'>[user] is sent flying by pressure!</span>","<span class='userdanger'>The pressure sends you flying!</span>")
	//Values based on 2*ONE_ATMOS (the unsafe pressure), resulting in 20 range and 4 speed
	user.throw_at(general_direction,pressures/10,pressures/50)