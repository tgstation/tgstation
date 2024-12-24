/obj/structure/frame
	name = "frame"
	desc = "A generic looking construction frame. One day this will be something greater."
	icon = 'icons/obj/devices/stock_parts.dmi'
	icon_state = "box_0"
	base_icon_state = "box_"
	density = TRUE
	max_integrity = 250
	/// What board do we accept
	var/board_type = /obj/item/circuitboard
	/// Reference to the circuit inside the frame
	VAR_FINAL/obj/item/circuitboard/machine/circuit
	/// The current (de/con)struction state of the frame
	var/state = FRAME_STATE_EMPTY

/obj/structure/frame/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/frame/examine(user)
	. = ..()
	if(circuit)
		. += "It has \a [circuit] installed."

/obj/structure/frame/CanAllowThrough(atom/movable/mover, border_dir)
	if(isprojectile(mover))
		return TRUE
	return ..()

/obj/structure/frame/atom_deconstruct(disassembled = TRUE)
	var/atom/movable/drop_loc = drop_location()
	new /obj/item/stack/sheet/iron(drop_loc, 5)
	circuit?.forceMove(drop_loc)

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

/obj/structure/frame/Destroy()
	QDEL_NULL(circuit)
	return ..()

/obj/structure/frame/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][state]"

/// Checks if the frame can be disassembled, and if so, begins the process
/obj/structure/frame/proc/try_dissassemble(mob/living/user, obj/item/tool, disassemble_time = 8 SECONDS)
	if(state != FRAME_STATE_EMPTY)
		return NONE
	if(anchored && state == FRAME_STATE_EMPTY) //when using a screwdriver on an incomplete frame(missing components) no point checking for this
		balloon_alert(user, "must be unanchored first!")
		return ITEM_INTERACT_BLOCKING
	if(!tool.tool_start_check(user, amount = (tool.tool_behaviour == TOOL_WELDER ? 1 : 0)))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "disassembling...")
	user.visible_message(
		span_warning("[user] begins disassembling [src]."),
		span_notice("You start to disassemble [src]..."),
		span_hear("You hear banging and clanking."),
	)
	if(!tool.use_tool(src, user, disassemble_time, amount = (tool.tool_behaviour == TOOL_WELDER ? 1 : 0), volume = 50) || state != FRAME_STATE_EMPTY)
		return ITEM_INTERACT_BLOCKING

	var/turf/decon_turf = get_turf(src)
	deconstruct(TRUE)
	for(var/obj/item/stack/leftover in decon_turf)
		leftover.add_fingerprint(user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/frame/screwdriver_act(mob/living/user, obj/item/tool)
	return try_dissassemble(user, tool, disassemble_time = 8 SECONDS)

/obj/structure/frame/welder_act(mob/living/user, obj/item/tool)
	return try_dissassemble(user, tool, disassemble_time = 2 SECONDS)

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
	. = NONE
	switch(default_unfasten_wrench(user, tool, 4 SECONDS))
		if(SUCCESSFUL_UNFASTEN)
			return ITEM_INTERACT_SUCCESS
		if(FAILED_UNFASTEN)
			return ITEM_INTERACT_BLOCKING
	return .

/obj/structure/frame/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/circuitboard)) // Install board will fail if passed an invalid circuitboard and give feedback
		return install_board(user, tool, by_hand = TRUE) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	return NONE

/obj/structure/frame/ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE

	if(!istype(tool, /obj/item/storage/part_replacer/bluespace))
		return

	. = item_interaction(user, tool, modifiers)
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		user.Beam(tool, icon_state = "rped_upgrade", time = 0.5 SECONDS)

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
/obj/structure/frame/proc/install_board(mob/living/user, obj/item/circuitboard/board, by_hand = FALSE)
	if(!istype(board, board_type) || !board.build_path)
		balloon_alert(user, "invalid board!")
		return FALSE
	if(by_hand && !user.transferItemToLoc(board, src))
		return FALSE
	else if(!board.forceMove(src))
		return FALSE

	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	balloon_alert(user, "circuit installed")
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
	for(var/obj/item/circuitboard/board as anything in replacer)
		if(istype(board, board_type))
			circuit_boards[board.name] = board

	if(!length(circuit_boards))
		return FALSE

	//if there is only one board directly install it else pick from list
	var/obj/item/circuitboard/target_board
	if(length(circuit_boards) == 1)
		for(var/board_name in circuit_boards)
			target_board = circuit_boards[board_name]

	else
		var/option = tgui_input_list(user, "Select Circuitboard To Install"," Available Boards", circuit_boards)
		target_board = circuit_boards[option]
		// Everything still where it should be after the UI closed?
		if(QDELETED(target_board) || QDELETED(src) || QDELETED(user) || !(target_board in replacer) || !user.is_holding(replacer))
			return FALSE
		// User still within range?
		var/close_enough = istype(replacer, /obj/item/storage/part_replacer/bluespace) || user.Adjacent(src)
		if(!close_enough)
			return FALSE

	if(install_board(user, target_board, by_hand = FALSE))
		// After installing, attempts to follow up by inserting parts
		install_parts_from_part_replacer(user, replacer, no_sound = TRUE)
		if(!no_sound)
			replacer.play_rped_sound()
		return TRUE

	return FALSE

/**
 * Attempt to install necessary parts from the contents of an RPED
 *
 * Arguments
 * * user - the player
 * * replacer - the RPED being used
 * * no_sound - if true, no sound will be played
 */
/obj/structure/frame/proc/install_parts_from_part_replacer(mob/living/user, obj/item/storage/part_replacer/replacer, no_sound = FALSE)
	return FALSE
