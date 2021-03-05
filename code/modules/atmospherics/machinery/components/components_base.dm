// So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
// On top of that, now people can add component-speciic procs/vars if they want!

/obj/machinery/atmospherics/components
	hide = FALSE
	///Is the component welded?
	var/welded = FALSE
	///Should the component should show the pipe underneath it?
	var/showpipe = TRUE
	///When the component is on a non default layer should we shift everything? Or just the underlay pipe
	var/shift_underlay_only = TRUE
	///Stores the component pipeline
	var/list/datum/pipeline/parents
	///Stores the component gas mixture
	var/list/datum/gas_mixture/airs

/obj/machinery/atmospherics/components/New()
	parents = new(device_type)
	airs = new(device_type)

	..()

	for(var/i in 1 to device_type)
		var/datum/gas_mixture/A = new
		A.volume = 200
		airs[i] = A

/obj/machinery/atmospherics/components/Initialize()
	. = ..()

	if(hide)
		RegisterSignal(src, COMSIG_OBJ_HIDE, .proc/hide_pipe)

// Iconnery

/**
 * Called by update_icon(), used individually by each component to determine the icon state without the pipe in consideration
 */
/obj/machinery/atmospherics/components/proc/update_icon_nopipes()
	return

/**
 * Called in Initialize(), set the showpipe var to true or false depending on the situation, calls update_icon()
 */
/obj/machinery/atmospherics/components/proc/hide_pipe(datum/source, covered)
	showpipe = !covered
	update_appearance()

/obj/machinery/atmospherics/components/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	plane = showpipe ? GAME_PLANE : FLOOR_PLANE

	if(!showpipe)
		return ..()

	var/connected = 0 //Direction bitset

	for(var/i in 1 to device_type) //adds intact pieces
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
		underlays += img
		connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

	if(!shift_underlay_only)
		PIPING_LAYER_SHIFT(src, piping_layer)
	return ..()

/**
 * Called by update_icon() when showpipe is TRUE, set the image for the underlay pipe
 * Arguments:
 * * -state: icon_state of the selected pipe
 * * -dir: direction of the pipe
 * * -color: color of the pipe
 */
/obj/machinery/atmospherics/components/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, color, piping_layer = shift_underlay_only ? piping_layer : 3)
	else
		. = getpipeimage('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, piping_layer = shift_underlay_only ? piping_layer : 3)

// Pipenet stuff; housekeeping

/obj/machinery/atmospherics/components/nullifyNode(i)
	if(parents[i])
		nullifyPipenet(parents[i])
	QDEL_NULL(airs[i])
	return ..()

/obj/machinery/atmospherics/components/on_construction()
	..()
	update_parents()

/obj/machinery/atmospherics/components/build_network()
	for(var/i in 1 to device_type)
		if(parents[i])
			continue
		parents[i] = new /datum/pipeline()
		var/datum/pipeline/P = parents[i]
		P.build_pipeline(src)

/**
 * Called by nullifyNode(), used to remove the pipeline the component is attached to
 * Arguments:
 * * -reference: the pipeline the component is attached to
 */
/obj/machinery/atmospherics/components/proc/nullifyPipenet(datum/pipeline/reference)
	if(!reference)
		CRASH("nullifyPipenet(null) called by [type] on [COORD(src)]")

	for (var/i in 1 to parents.len)
		if (parents[i] == reference)
			reference.other_airs -= airs[i] // Disconnects from the pipeline side
			parents[i] = null // Disconnects from the machinery side.

	reference.other_atmosmch -= src 
	
	/**
	 *  We explicitly qdel pipeline when this particular pipeline
	 *  is projected to have no member and cause GC problems.
	 *  We have to do this because components don't qdel pipelines
	 *  while pipes must and will happily wreck and rebuild everything
	 * again every time they are qdeleted.
	 */

	if(!length(reference.other_atmosmch) && !length(reference.members))
		if(QDESTROYING(reference))
			CRASH("nullifyPipenet() called on qdeleting [reference]")
		qdel(reference)

/obj/machinery/atmospherics/components/returnPipenetAirs(datum/pipeline/reference)
	var/list/returned_air = list()

	for (var/i in 1 to parents.len)
		if (parents[i] == reference)
			returned_air += airs[i]
	return returned_air

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		return list(nodes[parents.Find(reference)])
	return ..()

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	parents[nodes.Find(A)] = reference

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A = nodes[1]) //returns parents[1] if called without argument
	return parents[nodes.Find(A)]

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	parents[parents.Find(Old)] = New

/obj/machinery/atmospherics/components/unsafe_pressure_release(mob/user, pressures)
	. = ..()

	var/turf/T = get_turf(src)
	if(!T)
		return
	//Remove the gas from airs and assume it
	var/datum/gas_mixture/environment = T.return_air()
	var/lost = null
	var/times_lost = 0
	for(var/i in 1 to device_type)
		var/datum/gas_mixture/air = airs[i]
		lost += pressures*environment.volume/(air.temperature * R_IDEAL_GAS_EQUATION)
		times_lost++
	var/shared_loss = lost/times_lost

	var/datum/gas_mixture/to_release
	for(var/i in 1 to device_type)
		var/datum/gas_mixture/air = airs[i]
		if(!to_release)
			to_release = air.remove(shared_loss)
			continue
		to_release.merge(air.remove(shared_loss))
	T.assume_air(to_release)
	air_update_turf(FALSE, FALSE)

// Helpers

/**
 * Called in most atmos processes and gas handling situations, update the parents pipelines of the devices connected to the source component
 * This way gases won't get stuck
 */
/obj/machinery/atmospherics/components/proc/update_parents()
	for(var/i in 1 to device_type)
		var/datum/pipeline/parent = parents[i]
		if(!parent)
			WARNING("Component is missing a pipenet! Rebuilding...")
			SSair.add_to_rebuild_queue(src)
		else
			parent.update = TRUE

/obj/machinery/atmospherics/components/returnPipenets()
	. = list()
	for(var/i in 1 to device_type)
		. += returnPipenet(nodes[i])

// UI Stuff

/obj/machinery/atmospherics/components/ui_status(mob/user)
	if(allowed(user))
		return ..()
	to_chat(user, "<span class='danger'>Access denied.</span>")
	return UI_CLOSE

// Tool acts

/obj/machinery/atmospherics/components/return_analyzable_air()
	return airs
