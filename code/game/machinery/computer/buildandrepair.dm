/obj/structure/frame/computer
	name = "computer frame"
	desc = "A frame for constructing your own computer. Or console. Whichever name you prefer."
	icon_state = "0"
	state = COMPUTER_FRAME_DEFAULT

/obj/structure/frame/computer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)
	register_context()
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/frame/computer/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NO_DECONSTRUCTION))
		var/location = drop_location()
		if(state >= COMPUTER_FRAME_WIRED)
			new /obj/item/stack/cable_coil(location, 5)
		if(state == COMPUTER_FRAME_SCREEN_INSTALLED)
			new /obj/item/shard(location)
			new /obj/item/shard(location)
	..()

/obj/structure/frame/computer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	switch(state)
		if(COMPUTER_FRAME_DEFAULT)
			if(anchored)
				if(held_item.tool_behaviour == TOOL_WRENCH)
					context[SCREENTIP_CONTEXT_LMB] = "Unwrench"
					return CONTEXTUAL_SCREENTIP_SET
				else if(istype(held_item, /obj/item/circuitboard/computer))
					context[SCREENTIP_CONTEXT_LMB] = "Install board"
					return CONTEXTUAL_SCREENTIP_SET
			else
				if(held_item.tool_behaviour == TOOL_WRENCH)
					context[SCREENTIP_CONTEXT_LMB] = "wrench"
					return CONTEXTUAL_SCREENTIP_SET
				else if(held_item.tool_behaviour == TOOL_WELDER)
					context[SCREENTIP_CONTEXT_LMB] = "Unweld frame"
					return CONTEXTUAL_SCREENTIP_SET
		if(COMPUTER_FRAME_BOARD_INSTALLED)
			if(held_item.tool_behaviour == TOOL_CROWBAR)
				context[SCREENTIP_CONTEXT_LMB] = "Pry out board"
				return CONTEXTUAL_SCREENTIP_SET
			else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
				context[SCREENTIP_CONTEXT_LMB] = "Secure board"
				return CONTEXTUAL_SCREENTIP_SET
		if(COMPUTER_FRAME_BOARD_SECURED)
			if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
				context[SCREENTIP_CONTEXT_LMB] = "Unsecure board"
				return CONTEXTUAL_SCREENTIP_SET
			else if(istype(held_item, /obj/item/stack/cable_coil))
				context[SCREENTIP_CONTEXT_LMB] = "Install cable"
				return CONTEXTUAL_SCREENTIP_SET
		if(COMPUTER_FRAME_WIRED)
			if(held_item.tool_behaviour == TOOL_WIRECUTTER)
				context[SCREENTIP_CONTEXT_LMB] = "Cut out cable"
				return CONTEXTUAL_SCREENTIP_SET
			else if(istype(held_item, /obj/item/stack/sheet/glass))
				context[SCREENTIP_CONTEXT_LMB] = "Install panel"
				return CONTEXTUAL_SCREENTIP_SET
		if(COMPUTER_FRAME_SCREEN_INSTALLED)
			if(held_item.tool_behaviour == TOOL_CROWBAR)
				context[SCREENTIP_CONTEXT_LMB] = "Pry out glass"
				return CONTEXTUAL_SCREENTIP_SET
			else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
				context[SCREENTIP_CONTEXT_LMB] = "Complete frame"
				return CONTEXTUAL_SCREENTIP_SET


/obj/structure/frame/computer/examine(user)
	. = ..()

	switch(state)
		if(COMPUTER_FRAME_DEFAULT)
			if(anchored)
				. += span_notice("It can be [EXAMINE_HINT("wrenched")] loose.")
				. += span_warning("It's missing a circuit board.")
			else
				. += span_notice("It can be [EXAMINE_HINT("wrenched")] in place.")
				. += span_notice("It can be [EXAMINE_HINT("welded")] apart.")
		if(COMPUTER_FRAME_BOARD_INSTALLED)
			. += span_warning("An [circuit.name] is installed and should be [EXAMINE_HINT("screwed")] in place.")
			. += span_notice("The circuit board can be [EXAMINE_HINT("pried")] out.")
		if(COMPUTER_FRAME_BOARD_SECURED)
			. += span_warning("Its requires [EXAMINE_HINT("5 cable")] pieces to wire it.")
			. += span_notice("The circuit board can be [EXAMINE_HINT("screwed")] loose.")
		if(COMPUTER_FRAME_WIRED)
			. += span_notice("The wires can be cut out with [EXAMINE_HINT("wire cutters")].")
			. += span_warning("Its requires [EXAMINE_HINT("2 glass")] sheets to complete the screen.")
		if(COMPUTER_FRAME_SCREEN_INSTALLED)
			. += span_notice("The screen can be [EXAMINE_HINT("pried")] out.")
			. += span_notice("The moniter can be [EXAMINE_HINT("screwed")] to complete it")


/obj/structure/frame/computer/update_icon_state()
	icon_state = "[state]"
	return ..()

/**
 * Installs the board in the computer
 * Arguments
 *
 * * obj/item/circuitboard/computer/board - the board to install
 * * by_hand - are we installing it by hand or rped
 */
/obj/structure/frame/computer/proc/install_board(obj/item/circuitboard/computer/board, mob/user, by_hand)
	PRIVATE_PROC(TRUE)

	if(by_hand && !user.transferItemToLoc(board, src))
		return FALSE
	else if(!board.forceMove(src))
		return FALSE

	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	circuit = board
	circuit.add_fingerprint(user)
	state = COMPUTER_FRAME_BOARD_INSTALLED
	update_appearance(UPDATE_ICON_STATE)

	return TRUE

/obj/structure/frame/computer/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(state != COMPUTER_FRAME_DEFAULT)
		return
	if(default_unfasten_wrench(user, tool, 2 SECONDS) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/structure/frame/computer/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING

	if(state == COMPUTER_FRAME_DEFAULT && !anchored)
		if(!tool.tool_start_check(user, amount=1))
			return
		if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
			return
		var/obj/item/stack/sheet/iron/M = new (drop_location(), 5)
		if (!QDELETED(M))
			M.add_fingerprint(user)
		qdel(src)
		return ITEM_INTERACT_SUCCESS

/obj/structure/frame/computer/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING

	switch(state)
		if(COMPUTER_FRAME_BOARD_INSTALLED)
			tool.play_tool_sound(src)
			state = COMPUTER_FRAME_BOARD_SECURED
			update_appearance(UPDATE_ICON_STATE)
			return ITEM_INTERACT_SUCCESS

		if(COMPUTER_FRAME_BOARD_SECURED)
			tool.play_tool_sound(src)
			state = COMPUTER_FRAME_BOARD_INSTALLED
			update_appearance(UPDATE_ICON_STATE)
			return ITEM_INTERACT_SUCCESS

		if(COMPUTER_FRAME_SCREEN_INSTALLED)
			tool.play_tool_sound(src)

			var/obj/machinery/computer/new_computer = new circuit.build_path(loc)
			new_computer.setDir(dir)
			transfer_fingerprints_to(new_computer)
			new_computer.clear_components()

			// Set anchor state and move the frame's parts over to the new machine.
			// Then refresh parts and call on_construction().
			new_computer.set_anchored(anchored)
			new_computer.component_parts = list()

			circuit.forceMove(new_computer)
			new_computer.component_parts += circuit
			new_computer.circuit = circuit

			for(var/new_part in src)
				var/atom/movable/movable_part = new_part
				movable_part.forceMove(new_computer)
				new_computer.component_parts += movable_part

			new_computer.RefreshParts()
			new_computer.on_construction(user)

			qdel(src)
			return ITEM_INTERACT_SUCCESS

/obj/structure/frame/computer/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING

	switch(state)
		if(COMPUTER_FRAME_BOARD_INSTALLED)
			tool.play_tool_sound(src)
			circuit.forceMove(drop_location())
			circuit.add_fingerprint(user)
			circuit = null
			state = COMPUTER_FRAME_DEFAULT
			update_appearance(UPDATE_ICON_STATE)
			return ITEM_INTERACT_SUCCESS

		if(COMPUTER_FRAME_SCREEN_INSTALLED)
			tool.play_tool_sound(src)
			var/obj/item/stack/sheet/glass/G = new(drop_location(), 2)
			if (!QDELETED(G))
				G.add_fingerprint(user)
			state = COMPUTER_FRAME_WIRED
			update_appearance(UPDATE_ICON_STATE)
			return ITEM_INTERACT_SUCCESS

/obj/structure/frame/computer/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING

	if(state == COMPUTER_FRAME_WIRED)
		tool.play_tool_sound(src)
		state = COMPUTER_FRAME_BOARD_SECURED
		var/obj/item/stack/cable_coil/A = new (drop_location(), 5)
		if(!QDELETED(A))
			A.add_fingerprint(user)
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/structure/frame/computer/attackby(obj/item/weapon, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	add_fingerprint(user)

	switch(state)
		if(COMPUTER_FRAME_DEFAULT)
			if(!anchored)
				return ..()
			. = TRUE

			//attempt to install circuitboard from rped
			if(istype(weapon, /obj/item/storage/part_replacer) && weapon.contents.len)
				var/obj/item/storage/part_replacer/replacer = weapon
				// map of circuitboard names to the board
				var/list/circuit_boards = list()
				for(var/obj/item/circuitboard/computer/board in replacer.contents)
					circuit_boards[board.name] = board
				if(!length(circuit_boards))
					return
				//if there is only one board directly install it else pick from list
				var/obj/item/circuitboard/computer/target_board
				if(circuit_boards.len == 1)
					for(var/board_name in circuit_boards)
						target_board = circuit_boards[board_name]
				else
					var/option = tgui_input_list(user, "Select Circuitboard To Install"," Available Boards", circuit_boards)
					target_board = circuit_boards[option]
					if(!target_board)
						return

				if(install_board(target_board, user, by_hand = FALSE))
					replacer.play_rped_sound()
					//automatically screw the board in as well, a perk of using the rped
					to_chat(user, span_notice("You screw [circuit] into place."))
					state = COMPUTER_FRAME_BOARD_SECURED
					update_appearance(UPDATE_ICON_STATE)
					//attack again so we can install the cable & glass
					attackby(replacer, user, params)
					return

			//attempt to install circuitboard by hand
			if(istype(weapon, /obj/item/circuitboard/computer))
				install_board(weapon, user, by_hand = TRUE)
				return

			//regular attack chain
			else
				return ..()

		if(COMPUTER_FRAME_BOARD_SECURED)
			. = TRUE

			//serach for cable which can either be the attacking item or inside an rped
			var/obj/item/stack/cable_coil/cable = null
			if(istype(weapon, /obj/item/stack/cable_coil))
				cable = weapon
			else if(istype(weapon, /obj/item/storage/part_replacer))
				cable = locate(/obj/item/stack/cable_coil) in weapon.contents
			if(!cable)
				return

			//install cable
			if(!cable.tool_start_check(user, amount = 5))
				return
			if(cable.use_tool(src, user, istype(weapon, /obj/item/storage/part_replacer) ? 0 : 20, volume = 50, amount = 5))
				if(state != COMPUTER_FRAME_BOARD_SECURED)
					return
				state = COMPUTER_FRAME_WIRED
				update_appearance(UPDATE_ICON_STATE)

			//if the item was an rped then it could have glass sheets for the next stage so let it continue
			if(istype(weapon, /obj/item/storage/part_replacer))
				var/obj/item/storage/part_replacer/replacer = weapon
				replacer.play_rped_sound()
				//reattack to install the glass sheets as well
				attackby(replacer, user, params)
			return

		if(COMPUTER_FRAME_WIRED)
			. = TRUE

			//search for glass sheets which can either be the attacking item or inside an rped
			var/obj/item/stack/sheet/glass/glass_sheets = null
			if(istype(weapon, /obj/item/stack/sheet/glass))
				glass_sheets = weapon
			else if(istype(weapon, /obj/item/storage/part_replacer))
				glass_sheets = locate(/obj/item/stack/sheet/glass) in weapon.contents
			if(!glass_sheets)
				return

			//install glass sheets
			if(!glass_sheets.tool_start_check(user, amount = 2))
				return
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			if(glass_sheets.use_tool(src, user, istype(weapon, /obj/item/storage/part_replacer) ? 0 : 20, amount = 2))
				if(state != COMPUTER_FRAME_WIRED)
					return
				state = COMPUTER_FRAME_SCREEN_INSTALLED
				update_appearance(UPDATE_ICON_STATE)

			if(istype(weapon, /obj/item/storage/part_replacer))
				var/obj/item/storage/part_replacer/replacer = weapon
				replacer.play_rped_sound()
			return

/obj/structure/frame/computer/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/// Helpers for rcd
/obj/structure/frame/computer/rcd
	icon = 'icons/hud/radial.dmi'
	icon_state = "cnorth"

/obj/structure/frame/computer/rcd/Initialize(mapload)
	name = "computer frame"
	icon = 'icons/obj/devices/stock_parts.dmi'

	. = ..()

	set_anchored(TRUE)

/obj/structure/frame/computer/rcd/north
	dir = NORTH
	name = "Computer North"
	icon_state = "cnorth"

/obj/structure/frame/computer/rcd/south
	dir = SOUTH
	name = "Computer South"
	icon_state = "csouth"

/obj/structure/frame/computer/rcd/east
	dir = EAST
	name = "Computer East"
	icon_state = "ceast"

/obj/structure/frame/computer/rcd/west
	dir = WEST
	name = "Computer West"
	icon_state = "cwest"
