// So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
// On top of that, now people can add component-speciic procs/vars if they want!

/obj/machinery/atmospherics/components
	hide = FALSE
	layer = GAS_PUMP_LAYER
	///Is the component welded?
	var/welded = FALSE
	///Current underfloor_accessibility state, determines if the component should show the pipe underneath it and what plane it renders on.
	var/underfloor_state = UNDERFLOOR_INTERACTABLE
	///When the component is on a non default layer should we shift everything? Or just the underlay pipe
	var/shift_underlay_only = TRUE
	///Stores the parent pipeline, used in components
	var/list/datum/pipeline/parents
	///If this is queued for a rebuild this var signifies whether parents should be updated after it's done
	var/update_parents_after_rebuild = FALSE
	///Stores the gasmix for each node, used in components
	var/list/datum/gas_mixture/airs
	///Handles whether the custom reconcilation handling should be used
	var/custom_reconcilation = FALSE

/obj/machinery/atmospherics/components/get_save_vars()
	. = ..()
	if(!override_naming)
		// Prevents saving the dynamic name with \proper due to it converting to "???"
		. -= NAMEOF(src, name)
	. += NAMEOF(src, welded)
	return .

/obj/machinery/atmospherics/components/Initialize(mapload)
	parents = new(device_type)
	airs = new(device_type)

	. = ..()

	for(var/i in 1 to device_type)
		if(airs[i])
			continue
		var/datum/gas_mixture/component_mixture = new
		component_mixture.volume = 200
		airs[i] = component_mixture

	update_appearance()

// Iconnery

/**
 * Called by update_icon(), used individually by each component to determine the icon state without the pipe in consideration
 */
/obj/machinery/atmospherics/components/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/components/on_hide(datum/source, underfloor_accessibility)
	hide_pipe(underfloor_accessibility)
	return ..()

/**
 * Called in on_hide(), set the underfloor_state var to true or false depending on the situation, calls update_icon()
 */
/obj/machinery/atmospherics/components/proc/hide_pipe(underfloor_accessibility)
	underfloor_state = underfloor_accessibility
	if(underfloor_state)
		REMOVE_TRAIT(src, TRAIT_UNDERFLOOR, REF(src))
	else
		ADD_TRAIT(src, TRAIT_UNDERFLOOR, REF(src))
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	color = null
	var/uncovered_turf = loc && HAS_TRAIT(loc, TRAIT_UNCOVERED_TURF)
	SET_PLANE_IMPLICIT(src, (underfloor_state == UNDERFLOOR_INTERACTABLE && !uncovered_turf) ? GAME_PLANE : FLOOR_PLANE)

	// Layer is handled in update_layer()
	if(!underfloor_state)
		return ..()

	if(pipe_flags & PIPING_DISTRO_AND_WASTE_LAYERS)
		return ..()

	var/connected = 0 //Direction bitset
	var/underlay_pipe_layer = shift_underlay_only ? piping_layer : 3

	for(var/i in 1 to device_type) //adds intact pieces
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/node_dir = get_dir(src, node)
		var/mutable_appearance/pipe_appearance = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "intact_[node_dir]_[underlay_pipe_layer]", appearance_flags = RESET_COLOR|KEEP_APART)
		pipe_appearance.color = (node.pipe_color == ATMOS_COLOR_OMNI || istype(node, /obj/machinery/atmospherics/pipe/color_adapter)) ? pipe_color : node.pipe_color
		if (underfloor_state == UNDERFLOOR_VISIBLE || uncovered_turf)
			pipe_appearance.layer = BELOW_CATWALK_LAYER + get_pipe_layer_offset()
			SET_PLANE_EXPLICIT(pipe_appearance, FLOOR_PLANE, src)
		underlays += pipe_appearance
		connected |= node_dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			var/mutable_appearance/pipe_appearance = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "exposed_[direction]_[underlay_pipe_layer]", appearance_flags = RESET_COLOR|KEEP_APART)
			pipe_appearance.color = pipe_color
			if (underfloor_state == UNDERFLOOR_VISIBLE || uncovered_turf)
				pipe_appearance.layer = BELOW_CATWALK_LAYER + get_pipe_layer_offset()
				SET_PLANE_EXPLICIT(pipe_appearance, FLOOR_PLANE, src)
			underlays += pipe_appearance

	if(!shift_underlay_only)
		PIPING_LAYER_SHIFT(src, piping_layer)
	return ..()

/obj/machinery/atmospherics/components/get_pipe_image(iconfile, iconstate, direction, color, piping_layer, trinary)
	var/mutable_appearance/pipe_appearance = ..()
	if (underfloor_state == UNDERFLOOR_VISIBLE || (loc && HAS_TRAIT(loc, TRAIT_UNCOVERED_TURF)))
		pipe_appearance.layer = BELOW_CATWALK_LAYER + get_pipe_layer_offset()
		SET_PLANE_EXPLICIT(pipe_appearance, FLOOR_PLANE, src)
	return pipe_appearance

// Pipenet stuff; housekeeping

/obj/machinery/atmospherics/components/nullify_node(i)
	if(parents[i])
		nullify_pipenet(parents[i])
	airs[i] = null
	return ..()

/obj/machinery/atmospherics/components/on_construction(mob/user)
	. = ..()
	update_parents()

/obj/machinery/atmospherics/components/on_deconstruction(disassembled)
	relocate_airs()
	return ..()

/obj/machinery/atmospherics/components/rebuild_pipes()
	. = ..()
	if(update_parents_after_rebuild)
		update_parents()

/obj/machinery/atmospherics/components/get_rebuild_targets()
	var/list/to_return = list()
	for(var/i in 1 to device_type)
		if(parents[i])
			continue
		parents[i] = new /datum/pipeline()
		to_return += parents[i]
	return to_return

/**
 * Called by nullify_node(), used to remove the pipeline the component is attached to
 * Arguments:
 * * -reference: the pipeline the component is attached to
 */
/obj/machinery/atmospherics/components/proc/nullify_pipenet(datum/pipeline/reference)
	if(!reference)
		CRASH("nullify_pipenet(null) called by [type] on [COORD(src)]")

	for (var/i in 1 to parents.len)
		if (parents[i] == reference)
			reference.other_airs -= airs[i] // Disconnects from the pipeline side
			parents[i] = null // Disconnects from the machinery side.

	reference.other_atmos_machines -= src
	if(custom_reconcilation)
		reference.require_custom_reconcilation -= src

	/**
	 *  We explicitly qdel pipeline when this particular pipeline
	 *  is projected to have no member and cause GC problems.
	 *  We have to do this because components don't qdel pipelines
	 *  while pipes must and will happily wreck and rebuild everything
	 * again every time they are qdeleted.
	 */

	if(!length(reference.other_atmos_machines) && !length(reference.members))
		if(QDESTROYING(reference))
			CRASH("nullify_pipenet() called on qdeleting [reference]")
		qdel(reference)

/obj/machinery/atmospherics/components/return_pipenet_airs(datum/pipeline/reference)
	var/list/returned_air = list()

	for (var/i in 1 to parents.len)
		if (parents[i] == reference)
			returned_air += airs[i]
	return returned_air

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		return list(nodes[parents.Find(reference)])
	return ..()

/obj/machinery/atmospherics/components/set_pipenet(datum/pipeline/reference, obj/machinery/atmospherics/target_component)
	parents[nodes.Find(target_component)] = reference

/obj/machinery/atmospherics/components/return_pipenet(obj/machinery/atmospherics/target_component = nodes[1]) //returns parents[1] if called without argument
	return parents[nodes.Find(target_component)]

/obj/machinery/atmospherics/components/replace_pipenet(datum/pipeline/Old, datum/pipeline/New)
	parents[parents.Find(Old)] = New

// Helpers

/**
 * Called in most atmos processes and gas handling situations, update the parents pipelines of the devices connected to the source component
 * This way gases won't get stuck
 */
/obj/machinery/atmospherics/components/proc/update_parents()
	if(!SSair.initialized)
		return
	if(rebuilding)
		update_parents_after_rebuild = TRUE
		return
	for(var/i in 1 to device_type)
		var/datum/pipeline/parent = parents[i]
		if(!parent)
			WARNING("Component is missing a pipenet! Rebuilding...")
			SSair.add_to_rebuild_queue(src)
		else
			parent.update = TRUE

/obj/machinery/atmospherics/components/return_pipenets()
	. = list()
	for(var/i in 1 to device_type)
		. += return_pipenet(nodes[i])

/// When this machine is in a pipenet that is reconciling airs, this proc can add pipelines to the calculation.
/// Can be either a list of pipenets or a single pipenet.
/obj/machinery/atmospherics/components/proc/return_pipenets_for_reconcilation(datum/pipeline/requester)
	return list()

/// When this machine is in a pipenet that is reconciling airs, this proc can add airs to the calculation.
/// Can be either a list of airs or a single air mix.
/obj/machinery/atmospherics/components/proc/return_airs_for_reconcilation(datum/pipeline/requester)
	return list()

// UI Stuff

/obj/machinery/atmospherics/components/ui_status(mob/user, datum/ui_state/state)
	if(allowed(user))
		return ..()
	to_chat(user, span_danger("Access denied."))
	return UI_CLOSE

// Tool acts

/obj/machinery/atmospherics/components/return_analyzable_air()
	return airs

/**
 * Handles machinery deconstruction and unsafe pressure release
 */
/obj/machinery/atmospherics/components/proc/crowbar_deconstruction_act(mob/living/user, obj/item/tool, internal_pressure = 0)
	if(!panel_open)
		balloon_alert(user, "open panel!")
		return ITEM_INTERACT_SUCCESS

	var/unsafe_wrenching = FALSE
	var/filled_pipe = FALSE
	var/datum/gas_mixture/environment_air = loc.return_air()

	for(var/i in 1 to device_type)
		var/datum/gas_mixture/inside_air = airs[i]
		if(inside_air.total_moles() > 0 || internal_pressure)
			filled_pipe = TRUE
		if(!nodes[i] || (istype(nodes[i], /obj/machinery/atmospherics/components/unary/portables_connector) && !portable_device_connected(i)))
			internal_pressure = internal_pressure > airs[i].return_pressure() ? internal_pressure : airs[i].return_pressure()

	if(!filled_pipe)
		default_deconstruction_crowbar(tool)
		return ITEM_INTERACT_SUCCESS

	to_chat(user, span_notice("You begin to unfasten \the [src]..."))

	internal_pressure -= environment_air.return_pressure()

	if(internal_pressure > 2 * ONE_ATMOSPHERE)
		to_chat(user, span_warning("As you begin deconstructing \the [src] a gush of air blows in your face... maybe you should reconsider?"))
		unsafe_wrenching = TRUE

	if(!do_after(user, 2 SECONDS, src))
		return
	if(unsafe_wrenching)
		unsafe_pressure_release(user, internal_pressure)
	tool.play_tool_sound(src, 50)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/atmospherics/components/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(!.)
		return FALSE
	set_init_directions()
	reconnect_nodes()
	return TRUE

/obj/machinery/atmospherics/components/proc/reconnect_nodes()
	for(var/i in 1 to device_type)
		var/obj/machinery/atmospherics/node = nodes[i]
		if(node)
			if(src in node.nodes)
				node.disconnect(src)
			nodes[i] = null
		if(parents[i])
			nullify_pipenet(parents[i])
	for(var/i in 1 to device_type)
		var/obj/machinery/atmospherics/node = nodes[i]
		atmos_init()
		node = nodes[i]
		if(node)
			node.atmos_init()
			node.add_member(src)
			update_parents()
		SSair.add_to_rebuild_queue(src)

/**
 * Disconnects all nodes from ourselves, remove us from the node's nodes.
 * Nullify our parent pipenet
 */
/obj/machinery/atmospherics/components/proc/disconnect_nodes()
	for(var/i in 1 to device_type)
		var/obj/machinery/atmospherics/node = nodes[i]
		if(node)
			if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
				node.disconnect(src)
			nodes[i] = null
		if(parents[i])
			nullify_pipenet(parents[i])

/**
 * Connects all nodes to ourselves, add us to the node's nodes.
 * Calls atmos_init() on the node and on us.
 */
/obj/machinery/atmospherics/components/proc/connect_nodes()
	atmos_init()
	for(var/i in 1 to device_type)
		var/obj/machinery/atmospherics/node = nodes[i]
		if(node)
			node.atmos_init()
			node.add_member(src)
	SSair.add_to_rebuild_queue(src)

/**
 * Easy way to toggle nodes connection and disconnection.
 *
 * Arguments:
 * * disconnect - if TRUE, disconnects all nodes. If FALSE, connects all nodes.
 */
/obj/machinery/atmospherics/components/proc/change_nodes_connection(disconnect)
	if(disconnect)
		disconnect_nodes()
		return
	connect_nodes()

/obj/machinery/atmospherics/components/update_layer()
	if (!underfloor_state)
		layer = BELOW_CATWALK_LAYER
	else if (PLANE_TO_TRUE(plane) == FLOOR_PLANE)
		layer = ABOVE_OPEN_TURF_LAYER
	else
		layer = initial(layer)
	layer += get_pipe_layer_offset()

/obj/machinery/atmospherics/components/proc/get_pipe_layer_offset()
	return (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE + (GLOB.pipe_colors_ordered[pipe_color] * 0.001)

/**
 * Handles air relocation to the pipenet/environment
 */
/obj/machinery/atmospherics/components/proc/relocate_airs(datum/gas_mixture/to_release)
	var/turf/local_turf = get_turf(src)
	for(var/i in 1 to device_type)
		var/datum/gas_mixture/air = airs[i]
		if(!nodes[i] || (istype(nodes[i], /obj/machinery/atmospherics/components/unary/portables_connector) && !portable_device_connected(i)))
			if(!to_release)
				to_release = air
				continue
			to_release.merge(air)
			continue
		var/datum/gas_mixture/parents_air = parents[i].air
		parents_air.merge(air)
	if(to_release)
		local_turf.assume_air(to_release)
