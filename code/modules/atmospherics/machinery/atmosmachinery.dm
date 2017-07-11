/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/
#define PIPE_VISIBLE_LEVEL 2
#define PIPE_HIDDEN_LEVEL 1

/obj/machinery/atmospherics
	anchored = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	on_blueprints = TRUE
	layer = GAS_PIPE_HIDDEN_LAYER //under wires
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	var/nodealert = 0
	var/can_unwrench = 0
	var/initialize_directions = 0
	var/pipe_color

	var/global/list/iconsetids = list()
	var/global/list/pipeimages = list()

	var/image/pipe_vision_img = null

	var/device_type = 0
	var/list/obj/machinery/atmospherics/nodes

/obj/machinery/atmospherics/New(loc, process = TRUE)
	nodes = new(device_type)
	if (!armor)
		armor = list(melee = 25, bullet = 10, laser = 10, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 100, acid = 70)
	..()
	if(process)
		SSair.atmos_machinery += src
	SetInitDirections()

/obj/machinery/atmospherics/Destroy()
	for(DEVICE_TYPE_LOOP)
		nullifyNode(I)

	SSair.atmos_machinery -= src

	dropContents()
	if(pipe_vision_img)
		qdel(pipe_vision_img)

	return ..()
	//return QDEL_HINT_FINDREFERENCE

/obj/machinery/atmospherics/proc/nullifyNode(I)
	if(NODE_I)
		var/obj/machinery/atmospherics/N = NODE_I
		N.disconnect(src)
		NODE_I = null

/obj/machinery/atmospherics/proc/getNodeConnects()
	var/list/node_connects = list()
	node_connects.len = device_type

	for(DEVICE_TYPE_LOOP)
		for(var/D in GLOB.cardinals)
			if(D & GetInitDirections())
				if(D in node_connects)
					continue
				node_connects[I] = D
				break
	return node_connects


//this is called just after the air controller sets up turfs
/obj/machinery/atmospherics/proc/atmosinit(var/list/node_connects)
	if(!node_connects) //for pipes where order of nodes doesn't matter
		node_connects = getNodeConnects()

	for(DEVICE_TYPE_LOOP)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[I]))
			if(can_be_node(target, I))
				NODE_I = target
				break

	update_icon()

/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target)
	if(target.initialize_directions & get_dir(target,src))
		return 1

/obj/machinery/atmospherics/proc/pipeline_expansion()
	return nodes

/obj/machinery/atmospherics/proc/SetInitDirections()
	return

/obj/machinery/atmospherics/proc/GetInitDirections()
	return initialize_directions

/obj/machinery/atmospherics/proc/returnPipenet()
	return

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
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		qdel(P.parent)
	var/I = nodes.Find(reference)
	NODE_I = null
	update_icon()

/obj/machinery/atmospherics/update_icon()
	return

/obj/machinery/atmospherics/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(can_unwrench(user))
			var/turf/T = get_turf(src)
			if (level==1 && isturf(T) && T.intact)
				to_chat(user, "<span class='warning'>You must remove the plating first!</span>")
				return 1
			var/datum/gas_mixture/int_air = return_air()
			var/datum/gas_mixture/env_air = loc.return_air()
			add_fingerprint(user)

			var/unsafe_wrenching = FALSE
			var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()

			playsound(src.loc, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
			if (internal_pressure > 2*ONE_ATMOSPHERE)
				to_chat(user, "<span class='warning'>As you begin unwrenching \the [src] a gush of air blows in your face... maybe you should reconsider?</span>")
				unsafe_wrenching = TRUE //Oh dear oh dear

			if (do_after(user, 20*W.toolspeed, target = src) && !QDELETED(src))
				user.visible_message( \
					"[user] unfastens \the [src].", \
					"<span class='notice'>You unfasten \the [src].</span>", \
					"<span class='italics'>You hear ratchet.</span>")
				investigate_log("was <span class='warning'>REMOVED</span> by [key_name(usr)]", INVESTIGATE_ATMOS)

				//You unwrenched a pipe full of pressure? Let's splat you into the wall, silly.
				if(unsafe_wrenching)
					unsafe_pressure_release(user, internal_pressure)
				deconstruct(TRUE)
	else
		return ..()

/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

// Throws the user when they unwrench a pipe with a major difference between the internal and environmental pressure.
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/user, pressures = null)
	if(!user)
		return
	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	var/fuck_you_dir = get_dir(src, user) // Because fuck you...
	if(!fuck_you_dir)
		fuck_you_dir = pick(GLOB.cardinals)
	var/turf/target = get_edge_target_turf(user, fuck_you_dir)
	var/range = pressures/250
	var/speed = range/5

	user.visible_message("<span class='danger'>[user] is sent flying by pressure!</span>","<span class='userdanger'>The pressure sends you flying!</span>")
	user.throw_at(target, range, speed)

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(can_unwrench)
			var/obj/item/pipe/stored = new(loc, make_from=src)
			if(!disassembled)
				stored.obj_integrity = stored.max_integrity * 0.5
			transfer_fingerprints_to(stored)
	..()

/obj/machinery/atmospherics/proc/getpipeimage(iconset, iconstate, direction, col=rgb(255,255,255))

	//Add identifiers for the iconset
	if(iconsetids[iconset] == null)
		iconsetids[iconset] = num2text(iconsetids.len + 1)

	//Generate a unique identifier for this image combination
	var/identifier = iconsetids[iconset] + "_[iconstate]_[direction]_[col]"

	if((!(. = pipeimages[identifier])))
		var/image/pipe_overlay
		pipe_overlay = . = pipeimages[identifier] = image(iconset, iconstate, dir = direction)
		pipe_overlay.color = col

/obj/machinery/atmospherics/on_construction(pipe_type, obj_color)
	if(can_unwrench)
		add_atom_colour(obj_color, FIXED_COLOUR_PRIORITY)
		pipe_color = obj_color
	var/turf/T = get_turf(src)
	level = T.intact ? 2 : 1
	atmosinit()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmosinit()
		A.addMember(src)
	build_network()

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)


//Find a connecting /obj/machinery/atmospherics in specified direction
/obj/machinery/atmospherics/proc/findConnecting(direction)
	for(var/obj/machinery/atmospherics/target in get_step(src, direction))
		if(target.initialize_directions & get_dir(target,src))
			return target


#define VENT_SOUND_DELAY 30

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	if(!(direction & initialize_directions)) //cant go this way.
		return

	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return

	var/obj/machinery/atmospherics/target_move = findConnecting(direction)
	if(target_move)
		if(target_move.can_crawl_through())
			if(is_type_in_typecache(target_move, GLOB.ventcrawl_machinery))
				user.forceMove(target_move.loc) //handle entering and so on.
				user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>","<span class='notice'>You climb out the ventilation system.")
			else
				var/list/pipenetdiff = returnPipenets() ^ target_move.returnPipenets()
				if(pipenetdiff.len)
					user.update_pipe_vision(target_move)
				user.loc = target_move
				user.client.eye = target_move  //Byond only updates the eye every tick, This smooths out the movement
				if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
					user.last_played_vent = world.time
					playsound(src, 'sound/machines/ventcrawl.ogg', 50, 1, -3)
	else
		if((direction & initialize_directions) || is_type_in_typecache(src, GLOB.ventcrawl_machinery) && can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
			user.forceMove(src.loc)
			user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>","<span class='notice'>You climb out the ventilation system.")
	user.canmove = 0
	spawn(1)
		user.canmove = 1


/obj/machinery/atmospherics/AltClick(mob/living/L)
	if(is_type_in_list(src, GLOB.ventcrawl_machinery))
		L.handle_ventcrawl(src)
		return
	..()


/obj/machinery/atmospherics/proc/can_crawl_through()
	return 1

/obj/machinery/atmospherics/proc/returnPipenets()
	return list()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.sight |= (SEE_TURFS|BLIND)

//Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
/obj/machinery/atmospherics/proc/can_see_pipes()
	return 1

//Properly updates pipes on shuttle movement
/obj/machinery/atmospherics/shuttleRotate(rotation)
	var/list/real_node_connect = getNodeConnects()
	for(DEVICE_TYPE_LOOP)
		real_node_connect[I] = angle2dir(rotation+dir2angle(real_node_connect[I]))

	..()
	SetInitDirections()
	var/list/supposed_node_connect = getNodeConnects()
	var/list/nodes_copy = nodes.Copy()

	for(DEVICE_TYPE_LOOP)
		var/new_pos = supposed_node_connect.Find(real_node_connect[I])
		nodes[new_pos] = nodes_copy[I]

/obj/machinery/atmospherics/afterShuttleMove()
	..()
	var/missing_nodes = FALSE
	for(DEVICE_TYPE_LOOP)
		if(src.nodes[I])
			var/obj/machinery/atmospherics/node = src.nodes[I]
			var/connected = FALSE
			for(var/D in GLOB.cardinals)
				if(node in get_step(src, D))
					connected = TRUE
					break

			if(!connected)
				nullifyNode(I)

		if(!src.nodes[I])
			missing_nodes = TRUE

	if(missing_nodes)
		atmosinit()
		for(var/obj/machinery/atmospherics/A in pipeline_expansion())
			A.atmosinit()
			if(A.returnPipenet())
				A.addMember(src)
		build_network()
	else
		// atmosinit() calls update_icon(), so we don't need to call it
		update_icon()
