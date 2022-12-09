/obj/structure/frame
	name = "frame"
	icon = 'icons/obj/stock_parts.dmi'
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

/obj/structure/frame/machine/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

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

			if(istype(P, /obj/item/circuitboard/machine))
				var/obj/item/circuitboard/machine/board = P
				if(!board.build_path)
					to_chat(user, span_warning("This circuitboard seems to be broken."))
					return
				if(!anchored && board.needs_anchored)
					to_chat(user, span_warning("The frame needs to be secured first!"))
					return
				if(!user.transferItemToLoc(board, src))
					return
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
				to_chat(user, span_notice("You add the circuit board to the frame."))
				circuit = board
				icon_state = "box_2"
				state = 3
				components = list()
				req_components = board.req_components.Copy()
				update_namelist(board.specific_parts)
				return

			else if(istype(P, /obj/item/circuitboard))
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
						// Machines will init with a set of default components. Move to nullspace so we don't trigger handle_atom_del, then qdel.
						// Finally, replace with this frame's parts.
						if(new_machine.circuit)
							// Move to nullspace and delete.
							new_machine.circuit.moveToNullspace()
							QDEL_NULL(new_machine.circuit)
						for(var/obj/old_part in new_machine.component_parts)
							// Move to nullspace and delete.
							old_part.moveToNullspace()
							qdel(old_part)

						// Set anchor state and move the frame's parts over to the new machine.
						// Then refresh parts and call on_construction().

						new_machine.set_anchored(anchored)
						new_machine.component_parts = list()

						circuit.forceMove(new_machine)
						new_machine.component_parts += circuit
						new_machine.circuit = circuit

						for (var/obj/new_part in src)
							new_part.forceMove(new_machine)

						new_machine.component_parts = components
						components = null

						new_machine.RefreshParts()

						new_machine.on_construction()
					qdel(src)
				return

			if(istype(P, /obj/item/storage/part_replacer) && P.contents.len && get_req_components_amt())
				var/obj/item/storage/part_replacer/replacer = P
				var/list/added_components = list()
				var/list/part_list = list()

				//Assemble a list of current parts, then sort them by their rating!
				for(var/obj/item/co in replacer)
					part_list += co
				//Sort the parts. This ensures that higher tier items are applied first.
				part_list = sortTim(part_list, GLOBAL_PROC_REF(cmp_rped_sort))

				for(var/path in req_components)
					while(req_components[path] > 0 && (locate(path) in part_list))
						var/obj/item/part = (locate(path) in part_list)
						part_list -= part
						if(istype(part,/obj/item/stack))
							var/obj/item/stack/S = part
							var/used_amt = min(round(S.get_amount()), req_components[path])
							if(!used_amt || !S.use(used_amt))
								continue
							var/NS = new S.merge_type(src, used_amt)
							added_components[NS] = path
							req_components[path] -= used_amt
						else
							added_components[part] = path
							if(replacer.atom_storage.attempt_remove(part, src))
								req_components[path]--

				for(var/obj/item/part in added_components)
					if(istype(part,/obj/item/stack))
						var/obj/item/stack/incoming_stack = part
						for(var/obj/item/stack/merge_stack in components)
							if(incoming_stack.can_merge(merge_stack))
								incoming_stack.merge(merge_stack)
								if(QDELETED(incoming_stack))
									break
					if(!QDELETED(part)) //If we're a stack and we merged we might not exist anymore
						components += part
						part.forceMove(src)
					to_chat(user, span_notice("You add [part] to [src]."))
				if(added_components.len)
					replacer.play_rped_sound()
				return

			for(var/stock_part_base in req_components)
				var/stock_part_path

				if (ispath(stock_part_base, /obj/item))
					stock_part_path = stock_part_base
				else if (ispath(stock_part_base, /datum/stock_part))
					var/datum/stock_part/stock_part_datum_type = stock_part_base
					stock_part_path = initial(stock_part_datum_type.physical_object_type)
				else
					stack_trace("Bad stock part in req_components: [stock_part_base]")
					continue

				if (req_components[stock_part_path] == 0)
					continue

				if (!istype(P, stock_part_path))
					continue

				if(isstack(P))
					var/obj/item/stack/S = P
					var/used_amt = min(round(S.get_amount()), req_components[stock_part_path])

					if(used_amt && S.use(used_amt))
						var/obj/item/stack/NS = locate(S.merge_type) in components

						if(!NS)
							NS = new S.merge_type(src, used_amt)
							components += NS
						else
							NS.add(used_amt)

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
