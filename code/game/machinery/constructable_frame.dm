/obj/structure/frame
	name = "frame"
	desc = "A generic looking construction frame. One day this will be something greater."
	icon = 'icons/obj/assemblies/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	max_integrity = 250
	var/obj/item/circuitboard/machine/circuit = null
	var/state = 1

/obj/structure/frame/examine(user)
	. = ..()
	if(circuit)
		. += "It has \a [circuit] installed."


/obj/structure/frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 5)
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	qdel(src)


/obj/structure/frame/machine
	name = "machine frame"
	desc = "The standard frame for most station appliances. Its appearance and function is controlled by the inserted board."
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null // user-friendly names of components

/obj/structure/frame/machine/examine(user)
	. = ..()
	if(state != 3)
		return

	if(!length(req_components))
		. += span_info("It requires no components.")
		return .

	if(!req_component_names)
		stack_trace("[src]'s req_components list has items but its req_component_names list is null!")
		return

	var/list/nice_list = list()
	for(var/component in req_components)
		if(!ispath(component))
			stack_trace("An item in [src]'s req_components list is not a path!")
			continue
		if(!req_components[component])
			continue

		nice_list += list("[req_components[component]] [req_component_names[component]]\s")
	. += span_info("It requires [english_list(nice_list, "no more components")].")

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

/**
 * install the circuitboard in this frame
 * * board - the machine circuitboard to install
 * * user - the player
 * * by_hand - is the player installing the board by hand or from the RPED. Used to decide how to transfer the board into the frame
 */
/obj/structure/frame/machine/proc/install_board(obj/item/circuitboard/machine/board, mob/user, by_hand)
	if(!board.build_path)
		to_chat(user, span_warning("This circuitboard seems to be broken."))
		return
	if(!anchored && board.needs_anchored)
		to_chat(user, span_warning("The frame needs to be secured first!"))
		return
	if(by_hand && !user.transferItemToLoc(board, src))
		return
	else if(!board.forceMove(src))
		return

	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	to_chat(user, span_notice("You add the circuit board to the frame."))
	circuit = board
	icon_state = "box_2"
	state = 3
	components = list()
	//add circuit board as the first component to the list of components
	//required for part_replacer to locate it while exchanging parts so it does not early return in /obj/machinery/proc/exchange_parts
	components += circuit
	req_components = board.req_components.Copy()
	update_namelist(board.specific_parts)
	return TRUE

/obj/structure/frame/machine/attackby(obj/item/P, mob/living/user, params)
	switch(state)
		if(1)
			if(istype(P, /obj/item/circuitboard/machine))
				to_chat(user, span_warning("The frame needs wiring first!"))
				return
			else if(istype(P, /obj/item/circuitboard))
				to_chat(user, span_warning("This frame does not accept circuit boards of this type!"))
				return
			if(istype(P, /obj/item/stack/cable_coil))
				if(!P.tool_start_check(user, amount=5))
					return

				to_chat(user, span_notice("You start to add cables to the frame..."))
				if(P.use_tool(src, user, 20, volume=50, amount=5))
					to_chat(user, span_notice("You add cables to the frame."))
					state = 2
					icon_state = "box_1"

				return
			if(P.tool_behaviour == TOOL_SCREWDRIVER && !anchored)
				user.visible_message(span_warning("[user] disassembles the frame."), \
									span_notice("You start to disassemble the frame..."), span_hear("You hear banging and clanking."))
				if(P.use_tool(src, user, 40, volume=50))
					if(state == 1)
						to_chat(user, span_notice("You disassemble the frame."))
						var/obj/item/stack/sheet/iron/M = new (loc, 5)
						if (!QDELETED(M))
							M.add_fingerprint(user)
						qdel(src)
				return
			if(P.tool_behaviour == TOOL_WRENCH)
				var/turf/ground = get_turf(src)
				if(!anchored && ground.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
					to_chat(user, span_notice("You fail to secure [src]."))
					return
				to_chat(user, span_notice("You start [anchored ? "un" : ""]securing [src]..."))
				if(P.use_tool(src, user, 40, volume=75))
					if(state == 1)
						to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
						set_anchored(!anchored)
				return

		if(2)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start [anchored ? "un" : ""]securing [src]..."))
				if(P.use_tool(src, user, 40, volume=75))
					to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
					set_anchored(!anchored)
				return

			if(!circuit && istype(P, /obj/item/storage/part_replacer) && P.contents.len)
				var/obj/item/storage/part_replacer/replacer = P
				// map of circuitboard names to the board
				var/list/circuit_boards = list()
				for(var/obj/item/circuitboard/machine/board in replacer.contents)
					circuit_boards[board.name] = board
				if(!length(circuit_boards))
					return
				//if there is only one board directly install it else pick from list
				var/obj/item/circuitboard/machine/target_board
				if(circuit_boards.len == 1)
					for(var/board_name in circuit_boards)
						target_board = circuit_boards[board_name]
				else
					var/option = tgui_input_list(user, "Select Circuitboard To Install"," Available Boards", circuit_boards)
					target_board = circuit_boards[option]
					if(!target_board)
						return
				//install board
				if(install_board(target_board, user, FALSE))
					replacer.play_rped_sound()
					//attack this frame again with the rped so it can install stock parts since its now in state 3
					attackby(replacer, user, params)
					return

			if(!circuit && istype(P, /obj/item/circuitboard/machine))
				var/obj/item/circuitboard/machine/machine_board = P
				install_board(machine_board, user, TRUE)
				return

			else if(!circuit && istype(P, /obj/item/circuitboard))
				to_chat(user, span_warning("This frame does not accept circuit boards of this type!"))
				return

			if(P.tool_behaviour == TOOL_WIRECUTTER)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You remove the cables."))
				state = 1
				icon_state = "box_0"
				new /obj/item/stack/cable_coil(drop_location(), 5)
				return

		if(3)
			if(P.tool_behaviour == TOOL_CROWBAR)
				P.play_tool_sound(src)
				state = 2
				circuit.forceMove(drop_location())
				components.Remove(circuit)
				//spawn stack components from the circuitboards requested components since they no longer exist inside components
				for(var/component in circuit.req_components)
					if(!ispath(component, /obj/item/stack))
						continue
					var/obj/item/stack/stack_path = component
					var/stack_amount = circuit.req_components[component] - req_components[component]
					if(stack_amount > 0)
						new stack_path(drop_location(), stack_amount)
				circuit = null
				if(components.len == 0)
					to_chat(user, span_notice("You remove the circuit board."))
				else
					to_chat(user, span_notice("You remove the circuit board and other components."))
					dump_contents()

				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"
				return

			if(P.tool_behaviour == TOOL_WRENCH && !circuit.needs_anchored)
				to_chat(user, span_notice("You start [anchored ? "un" : ""]securing [src]..."))
				if(P.use_tool(src, user, 40, volume=75))
					to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
					set_anchored(!anchored)
				return

			if(P.tool_behaviour == TOOL_SCREWDRIVER)
				var/component_check = TRUE
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = FALSE
						break
				if(component_check)
					P.play_tool_sound(src)
					var/obj/machinery/new_machine = new circuit.build_path(loc)
					if(istype(new_machine))
						new_machine.clear_components()

						// Set anchor state
						new_machine.set_anchored(anchored)

						// Assign the circuit & parts & move them all at once into the machine
						// no need to seperatly move circuit board as its already part of the components list
						new_machine.circuit = circuit
						new_machine.component_parts = components
						for (var/obj/new_part in components)
							new_part.forceMove(new_machine)

						//Inform machine that its finished & cleanup
						new_machine.RefreshParts()
						new_machine.on_construction(user)
						components = null
					qdel(src)
				return

			if(istype(P, /obj/item/storage/part_replacer))
				/**
				 * more efficient return so no if conditions after this are executed.
				 * Required when the rped is re attacking the frame after installing circuitboard so it returns quickly
				 */
				if(!P.contents.len || !get_req_components_amt())
					return

				var/obj/item/storage/part_replacer/replacer = P
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
						if(istype(part,/obj/item/stack))
							var/obj/item/stack/S = part
							var/used_amt = min(round(S.get_amount()), req_components[path])
							var/stack_name = S.singular_name
							if(!used_amt || !S.use(used_amt))
								continue
							req_components[path] -= used_amt
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
							to_chat(user, span_notice("You add [part] to [src]."))
							play_sound = TRUE

				if(play_sound)
					replacer.play_rped_sound()
				return

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
				if(ispath(stock_part_path, /obj/item/stack/ore/bluespace_crystal) && istype(P, /obj/item/stack/sheet/bluespace_crystal))
					//allow it
				else if(!istype(P, stock_part_path))
					continue

				if(isstack(P))
					var/obj/item/stack/S = P
					var/used_amt = min(round(S.get_amount()), req_components[stock_part_path])
					if(used_amt && S.use(used_amt))
						req_components[stock_part_path] -= used_amt
						to_chat(user, span_notice("You add [P] to [src]."))
					return

				// We might end up qdel'ing the part if it's a stock part datum.
				// In practice, this doesn't have side effects to the name,
				// but academically we should not be using an object after it's deleted.
				var/part_name = "[P]"

				if (ispath(stock_part_base, /datum/stock_part))
					// We can't just reuse stock_part_path here or its singleton,
					// or else putting in a tier 2 part will deconstruct to a tier 1 part.
					var/stock_part_datum = GLOB.stock_part_datums_per_object[P.type]
					if (isnull(stock_part_datum))
						stack_trace("[P.type] does not have an associated stock part datum!")
						continue

					components += stock_part_datum

					// We regenerate the stock parts on deconstruct.
					// This technically means we lose unique qualities of the stock part, but
					// it's worth it for how dramatically this simplifies the code.
					// The only place I can see it affecting anything is like...RPG qualities. :P
					qdel(P)
				else if(user.transferItemToLoc(P, src))
					components += P
				else
					break

				to_chat(user, span_notice("You add [part_name] to [src]."))
				req_components[stock_part_base]--
				return TRUE
			to_chat(user, span_warning("You cannot add that to the machine!"))
			return FALSE
	if(user.combat_mode)
		return ..()

/// returns instance of path1 in list else path2 in list
/obj/structure/frame/machine/proc/look_for(list/parts, path1, path2 = null)
	//look for path1 in list
	var/part = locate(path1) in parts
	if(!isnull(part))
		return part

	//optional look for path2 in list
	if(!isnull(path2))
		part = locate(path2) in parts
	return part

/obj/structure/frame/machine/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(state >= 2)
			new /obj/item/stack/cable_coil(loc , 5)

		dump_contents()
	..()

/obj/structure/frame/machine/dump_contents()
	for (var/component in components)
		if (ismovable(component))
			var/atom/movable/atom_component = component
			atom_component.forceMove(drop_location())
		else if (istype(component, /datum/stock_part))
			var/datum/stock_part/stock_part_datum = component
			var/physical_object_type = initial(stock_part_datum.physical_object_type)
			new physical_object_type(drop_location())
		else
			stack_trace("Invalid component [component] was found in constructable frame")
