/obj/structure/frame/computer
	name = "computer frame"
	icon_state = "0"
	state = 0

/obj/structure/frame/computer/attackby(obj/item/P, mob/living/user, params)
	add_fingerprint(user)
	switch(state)
		if(0)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start wrenching the frame into place..."))
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You wrench the frame into place."))
					set_anchored(TRUE)
					state = 1
				return
			if(P.tool_behaviour == TOOL_WELDER)
				if(!P.tool_start_check(user, amount=0))
					return

				to_chat(user, span_notice("You start deconstructing the frame..."))
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You deconstruct the frame."))
					var/obj/item/stack/sheet/iron/M = new (drop_location(), 5)
					if (!QDELETED(M))
						M.add_fingerprint(user)
					qdel(src)
				return
		if(1)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start to unfasten the frame..."))
				if(P.use_tool(src, user, 20, volume=50))
					to_chat(user, span_notice("You unfasten the frame."))
					set_anchored(FALSE)
					state = 0
				return
			if(istype(P, /obj/item/circuitboard/computer) && !circuit)
				if(!user.transferItemToLoc(P, src))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				to_chat(user, span_notice("You place [P] inside the frame."))
				icon_state = "1"
				circuit = P
				circuit.add_fingerprint(user)
				return

			else if(istype(P, /obj/item/circuitboard) && !circuit)
				to_chat(user, span_warning("This frame does not accept circuit boards of this type!"))
				return
			if(P.tool_behaviour == TOOL_SCREWDRIVER && circuit)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You screw [circuit] into place."))
				state = 2
				icon_state = "2"
				return
			if(P.tool_behaviour == TOOL_CROWBAR && circuit)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You remove [circuit]."))
				state = 1
				icon_state = "0"
				circuit.forceMove(drop_location())
				circuit.add_fingerprint(user)
				circuit = null
				return
		if(2)
			if(P.tool_behaviour == TOOL_SCREWDRIVER && circuit)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You unfasten the circuit board."))
				state = 1
				icon_state = "1"
				return
			if(istype(P, /obj/item/stack/cable_coil))
				if(!P.tool_start_check(user, amount=5))
					return
				to_chat(user, span_notice("You start adding cables to the frame..."))
				if(P.use_tool(src, user, 20, volume=50, amount=5))
					if(state != 2)
						return
					to_chat(user, span_notice("You add cables to the frame."))
					state = 3
					icon_state = "3"
				return
		if(3)
			if(P.tool_behaviour == TOOL_WIRECUTTER)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You remove the cables."))
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new (drop_location(), 5)
				if (!QDELETED(A))
					A.add_fingerprint(user)
				return

			if(istype(P, /obj/item/stack/sheet/glass))
				if(!P.tool_start_check(user, amount=2))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				to_chat(user, span_notice("You start to put in the glass panel..."))
				if(P.use_tool(src, user, 20, amount=2))
					if(state != 3)
						return
					to_chat(user, span_notice("You put in the glass panel."))
					state = 4
					src.icon_state = "4"
				return
		if(4)
			if(P.tool_behaviour == TOOL_CROWBAR)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You remove the glass panel."))
				state = 3
				icon_state = "3"
				var/obj/item/stack/sheet/glass/G = new(drop_location(), 2)
				if (!QDELETED(G))
					G.add_fingerprint(user)
				return
			if(P.tool_behaviour == TOOL_SCREWDRIVER)
				P.play_tool_sound(src)
				to_chat(user, span_notice("You connect the monitor."))

				var/obj/machinery/new_machine = new circuit.build_path(loc)
				new_machine.setDir(dir)
				transfer_fingerprints_to(new_machine)

				if(istype(new_machine, /obj/machinery/computer))
					var/obj/machinery/computer/new_computer = new_machine

					// Machines will init with a set of default components.
					// Triggering handle_atom_del will make the machine realise it has lost a component_parts and then deconstruct.
					// Move to nullspace so we don't trigger handle_atom_del, then qdel.
					// Finally, replace new machine's parts with this frame's parts.
					if(new_computer.circuit)
						// Move to nullspace and delete.
						new_computer.circuit.moveToNullspace()
						QDEL_NULL(new_computer.circuit)
					for(var/old_part in new_computer.component_parts)
						var/atom/movable/movable_part = old_part
						// Move to nullspace and delete.
						movable_part.moveToNullspace()
						qdel(movable_part)

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
					new_computer.on_construction()

				qdel(src)
				return
	if(user.combat_mode)
		return ..()


/obj/structure/frame/computer/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(state == 4)
			new /obj/item/shard(drop_location())
			new /obj/item/shard(drop_location())
		if(state >= 3)
			new /obj/item/stack/cable_coil(drop_location(), 5)
	..()

/obj/structure/frame/computer/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return

	if(anchored)
		to_chat(usr, span_warning("You must unwrench [src] before rotating it!"))
		return

	setDir(turn(dir, -90))
