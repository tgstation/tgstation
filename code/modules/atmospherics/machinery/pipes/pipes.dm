/obj/machinery/atmospherics/pipe
	icon = 'icons/obj/pipes_n_cables/!pipes_bitmask.dmi'
	damage_deflection = 12
	/// Temporary holder for gases in the absence of a pipeline
	var/datum/gas_mixture/air_temporary

	/// The gas capacity this pipe contributes to a pipeline
	var/volume = 0

	use_power = NO_POWER_USE
	can_unwrench = 1
	/// The pipeline this pipe is a member of
	var/datum/pipeline/parent = null

	paintable = TRUE

	/// Determines if this pipe will be given gas visuals
	var/has_gas_visuals = TRUE

	//Buckling
	can_buckle = TRUE
	buckle_requires_restraints = TRUE
	buckle_lying = NO_BUCKLE_LYING

/obj/machinery/atmospherics/pipe/New()
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	if (!volume) // Pipes can have specific volumes or have it determined by their device_type.
		volume = UNARY_PIPE_VOLUME * device_type
	. = ..()

/obj/machinery/atmospherics/pipe/proc/set_volume(new_volume)
	if(volume == new_volume)
		return
	var/datum/gas_mixture/gasmix = parent?.air
	if(gasmix)
		gasmix.volume = gasmix.volume + new_volume - volume
	volume = new_volume

/obj/machinery/atmospherics/pipe/setup_hiding()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE) //if changing this, change the subtypes RemoveElements too, because thats how bespoke works

	// Registering on `COMSIG_OBJ_HIDE` would cause order of operations issues with undertile, so we register to run when undertile updates instead
	RegisterSignal(src, COMSIG_UNDERTILE_UPDATED, PROC_REF(on_hide))

/obj/machinery/atmospherics/pipe/on_deconstruction(disassembled)
	//we delete the parent here so it initializes air_temporary for us. See /datum/pipeline/Destroy() which calls temporarily_store_air()
	QDEL_NULL(parent)

	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)

	return ..()

/obj/machinery/atmospherics/pipe/Destroy()
	QDEL_NULL(parent)
	return ..()

//-----------------
// PIPENET STUFF

/obj/machinery/atmospherics/pipe/nullify_node(i)
	var/obj/machinery/atmospherics/old_node = nodes[i]
	. = ..()
	if(old_node)
		SSair.add_to_rebuild_queue(old_node)

/obj/machinery/atmospherics/pipe/destroy_network()
	QDEL_NULL(parent)

/obj/machinery/atmospherics/pipe/get_rebuild_targets()
	if(!QDELETED(parent))
		return
	replace_pipenet(parent, new /datum/pipeline)
	return list(parent)

/obj/machinery/atmospherics/pipe/return_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/return_analyzable_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/remove_air(amount)
	if(air_temporary)
		return air_temporary.remove(amount)
	return parent.air.remove(amount)

/obj/machinery/atmospherics/pipe/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = item
		user.dropItemToGround(meter)
		meter.setAttachLayer(piping_layer)
	else
		return ..()

/obj/machinery/atmospherics/pipe/return_pipenet()
	return parent

/obj/machinery/atmospherics/pipe/replace_pipenet(datum/pipeline/old_pipenet, datum/pipeline/new_pipenet)
	if(parent && has_gas_visuals)
		vis_contents -= parent.GetGasVisual('icons/obj/pipes_n_cables/!pipe_gas_overlays.dmi')

	parent = new_pipenet

	if(parent && has_gas_visuals) // null is a valid argument here
		vis_contents += parent.GetGasVisual('icons/obj/pipes_n_cables/!pipe_gas_overlays.dmi')

/obj/machinery/atmospherics/pipe/return_pipenets()
	. = list(parent)

//--------------------
// APPEARANCE STUFF

/obj/machinery/atmospherics/pipe/update_icon()
	update_pipe_icon()
	update_layer()
	return ..()

/obj/machinery/atmospherics/pipe/proc/update_pipe_icon()
	switch(initialize_directions)
		if(NORTH, EAST, SOUTH, WEST) // Pipes with only a single connection aren't handled by this system
			icon = null
			return
		else
			icon = 'icons/obj/pipes_n_cables/!pipes_bitmask.dmi'
	var/connections = NONE
	var/bitfield = NONE
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/connected_dir = get_dir(src, node)
		connections |= connected_dir
	bitfield = CARDINAL_TO_FULLPIPES(connections)
	bitfield |= CARDINAL_TO_SHORTPIPES(initialize_directions & ~connections)
	icon_state = "[bitfield]_[piping_layer]"

/obj/machinery/atmospherics/proc/update_node_icon()
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/current_node = nodes[i]
		current_node.update_icon()

/obj/machinery/atmospherics/pipe/update_layer()
	layer = (HAS_TRAIT(src, TRAIT_UNDERFLOOR) ? BELOW_CATWALK_LAYER : initial(layer)) + (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE + (GLOB.pipe_colors_ordered[pipe_color] * 0.0001)
