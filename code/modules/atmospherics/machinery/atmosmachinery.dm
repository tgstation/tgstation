// Quick overview:
//
// Pipes combine to form pipelines
// Pipelines and other atmospheric objects combine to form pipe_networks
//   Note: A single pipe_network represents a completely open space
//
// Pipes -> Pipelines
// Pipelines + Other Objects -> Pipe network

#define PIPE_VISIBLE_LEVEL 2
#define PIPE_HIDDEN_LEVEL 1

/obj/machinery/atmospherics
	anchored = TRUE
	move_resist = INFINITY //Moving a connected machine without actually doing the normal (dis)connection things will probably cause a LOT of issues. (this imply moving machines with something that can push turfs like a megafauna)
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = AREA_USAGE_ENVIRON
	layer = GAS_PIPE_HIDDEN_LAYER //under wires
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	///Check if the object can be unwrenched
	var/can_unwrench = FALSE
	///Bitflag of the initialized directions (NORTH | SOUTH | EAST | WEST)
	var/initialize_directions = 0
	///The color of the pipe
	var/pipe_color
	///What layer the pipe is in (from 1 to 5, default 3)
	var/piping_layer = PIPING_LAYER_DEFAULT
	///The flags of the pipe/component (PIPING_ALL_LAYER | PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY | PIPING_CARDINAL_AUTONORMALIZE)
	var/pipe_flags = NONE

	///This only works on pipes, because they have 1000 subtypes wich need to be visible and invisible under tiles, so we track this here
	var/hide = TRUE

	///Identifiers for the iconset, the path where the image will be taken from
	var/static/list/iconsetids = list()
	///The unique identifier created from the iconsetids, the parameters are then used to define the pipe image (icon, icon_state, color, direction, piping_layer)
	var/static/list/pipeimages = list()
	///The image of the pipe/device used for ventcrawling
	var/image/pipe_vision_img = null

	///The type of the device (UNARY, BINARY, TRINARY, QUATERNARY)
	var/device_type = 0
	///The lists of nodes that a pipe/device has, depends on the device_type var (from 1 to 4)
	var/list/obj/machinery/atmospherics/nodes

	///The path of the pipe/device that will spawn after unwrenching it (such as pipe fittings)
	var/construction_type
	///icon_state as a pipe item
	var/pipe_state
	///Check if the device should be on or off (mostly used in processing for machines)
	var/on = FALSE

	///Whether it can be painted
	var/paintable = FALSE

/obj/machinery/atmospherics/examine(mob/user)
	. = ..()
	if(is_type_in_list(src, GLOB.ventcrawl_machinery) && isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_VENTCRAWLER_NUDE) || HAS_TRAIT(L, TRAIT_VENTCRAWLER_ALWAYS))
			. += "<span class='notice'>Alt-click to crawl through it.</span>"

/obj/machinery/atmospherics/New(loc, process = TRUE, setdir)
	if(!isnull(setdir))
		setDir(setdir)
	if(pipe_flags & PIPING_CARDINAL_AUTONORMALIZE)
		normalize_cardinal_directions()
	nodes = new(device_type)
	if (!armor)
		armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 100, ACID = 70)
	..()
	if(process)
		SSair.start_processing_machine(src)
	SetInitDirections()

/obj/machinery/atmospherics/Destroy()
	for(var/i in 1 to device_type)
		nullifyNode(i)

	SSair.stop_processing_machine(src)
	SSair.pipenets_needing_rebuilt -= src

	if(pipe_vision_img)
		qdel(pipe_vision_img)

	return ..()
	//return QDEL_HINT_FINDREFERENCE

/**
 * Called by the machinery disconnect(), custom for each type
 */
/obj/machinery/atmospherics/proc/destroy_network()
	return

/**
 * Called by all machines when on_construction() is called, it builds the network for the node
 */
/obj/machinery/atmospherics/proc/build_network()
	return

/**
 * Called on destroy(mostly deconstruction) and when moving nodes around, disconnect the nodes from the network
 * Arguments:
 * * i - is the current iteration of the node, based on the device_type (from 1 to 4)
 */
/obj/machinery/atmospherics/proc/nullifyNode(i)
	if(nodes[i])
		var/obj/machinery/atmospherics/N = nodes[i]
		N.disconnect(src)
		nodes[i] = null

/**
 * Getter for node_connects
 *
 * Return a list of the nodes that can connect to other machines, get called by atmosinit()
 */
/obj/machinery/atmospherics/proc/getNodeConnects()
	var/list/node_connects = list()
	node_connects.len = device_type

	for(var/i in 1 to device_type)
		for(var/D in GLOB.cardinals)
			if(D & GetInitDirections())
				if(D in node_connects)
					continue
				node_connects[i] = D
				break
	return node_connects

/**
 * Setter for device direction
 *
 * Set the direction to either SOUTH or WEST if the pipe_flag is set to PIPING_CARDINAL_AUTONORMALIZE, called in New(), used mostly by layer manifolds
 */
/obj/machinery/atmospherics/proc/normalize_cardinal_directions()
	switch(dir)
		if(SOUTH)
			setDir(NORTH)
		if(WEST)
			setDir(EAST)

/**
 * Initialize for atmos devices
 *
 * initialize the nodes for each pipe/device, this is called just after the air controller sets up turfs
 * Arguments:
 * * list/node_connects - a list of the nodes on the device that can make a connection to other machines
 */
/obj/machinery/atmospherics/proc/atmosinit(list/node_connects)
	if(!node_connects) //for pipes where order of nodes doesn't matter
		node_connects = getNodeConnects()

	for(var/i in 1 to device_type)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[i]))
			if(can_be_node(target, i))
				nodes[i] = target
				break
	update_appearance()

/**
 * setter for pipe layers
 *
 * Set the layer of the pipe that the device has to a new_layer
 * Arguments:
 * * new_layer - the layer at which we want the piping_layer to be (1 to 5)
 */
/obj/machinery/atmospherics/proc/setPipingLayer(new_layer)
	piping_layer = (pipe_flags & PIPING_DEFAULT_LAYER_ONLY) ? PIPING_LAYER_DEFAULT : new_layer
	update_appearance()

/obj/machinery/atmospherics/update_icon()
	layer = initial(layer) + piping_layer / 1000
	return ..()

/**
 * Check if a node can actually exists by connecting to another machine
 * called on atmosinit()
 * Arguments:
 * * obj/machinery/atmospherics/target - the machine we are connecting to
 * * iteration - the current node we are checking (from 1 to 4)
 */
/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target, iteration)
	return connection_check(target, piping_layer)

/**
 * Find a connecting /obj/machinery/atmospherics in specified direction, called by relaymove()
 * used by ventcrawling mobs to check if they can move inside a pipe in a specific direction
 * Arguments:
 * * direction - the direction we are checking against
 * * prompted_layer - the piping_layer we are inside
 */
/obj/machinery/atmospherics/proc/findConnecting(direction, prompted_layer)
	for(var/obj/machinery/atmospherics/target in get_step(src, direction))
		if(target.initialize_directions & get_dir(target,src))
			if(connection_check(target, prompted_layer))
				return target

/**
 * Check the connection between two nodes
 *
 * Check if our machine and the target machine are connectable by both calling isConnectable and by checking that the directions and piping_layer are compatible
 * called by can_be_node() (for building a network) and findConnecting() (for ventcrawling)
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 * * given_layer - the piping_layer we are checking
 */
/obj/machinery/atmospherics/proc/connection_check(obj/machinery/atmospherics/target, given_layer)
	if(isConnectable(target, given_layer) && target.isConnectable(src, given_layer) && (target.initialize_directions & get_dir(target,src)))
		return TRUE
	return FALSE

/**
 * check if the piping layer are the same on both sides
 * returns TRUE or FALSE if the connection is possible or not
 * Arguments:
 * * obj/machinery/atmospherics/target - the machinery we want to connect to
 * * given_layer - the piping_layer we are connecting to
 */
/obj/machinery/atmospherics/proc/isConnectable(obj/machinery/atmospherics/target, given_layer)
	if(isnull(given_layer))
		given_layer = piping_layer
	if((target.piping_layer == given_layer) || (target.pipe_flags & PIPING_ALL_LAYER))
		return TRUE
	return FALSE

/**
 * Called on construction and when expanding the datum_pipeline, returns the nodes of the device
 */
/obj/machinery/atmospherics/proc/pipeline_expansion()
	return nodes

/**
 * Set the initial directions of the device (NORTH || SOUTH || EAST || WEST), called on New()
 */
/obj/machinery/atmospherics/proc/SetInitDirections()
	return

/**
 * Getter of initial directions
 */
/obj/machinery/atmospherics/proc/GetInitDirections()
	return initialize_directions

/**
 * Called by addMember() in datum_pipeline.dm, returns the parent network the device is connected to
 */
/obj/machinery/atmospherics/proc/returnPipenet()
	return

/**
 * Called by addMachineryMember() in datum_pipeline.dm, returns a list of gas_mixtures and assigns them into other_airs (by addMachineryMember) to allow pressure redistribution for the machineries.
 */
/obj/machinery/atmospherics/proc/returnPipenetAirs()
	return

/**
 * Called by build_pipeline() and addMember() in datum_pipeline.dm, set the network the device is connected to, to the datum pipeline it has reference
 */
/obj/machinery/atmospherics/proc/setPipenet()
	return

/**
 * Similar to setPipenet() but instead of setting a network to a pipeline, it replaces the old pipeline with a new one, called by Merge() in datum_pipeline.dm
 */
/obj/machinery/atmospherics/proc/replacePipenet()
	return

/**
 * Disconnects the nodes
 *
 * Called by nullifyNode(), it disconnects two nodes by removing the reference id from the node itself that called this proc
 * Arguments:
 * * obj/machinery/atmospherics/reference - the machinery we are removing from the node connection
 */
/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	nodes[nodes.Find(reference)] = null
	update_appearance()

/obj/machinery/atmospherics/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe)) //lets you autodrop
		var/obj/item/pipe/pipe = W
		if(user.dropItemToGround(pipe))
			pipe.setPipingLayer(piping_layer) //align it with us
			return TRUE
	else
		return ..()

/obj/machinery/atmospherics/wrench_act(mob/living/user, obj/item/I)
	if(!can_unwrench(user))
		return ..()

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	add_fingerprint(user)

	var/unsafe_wrenching = FALSE
	var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()

	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")

	if (internal_pressure > 2*ONE_ATMOSPHERE)
		to_chat(user, "<span class='warning'>As you begin unwrenching \the [src] a gush of air blows in your face... maybe you should reconsider?</span>")
		unsafe_wrenching = TRUE //Oh dear oh dear

	if(I.use_tool(src, user, 20, volume=50))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"<span class='notice'>You unfasten \the [src].</span>", \
			"<span class='hear'>You hear ratchet.</span>")
		investigate_log("was <span class='warning'>REMOVED</span> by [key_name(usr)]", INVESTIGATE_ATMOS)

		//You unwrenched a pipe full of pressure? Let's splat you into the wall, silly.
		if(unsafe_wrenching)
			unsafe_pressure_release(user, internal_pressure)
		return deconstruct(TRUE)
	return TRUE

/**
 * Getter for can_unwrench
 *
 * Called by wrench_act() to check if the device can be unwrenched, each device override this with custom code (like if on/operating can't unwrench)
 * Arguments:
 * * mob/user - the mob doing the act
 */
/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

/**
 * Pipe pressure release calculations
 *
 * Throws the user when they unwrench a pipe with a major difference between the internal and environmental pressure.
 * Called by wrench_act() before deconstruct()
 * Arguments:
 * * mob_user - the mob doing the act
 * * pressures - it can be passed on from wrench_act(), it's the pressure difference between the enviroment pressure and the pipe internal pressure
 */
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/user, pressures = null)
	if(!user)
		return
	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	user.visible_message("<span class='danger'>[user] is sent flying by pressure!</span>","<span class='userdanger'>The pressure sends you flying!</span>")

	// if get_dir(src, user) is not 0, target is the edge_target_turf on that dir
	// otherwise, edge_target_turf uses a random cardinal direction
	// range is pressures / 250
	// speed is pressures / 1250
	user.throw_at(get_edge_target_turf(user, get_dir(src, user) || pick(GLOB.cardinals)), pressures / 250, pressures / 1250)

/**
 * Pipe deconstruction
 *
 * Called by wrench_act(), create a pipe fitting and remove the pipe
 */
/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(can_unwrench)
			var/obj/item/pipe/stored = new construction_type(loc, null, dir, src)
			stored.setPipingLayer(piping_layer)
			if(!disassembled)
				stored.obj_integrity = stored.max_integrity * 0.5
			transfer_fingerprints_to(stored)
			. = stored
	..()

/**
 * Getter for pipe underlay
 *
 * Creates the image for the pipe underlay that all components use, called by get_pipe_underlay() in components_base.dm
 * Arguments:
 * * iconset - path of the iconstate we are using (ex: 'icons/obj/atmospherics/components/thermomachine.dmi')
 * * iconstate - the image we are using inside the file
 * * direction - the direction of our device
 * * col - the color (in hex value, like #559900) that the pipe should have
 * * piping_layer - the piping_layer the device is in, used inside PIPING_LAYER_SHIFT
 * * trinary - if TRUE we also use PIPING_FORWARD_SHIFT on layer 1 and 5 for trinary devices (filters and mixers)
 */
/obj/machinery/atmospherics/proc/getpipeimage(iconset, iconstate, direction, col=rgb(255,255,255), piping_layer=3, trinary = FALSE)

	//Add identifiers for the iconset
	if(iconsetids[iconset] == null)
		iconsetids[iconset] = num2text(iconsetids.len + 1)

	//Generate a unique identifier for this image combination
	var/identifier = iconsetids[iconset] + "_[iconstate]_[direction]_[col]_[piping_layer]"

	if((!(. = pipeimages[identifier])))
		var/image/pipe_overlay
		pipe_overlay = . = pipeimages[identifier] = image(iconset, iconstate, dir = direction)
		pipe_overlay.color = col
		PIPING_LAYER_SHIFT(pipe_overlay, piping_layer)
		if(trinary == TRUE && (piping_layer == 1 || piping_layer == 5))
			PIPING_FORWARD_SHIFT(pipe_overlay, piping_layer, 2)

/obj/machinery/atmospherics/on_construction(obj_color, set_layer)
	if(can_unwrench)
		add_atom_colour(obj_color, FIXED_COLOUR_PRIORITY)
		pipe_color = obj_color
	setPipingLayer(set_layer)
	atmosinit()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmosinit()
		A.addMember(src)
	build_network()

/obj/machinery/atmospherics/Entered(atom/movable/AM)
	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		L.ventcrawl_layer = piping_layer
	return ..()

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)
	return ..()

#define VENT_SOUND_DELAY 30

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	direction &= initialize_directions
	if(!direction || !(direction in GLOB.cardinals)) //cant go this way.
		return

	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return

	var/obj/machinery/atmospherics/target_move = findConnecting(direction, user.ventcrawl_layer)
	if(target_move)
		if(target_move.can_crawl_through())
			if(is_type_in_typecache(target_move, GLOB.ventcrawl_machinery))
				user.forceMove(target_move.loc) //handle entering and so on.
				user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>", "<span class='notice'>You climb out the ventilation system.</span>")
			else
				var/list/pipenetdiff = returnPipenets() ^ target_move.returnPipenets()
				if(pipenetdiff.len)
					user.update_pipe_vision(target_move)
				user.forceMove(target_move)
				user.client.eye = target_move  //Byond only updates the eye every tick, This smooths out the movement
				if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
					user.last_played_vent = world.time
					playsound(src, 'sound/machines/ventcrawl.ogg', 50, TRUE, -3)
	else if(is_type_in_typecache(src, GLOB.ventcrawl_machinery) && can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
		user.forceMove(loc)
		user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>", "<span class='notice'>You climb out the ventilation system.</span>")

	//PLACEHOLDER COMMENT FOR ME TO READD THE 1 (?) DS DELAY THAT WAS IMPLEMENTED WITH A... TIMER?

/obj/machinery/atmospherics/AltClick(mob/living/L)
	if(istype(L) && is_type_in_list(src, GLOB.ventcrawl_machinery))
		L.handle_ventcrawl(src)
		return
	..()

/**
 * Getter for vent crawling
 *
 * returns TRUE or FALSE, many devices overrides this (like cryo, or vents)
 * called by relaymove()
 */
/obj/machinery/atmospherics/proc/can_crawl_through()
	return TRUE

/**
 * Getter of a list of pipenets
 *
 * called in relaymove() to create the image for vent crawling
 */
/obj/machinery/atmospherics/proc/returnPipenets()
	return list()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.sight |= (SEE_TURFS|BLIND)

/**
 * Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
 */
/obj/machinery/atmospherics/proc/can_see_pipes()
	return TRUE

/**
 * Update the layer in which the pipe/device is in, that way pipes have consistent layer depending on piping_layer
 */
/obj/machinery/atmospherics/proc/update_layer()
	layer = initial(layer) + (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE

/**
 * Called by the RPD.dm pre_attack(), overriden by pipes.dm
 * Arguments:
 * * paint_color - color that the pipe will be painted in (colors in hex like #4f4f4f)
 */
/obj/machinery/atmospherics/proc/paint(paint_color)
	return FALSE
