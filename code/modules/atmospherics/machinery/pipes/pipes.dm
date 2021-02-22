/obj/machinery/atmospherics/pipe
	damage_deflection = 12
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/volume = 0

	use_power = NO_POWER_USE
	can_unwrench = 1
	var/datum/pipeline/parent = null

	paintable = TRUE

	//Buckling
	can_buckle = TRUE
	buckle_requires_restraints = TRUE
	buckle_lying = NO_BUCKLE_LYING

	var/max_pressure = 35000
	var/can_burst = TRUE
	var/burst_type = /obj/machinery/atmospherics/components/unary/burstpipe

/obj/machinery/atmospherics/pipe/New()
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	volume = 35 * device_type
	..()

///I have no idea why there's a new and at this point I'm too afraid to ask
/obj/machinery/atmospherics/pipe/Initialize(mapload)
	. = ..()

	if(hide)
		AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE) //if changing this, change the subtypes RemoveElements too, because thats how bespoke works

	if(isclosedturf(loc))
		can_burst = FALSE

	for(var/direction in GLOB.cardinals)
		var/obj/machinery/atmospherics/found
		if(initialize_directions & direction)
			found = findConnecting(direction)
		if(istype(found, /obj/machinery/atmospherics/components))
			can_burst = FALSE


/obj/machinery/atmospherics/pipe/nullifyNode(i)
	var/obj/machinery/atmospherics/oldN = nodes[i]
	..()
	if(oldN)
		SSair.add_to_rebuild_queue(oldN)

/obj/machinery/atmospherics/pipe/destroy_network()
	QDEL_NULL(parent)

/obj/machinery/atmospherics/pipe/build_network()
	if(QDELETED(parent))
		parent = new
		parent.build_pipeline(src)

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)
		air_update_turf(FALSE, FALSE)

/obj/machinery/atmospherics/pipe/return_air()
	return parent.air

/obj/machinery/atmospherics/pipe/return_analyzable_air()
	return parent.air

/obj/machinery/atmospherics/pipe/remove_air(amount)
	return parent.air.remove(amount)

/obj/machinery/atmospherics/pipe/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = W
		user.dropItemToGround(meter)
		meter.setAttachLayer(piping_layer)
	else
		return ..()

/obj/machinery/atmospherics/pipe/returnPipenet()
	return parent

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/pipe/Destroy()
	QDEL_NULL(parent)

	releaseAirToTurf()
	QDEL_NULL(air_temporary)

	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	. = ..()

/obj/machinery/atmospherics/pipe/update_icon()
	. = ..()
	update_layer()

/obj/machinery/atmospherics/pipe/proc/update_node_icon()
	for(var/i in 1 to device_type)
		if(nodes[i])
			var/obj/machinery/atmospherics/N = nodes[i]
			N.update_icon()

/obj/machinery/atmospherics/pipe/returnPipenets()
	. = list(parent)

/obj/machinery/atmospherics/pipe/paint(paint_color)
	if(paintable)
		add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
		pipe_color = paint_color
		update_node_icon()
	return paintable

/obj/machinery/atmospherics/pipe/process()
	if(!parent)
		return //machines subsystem fires before atmos is initialized so this prevents race condition runtimes
	if(!can_burst)
		return
	check_pressure()

/obj/machinery/atmospherics/pipe/proc/check_pressure()
	var/datum/gas_mixture/int_air = return_air()
	var/internal_pressure = int_air.return_pressure()
	if(int_air.total_moles() < 5) //Prevents micromoles bursts
		return
	if(internal_pressure > max_pressure && prob(1))
		burst()

/obj/machinery/atmospherics/pipe/proc/burst()
	message_admins("Pipe burst in area [ADMIN_JMP(src)]")
	investigate_log("Pipe burst in area", INVESTIGATE_ATMOS)

	for(var/obj/machinery/atmospherics/node in pipeline_expansion())
		if(node)
			node.disconnect(src)
			node = null


	for(var/direction in GLOB.cardinals)
		if(initialize_directions & direction)
			var/obj/machinery/atmospherics/found
			found = findConnecting(direction)
			if(!found)
				continue
			var/obj/machinery/atmospherics/components/unary/burstpipe/burst = new burst_type(loc, direction, piping_layer, pipe_color)
			burst.do_connect()

	qdel(src)
