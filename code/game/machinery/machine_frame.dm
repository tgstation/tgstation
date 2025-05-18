/obj/structure/frame/machine
	name = "machine frame"
	desc = "The standard frame for most station appliances. Its appearance and function is controlled by the inserted board."
	board_type = /obj/item/circuitboard/machine
	/// List of all compnents inside the frame contributing to its construction
	var/list/components
	/// List of all components required to construct the frame
	var/list/req_components
	/// User-friendly list of names of required components
	var/list/req_component_names

/obj/structure/frame/machine/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/frame/machine/Destroy()
	QDEL_LIST(components)
	return ..()

/obj/structure/frame/machine/atom_deconstruct(disassembled = TRUE)
	if(state >= FRAME_STATE_WIRED)
		new /obj/item/stack/cable_coil(drop_location(), 5)
	dump_contents()
	return ..()

/obj/structure/frame/machine/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_WRENCH && !circuit?.needs_anchored)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""]anchor"
		return CONTEXTUAL_SCREENTIP_SET

	switch(state)
		if(FRAME_STATE_EMPTY)
			if(istype(held_item, /obj/item/stack/cable_coil))
				context[SCREENTIP_CONTEXT_LMB] = "Wire Frame"
				return CONTEXTUAL_SCREENTIP_SET
			else if(held_item.tool_behaviour == TOOL_WELDER)
				context[SCREENTIP_CONTEXT_LMB] = "Unweld frame"
				return CONTEXTUAL_SCREENTIP_SET
			else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
				context[SCREENTIP_CONTEXT_LMB] = "Disassemble frame"
				return CONTEXTUAL_SCREENTIP_SET
		if(FRAME_STATE_WIRED)
			if(held_item.tool_behaviour == TOOL_WIRECUTTER)
				context[SCREENTIP_CONTEXT_LMB] = "Cut wires"
				return CONTEXTUAL_SCREENTIP_SET
			else if(istype(held_item, board_type))
				context[SCREENTIP_CONTEXT_LMB] = "Insert board"
				return CONTEXTUAL_SCREENTIP_SET
		if(FRAME_STATE_BOARD_INSTALLED)
			if(held_item.tool_behaviour == TOOL_CROWBAR)
				context[SCREENTIP_CONTEXT_LMB] = "Pry out components"
				return CONTEXTUAL_SCREENTIP_SET
			else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
				var/needs_components = FALSE
				for(var/component in req_components)
					if(!req_components[component])
						continue
					needs_components = TRUE
					break
				if(!needs_components)
					context[SCREENTIP_CONTEXT_LMB] = "Complete frame"
					return CONTEXTUAL_SCREENTIP_SET
			else if(!istype(held_item, /obj/item/storage/part_replacer))
				for(var/component in req_components)
					if(!req_components[component])
						continue
					var/stock_part_path
					if(ispath(component, /obj/item))
						stock_part_path = component
					else if(ispath(component, /datum/stock_part))
						var/datum/stock_part/stock_part_datum_type = component
						stock_part_path = initial(stock_part_datum_type.physical_object_type)
					if(istype(held_item, stock_part_path))
						context[SCREENTIP_CONTEXT_LMB] = "Insert part"
						return CONTEXTUAL_SCREENTIP_SET

/obj/structure/frame/machine/examine(user)
	. = ..()
	if(!circuit?.needs_anchored)
		. += span_notice("It can be [EXAMINE_HINT("anchored")] [anchored ? "loose." : "into place."]")
	if(state == FRAME_STATE_EMPTY)
		if(!anchored)
			. += span_notice("It can be [EXAMINE_HINT("welded")] or [EXAMINE_HINT("screwed")] apart.")
		. += span_info("It should be [EXAMINE_HINT("wired")] with 5 cables.")
		return
	if(state == FRAME_STATE_WIRED)
		. += span_notice("Its wires can be [EXAMINE_HINT("cut")].")
	if(state != FRAME_STATE_BOARD_INSTALLED)
		. += span_warning("It's missing a circuit board!")
		return
	if(!length(req_components))
		. += span_info("It requires no components.")
		return

	var/list/nice_list = list()
	for(var/component in req_components)
		if(!req_components[component])
			continue
		nice_list += list("[req_components[component]] [req_component_names[component]]\s")
	. += span_info("It requires [english_list(nice_list, "no more components")].")

	. += span_notice("All the components can be [EXAMINE_HINT("pried")] out.")
	if(!length(nice_list))
		. += span_info("The frame should be [EXAMINE_HINT("screwed")] to complete it.")

/obj/structure/frame/machine/dump_contents()
	var/atom/drop_loc = drop_location()

	// We need a snowflake check for stack items since they don't exist anymore
	for(var/component in circuit?.req_components)
		if(!ispath(component, /obj/item/stack))
			continue
		var/obj/item/stack/stack_path = component
		var/stack_amount = circuit.req_components[component] - req_components[component]
		if(stack_amount > 0)
			new stack_path(drop_loc, stack_amount)

	// Rest of the stuff can just be spat out (this includes the circuitboard0)
	for(var/component in components)
		if(ismovable(component))
			var/atom/movable/atom_component = component
			atom_component.forceMove(drop_loc)

		else if(istype(component, /datum/stock_part))
			var/datum/stock_part/stock_part_datum = component
			var/physical_object_type = initial(stock_part_datum.physical_object_type)
			new physical_object_type(drop_loc)

		else
			stack_trace("Invalid component [component] was found in constructable frame")

	components = null
	req_components = null
	req_component_names = null

/obj/structure/frame/machine/install_board(mob/living/user, obj/item/circuitboard/machine/board, by_hand = TRUE)
	if(state == FRAME_STATE_EMPTY)
		balloon_alert(user, "needs wiring!")
		return FALSE
	if(state == FRAME_STATE_BOARD_INSTALLED)
		balloon_alert(user, "circuit already installed!")
		return FALSE
	if(!anchored && istype(board) && board.needs_anchored)
		balloon_alert(user, "frame must be anchored!")
		return FALSE

	return ..()

/obj/structure/frame/machine/circuit_added(obj/item/circuitboard/machine/added)
	state = FRAME_STATE_BOARD_INSTALLED
	update_appearance(UPDATE_ICON_STATE)

	//add circuit board as the first component to the list of components
	//required for part_replacer to locate it while exchanging parts
	//so it does not early return in /obj/machinery/proc/exchange_parts
	components = list(circuit)
	req_components = added.req_components.Copy()
	if(!req_components)
		return

	//creates a list of names from all the required parts
	req_component_names = list()
	for(var/component_path in req_components)
		if(!ispath(component_path))
			continue

		if(ispath(component_path, /obj/item/stack))
			var/obj/item/stack/stack_path = component_path
			if(initial(stack_path.singular_name))
				req_component_names[component_path] = initial(stack_path.singular_name)
			else
				req_component_names[component_path] = initial(stack_path.name)
		else if(ispath(component_path, /datum/stock_part))
			var/datum/stock_part/stock_part = component_path
			var/obj/item/physical_object_type = initial(stock_part.physical_object_type)

			req_component_names[component_path] = initial(physical_object_type.name)
		else if(ispath(component_path, /obj/item/stock_parts))
			var/obj/item/stock_parts/stock_part = component_path

			if(!added.specific_parts && initial(stock_part.base_name))
				req_component_names[component_path] = initial(stock_part.base_name)
			else
				req_component_names[component_path] = initial(stock_part.name)
		else if(ispath(component_path, /obj/item))
			var/obj/item/part = component_path

			req_component_names[component_path] = initial(part.name)
		else
			stack_trace("Invalid component part [component_path] in [type], couldn't get its name")
			req_component_names[component_path] = "[component_path] (this is a bug)"

/obj/structure/frame/machine/circuit_removed(obj/item/circuitboard/machine/removed)
	components -= removed
	state = FRAME_STATE_WIRED
	update_appearance(UPDATE_ICON_STATE)

/**
 * Returns the instance of path1 in list, else path2 in list
 *
 * Arguments
 * * parts - the list of parts to search
 * * path1 - the first path to search for
 * * path2 - the second path to search for, if path1 is not found
 */
/obj/structure/frame/machine/proc/look_for(list/parts, path1, path2)
	PRIVATE_PROC(TRUE)

	return (locate(path1) in parts) || (path2 ? (locate(path2) in parts) : null)

/obj/structure/frame/machine/install_parts_from_part_replacer(mob/living/user, obj/item/storage/part_replacer/replacer, no_sound = FALSE)
	if(!length(replacer.contents))
		return FALSE
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	if(!amt)
		return FALSE

	var/play_sound = FALSE
	var/list/part_list = replacer.get_sorted_parts() //parts sorted in order of tier
	for(var/path in req_components)
		var/target_path
		if(ispath(path, /datum/stock_part))
			var/datum/stock_part/datum_part = path
			target_path = initial(datum_part.physical_object_base_type)
		else
			target_path = path

		var/obj/item/part
		while(req_components[path] > 0 && (part = look_for(part_list, target_path, ispath(path, /obj/item/stack/ore/bluespace_crystal) ? /obj/item/stack/sheet/bluespace_crystal : null)))
			part_list -= part
			if(istype(part, /obj/item/stack))
				var/obj/item/stack/S = part
				var/used_amt = min(round(S.get_amount()), req_components[path])
				var/stack_name = S.singular_name
				if(!used_amt || !S.use(used_amt))
					continue
				req_components[path] -= used_amt
				// No balloon alert here so they can look back and see what they added
				to_chat(user, span_notice("You add [used_amt] [stack_name] to [src]."))
				play_sound = TRUE
			else if(replacer.atom_storage.attempt_remove(part, src))
				var/stock_part_datum = GLOB.stock_part_datums_per_object[part.type]
				if (!isnull(stock_part_datum))
					components += stock_part_datum
					qdel(part)
				else
					components += part
					part.forceMove(src)
				req_components[path]--
				// No balloon alert here so they can look back and see what they added
				to_chat(user, span_notice("You add [part] to [src]."))
				play_sound = TRUE

	if(play_sound && !no_sound)
		replacer.play_rped_sound()

	return TRUE

/obj/structure/frame/machine/can_be_unfasten_wrench(mob/user, silent)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return .

	if(circuit?.needs_anchored)
		balloon_alert(user, "frame must be anchored!")
		return FAILED_UNFASTEN

	return .

/obj/structure/frame/machine/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(state != FRAME_STATE_BOARD_INSTALLED)
		return .
	if(finalize_construction(user, tool))
		return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/structure/frame/machine/wirecutter_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE
	if(state != FRAME_STATE_WIRED)
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "removing cables...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50) || state != FRAME_STATE_WIRED)
		return ITEM_INTERACT_BLOCKING

	state = FRAME_STATE_EMPTY
	update_appearance(UPDATE_ICON_STATE)
	new /obj/item/stack/cable_coil(drop_location(), 5)
	return ITEM_INTERACT_SUCCESS

/obj/structure/frame/machine/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE
	if(state != FRAME_STATE_BOARD_INSTALLED)
		return ITEM_INTERACT_BLOCKING

	tool.play_tool_sound(src)
	var/list/leftover_components = components.Copy() - circuit
	dump_contents()
	balloon_alert(user, "circuit board[length(leftover_components) ? " and components" : ""] removed")
	// Circuit exited handles updating state
	return ITEM_INTERACT_SUCCESS

/**
 * Attempts to add the passed part to the frame
 *
 * Requires no sanity check that the passed part is a stock part
 *
 * Arguments
 * * user - the player
 * * tool - the part to add
 */
/obj/structure/frame/machine/proc/add_part(mob/living/user, obj/item/tool)
	PRIVATE_PROC(TRUE)

	for(var/stock_part_base in req_components)
		if (req_components[stock_part_base] == 0)
			continue

		var/stock_part_path

		if(ispath(stock_part_base, /obj/item))
			stock_part_path = stock_part_base
		else if(ispath(stock_part_base, /datum/stock_part))
			var/datum/stock_part/stock_part_datum_type = stock_part_base
			stock_part_path = initial(stock_part_datum_type.physical_object_type)
		else
			stack_trace("Bad stock part in req_components: [stock_part_base]")
			continue

		//if we require an bluespace crystall and we have an full sheet of them we can allow that
		if(ispath(stock_part_path, /obj/item/stack/ore/bluespace_crystal) && istype(tool, /obj/item/stack/sheet/bluespace_crystal))
			pass() //allow it
		else if(!istype(tool, stock_part_path))
			continue

		if(isstack(tool))
			var/obj/item/stack/S = tool
			var/used_amt = min(round(S.get_amount()), req_components[stock_part_path])
			if(used_amt && S.use(used_amt))
				req_components[stock_part_path] -= used_amt
				// No balloon alert here so they can look back and see what they added
				to_chat(user, span_notice("You add [tool] to [src]."))
			return

		// We might end up qdel'ing the part if it's a stock part datum.
		// In practice, this doesn't have side effects to the name,
		// but academically we should not be using an object after it's deleted.
		var/part_name = "[tool]"

		if (ispath(stock_part_base, /datum/stock_part))
			// We can't just reuse stock_part_path here or its singleton,
			// or else putting in a tier 2 part will deconstruct to a tier 1 part.
			var/stock_part_datum = GLOB.stock_part_datums_per_object[tool.type]
			if (isnull(stock_part_datum))
				stack_trace("tool.type] does not have an associated stock part datum!")
				continue

			components += stock_part_datum

			// We regenerate the stock parts on deconstruct.
			// This technically means we lose unique qualities of the stock part, but
			// it's worth it for how dramatically this simplifies the code.
			// The only place I can see it affecting anything is like...RPG qualities. :P
			qdel(tool)
		else if(user.transferItemToLoc(tool, src))
			components += tool
		else
			break

		// No balloon alert here so they can look back and see what they added
		to_chat(user, span_notice("You add [part_name] to [src]."))
		req_components[stock_part_base]--
		return TRUE

	balloon_alert(user, "can't add that!")
	return FALSE

/obj/structure/frame/machine/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .

	switch(state)
		if(FRAME_STATE_EMPTY)
			if(istype(tool, /obj/item/stack/cable_coil))
				if(!tool.tool_start_check(user, amount = 5))
					return ITEM_INTERACT_BLOCKING

				balloon_alert(user, "adding cables...")
				if(!tool.use_tool(src, user, 2 SECONDS, volume = 50, amount = 5) || state != FRAME_STATE_EMPTY)
					return ITEM_INTERACT_BLOCKING

				state = FRAME_STATE_WIRED
				update_appearance(UPDATE_ICON_STATE)
				return ITEM_INTERACT_SUCCESS

		if(FRAME_STATE_WIRED)
			if(isnull(circuit) && istype(tool, /obj/item/storage/part_replacer))
				return install_circuit_from_part_replacer(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

		if(FRAME_STATE_BOARD_INSTALLED)
			if(istype(tool, /obj/item/storage/part_replacer))
				return install_parts_from_part_replacer(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	return  .

// Override of base_item_interaction so we only try to add parts to the frame AFTER running item_interaction and all the tool_acts
/obj/structure/frame/machine/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(user.combat_mode)
		return NONE

	return add_part(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/**
 * Attempt to finalize the construction of the frame into a machine
 * as according to our circuit and parts
 *
 * If successful, results in qdel'ing the frame and newing of a machine
 *
 * Arguments
 * * user - the player
 * * tool - the tool used to finalize the construction
 */
/obj/structure/frame/machine/finalize_construction(mob/living/user, obj/item/tool)
	if(locate(circuit.build_path) in loc)
		balloon_alert(user, "identical machine present!")
		return FALSE
	for(var/component in req_components)
		if(req_components[component] > 0)
			user.balloon_alert(user, "missing components!")
			return FALSE

	tool.play_tool_sound(src)
	var/obj/machinery/new_machine = new circuit.build_path(loc)
	if(istype(new_machine))
		new_machine.clear_components()
		// Set anchor state
		new_machine.set_anchored(anchored)
		// Prevent us from dropping stuff thanks to /Exited
		var/obj/item/circuitboard/machine/leaving_circuit = circuit
		circuit = null
		// Assign the circuit & parts & move them all at once into the machine
		// no need to separately move circuit board as its already part of the components list
		new_machine.circuit = leaving_circuit
		new_machine.component_parts = components
		for (var/obj/new_part in components)
			new_part.forceMove(new_machine)
		//Inform machine that its finished & cleanup
		new_machine.RefreshParts()
		new_machine.on_construction(user)
		components = null
	qdel(src)
	return TRUE

/obj/structure/frame/machine/secured
	icon_state = "box_1"
	state = FRAME_STATE_WIRED
	anchored = TRUE
