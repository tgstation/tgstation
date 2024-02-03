/obj/structure/frame
	name = "frame"
	desc = "A generic looking construction frame. One day this will be something greater."
	icon = 'icons/obj/devices/stock_parts.dmi'
	icon_state = "box_0"
	base_icon_state = "box_"
	density = TRUE
	max_integrity = 250
	/// Reference to the circuit inside the frame
	VAR_FINAL/obj/item/circuitboard/machine/circuit
	/// The current (de/con)struction state of the frame
	var/state = FRAME_STATE_EMPTY

/obj/structure/frame/examine(user)
	. = ..()
	if(circuit)
		. += "It has \a [circuit] installed."

/obj/structure/frame/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NO_DECONSTRUCTION))
		var/atom/movable/drop_loc = drop_location()
		new /obj/item/stack/sheet/iron(drop_loc, 5)
		circuit?.forceMove(drop_loc)

	qdel(src)

/// Called when circuit has been set to a new board
/obj/structure/frame/proc/circuit_added(obj/item/circuitboard/added)
	return

/// Called when circuit has been removed from the frame
/obj/structure/frame/proc/circuit_removed(obj/item/circuitboard/removed)
	return

/obj/structure/frame/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != circuit)
		return
	circuit = null

	if(QDELING(src))
		return

	circuit_removed(gone)
	state -= 1
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/frame/Destroy()
	QDEL_NULL(circuit)
	return ..()

/obj/structure/frame/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][state]"

/// Checks if the frame can be disassembled, and if so, begins the process
/obj/structure/frame/proc/try_dissassemble(mob/living/user, obj/item/tool, disassemble_time = 8 SECONDS)
	if(state != FRAME_STATE_EMPTY)
		return FALSE
	if(obj_flags & NO_DECONSTRUCTION)
		return FALSE
	if(!tool.tool_start_check(user, amount = 1))
		return FALSE

	balloon_alert(user, "disassembling...")
	user.visible_message(
		span_warning("[user] begins disassembling [src]."),
		span_notice("You start to disassemble [src]..."),
		span_hear("You hear banging and clanking."),
	)
	if(!tool.use_tool(src, user, disassemble_time, amount = 1, volume = 50) || state != FRAME_STATE_EMPTY)
		return FALSE

	var/turf/decon_turf = get_turf(src)
	deconstruct(TRUE)
	for(var/obj/item/stack/leftover in decon_turf)
		leftover.add_fingerprint(user)
	return TRUE

/obj/structure/frame/screwdriver_act(mob/living/user, obj/item/tool)
	return try_dissassemble(user, tool, disassemble_time = 8 SECONDS) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/structure/frame/welder_act(mob/living/user, obj/item/tool)
	return try_dissassemble(user, tool, disassemble_time = 2 SECONDS) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/**
 * Attempt to finalize the construction of the frame into a machine
 *
 * If successful, results in qdel'ing the frame and newing of a machine
 *
 * Arguments
 * * user - the player
 * * tool - the tool used to finalize the construction
 */
/obj/structure/frame/proc/finalize_construction(mob/living/user, obj/item/tool)
	stack_trace("[type] finalize_construction unimplemented.")
	return FALSE

/obj/structure/frame/wrench_act(mob/living/user, obj/item/tool)
	switch(default_unfasten_wrench(user, tool, 4 SECONDS))
		if(SUCCESSFUL_UNFASTEN)
			return ITEM_INTERACT_SUCCESS
		if(FAILED_UNFASTEN)
			return ITEM_INTERACT_BLOCKING

	return NONE

/**
 * Installs the passed circuit board into the frame
 *
 * Assumes there is no circuit already installed
 *
 * Arguments
 * * board - the machine circuitboard to install
 * * user - the player
 * * by_hand - is the player installing the board by hand or from the RPED.
 * Used to decide how to transfer the board into the frame
 */
/obj/structure/frame/proc/install_board(obj/item/circuitboard/board, mob/user, by_hand = FALSE)
	if(by_hand && !user.transferItemToLoc(board, src))
		return FALSE
	else if(!board.forceMove(src))
		return FALSE

	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	to_chat(user, span_notice("You place [board] inside the frame."))
	circuit = board
	if(by_hand)
		circuit.add_fingerprint(user)
	circuit_added(board)
	return TRUE

/**
 * Attempt to install a circuit from the contents of an RPED
 *
 * Arguments
 * * user - the player
 * * replacer - the RPED being used
 * * no_sound - if true, no sound will be played
 */
/obj/structure/frame/proc/install_circuit_from_part_replacer(mob/living/user, obj/item/storage/part_replacer/replacer, no_sound = FALSE)
	if(!length(replacer.contents))
		return FALSE

	var/list/circuit_boards = list()
	for(var/obj/item/circuitboard/machine/board in replacer)
		circuit_boards[board.name] = board

	if(!length(circuit_boards))
		return FALSE

	//if there is only one board directly install it else pick from list
	var/obj/item/circuitboard/machine/target_board
	if(length(circuit_boards) == 1)
		for(var/board_name in circuit_boards)
			target_board = circuit_boards[board_name]

	else
		var/option = tgui_input_list(user, "Select Circuitboard To Install"," Available Boards", circuit_boards)
		target_board = circuit_boards[option]
		if(QDELETED(target_board) || QDELETED(src) || QDELETED(user) || !(target_board in replacer) || !user.is_holding(replacer) || !user.Adjacent(src))
			return FALSE

	if(install_board(user, target_board, by_hand = FALSE))
		// After installing, attempts to follow up by inserting parts
		install_parts_from_part_replacer(user, replacer, no_sound = TRUE)
		if(!no_sound)
			replacer.play_rped_sound()
		return TRUE

	return FALSE

/obj/structure/frame/proc/install_parts_from_part_replacer(mob/living/user, obj/item/storage/part_replacer/replacer, no_sound = FALSE)
	return FALSE

/obj/structure/frame/machine
	name = "machine frame"
	desc = "The standard frame for most station appliances. Its appearance and function is controlled by the inserted board."
	/// List of all compnents inside the frame contributing to its construction
	var/list/components
	/// List of all components required to construct the frame
	var/list/req_components
	/// User-friendly list of names of required components
	var/list/req_component_names

/obj/structure/frame/machine/examine(user)
	. = ..()
	if(state != FRAME_STATE_BOARD_INSTALLED)
		return .

	if(!length(req_components))
		. += span_info("It requires no components.")
		return .

	if(!req_component_names)
		stack_trace("[src]'s req_components list has items but its req_component_names list is null!")
		return .

	var/list/nice_list = list()
	for(var/component in req_components)
		if(!ispath(component))
			stack_trace("An item in [src]'s req_components list is not a path!")
			continue
		if(!req_components[component])
			continue

		nice_list += list("[req_components[component]] [req_component_names[component]]\s")
	. += span_info("It requires [english_list(nice_list, "no more components")].")
	return .

/**
 * Collates the displayed names of the machine's components
 *
 * Arguments:
 * * specific_parts - If true, the component should not use base name, but a specific tier
 */
/obj/structure/frame/machine/proc/update_namelist(specific_parts)
	if(!req_components)
		return

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

			if(!specific_parts && initial(stock_part.base_name))
				req_component_names[component_path] = initial(stock_part.base_name)
			else
				req_component_names[component_path] = initial(stock_part.name)
		else if(ispath(component_path, /obj/item))
			var/obj/item/part = component_path

			req_component_names[component_path] = initial(part.name)
		else
			stack_trace("Invalid component part [component_path] in [type], couldn't get its name")
			req_component_names[component_path] = "[component_path] (this is a bug)"

/obj/structure/frame/machine/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

/obj/structure/frame/machine/try_dissassemble(mob/living/user, obj/item/tool)
	if(anchored)
		balloon_alert(user, "must be unsecured first!")
		return FALSE
	return ..()

/obj/structure/frame/machine/install_board(mob/living/user, obj/item/circuitboard/machine/board, by_hand = TRUE)
	if(!board.build_path)
		to_chat(user, span_warning("This circuitboard seems to be broken."))
		return FALSE
	if(!anchored && board.needs_anchored)
		to_chat(user, span_warning("[src] needs to be secured first!"))
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
	update_namelist(added.specific_parts)

/obj/structure/frame/machine/circuit_removed(obj/item/circuitboard/machine/removed)
	state = FRAME_STATE_WIRED
	update_appearance(UPDATE_ICON_STATE)

/**
 * Attempt to install necessary parts from the contents of an RPED
 *
 * Arguments
 * * user - the player
 * * replacer - the RPED being used
 * * no_sound - if true, no sound will be played
 */
/obj/structure/frame/machine/install_parts_from_part_replacer(mob/living/user, obj/item/storage/part_replacer/replacer, no_sound = FALSE)
	if(!length(replacer.contents) || !get_req_components_amt())
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
			//allow it
			pass()
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
	for(var/component in req_components)
		if(req_components[component] > 0)
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
		// no need to seperatly move circuit board as its already part of the components list
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

/obj/structure/frame/machine/item_interaction(mob/living/user, obj/item/tool, list/modifiers, is_right_clicking)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .

	if(istype(tool, /obj/item/circuitboard/machine))
		if(state == FRAME_STATE_EMPTY)
			balloon_alert(user, "needs wiring!")
			return ITEM_INTERACT_BLOCKING

		if(state == FRAME_STATE_BOARD_INSTALLED)
			balloon_alert(user, "circuit already installed!")
			return ITEM_INTERACT_BLOCKING

		return install_board(user, tool, by_hand = TRUE) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/circuitboard) && isnull(circuit))
		balloon_alert(user, "incompatible board!")
		return ITEM_INTERACT_BLOCKING

	switch(state)
		if(FRAME_STATE_EMPTY)
			if(istype(tool, /obj/item/stack/cable_coil))
				if(!tool.tool_start_check(user, amount = 5))
					return ITEM_INTERACT_BLOCKING

				balloon_alert(user, "adding cables...")
				if(!tool.use_tool(src, user, 20, volume=50, amount=5) || state != FRAME_STATE_EMPTY)
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

			if(!user.combat_mode)
				return add_part(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	return .

/obj/structure/frame/machine/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(state != FRAME_STATE_BOARD_INSTALLED)
		return .

	if(finalize_construction(user, tool))
		return ITEM_INTERACT_SUCCESS

	balloon_alert(user, "missing components!")
	return ITEM_INTERACT_BLOCKING

/obj/structure/frame/machine/can_be_unfasten_wrench(mob/user, silent)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return .

	if(circuit?.needs_anchored)
		balloon_alert("circuit must be anchored!")
		return FAILED_UNFASTEN

	return .

/obj/structure/frame/machine/wirecutter_act(mob/living/user, obj/item/tool)
	if(state != FRAME_STATE_WIRED)
		return NONE

	balloon_alert(user, "removing cables...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50, amount = 5) || state != FRAME_STATE_WIRED)
		return ITEM_INTERACT_BLOCKING

	state = FRAME_STATE_EMPTY
	update_appearance(UPDATE_ICON_STATE)
	new /obj/item/stack/cable_coil(drop_location(), 5)
	return ITEM_INTERACT_SUCCESS

/obj/structure/frame/machine/crowbar_act(mob/living/user, obj/item/tool)
	if(state != FRAME_STATE_BOARD_INSTALLED)
		return NONE

	tool.play_tool_sound(src)
	var/list/leftover_components = components.Copy()
	dump_contents()
	balloon_alert(user, "circuit board[length(leftover_components) ? " and components" : ""] removed")
	return ITEM_INTERACT_SUCCESS

/obj/structure/frame/machine/Exited(atom/movable/gone, direction)
	if(gone == circuit)
		components -= circuit
	return ..()

/obj/structure/frame/machine/Destroy()
	QDEL_LIST(components)
	return ..()

/**
 * Returns the instance of path1 in list, else path2 in list
 *
 * Arguments
 * * parts - the list of parts to search
 * * path1 - the first path to search for
 * * path2 - the second path to search for, if path1 is not found
 */
/obj/structure/frame/machine/proc/look_for(list/parts, path1, path2)
	return (locate(path1) in parts) || (path2 ? (locate(path2) in parts) : null)

/obj/structure/frame/machine/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NO_DECONSTRUCTION))
		if(state >= FRAME_STATE_WIRED)
			new /obj/item/stack/cable_coil(drop_location(), 5)
		dump_contents()
	return ..()

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

/obj/structure/frame/machine/secured
	state = FRAME_STATE_WIRED
	anchored = TRUE

/obj/structure/frame/machine/secured/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)
