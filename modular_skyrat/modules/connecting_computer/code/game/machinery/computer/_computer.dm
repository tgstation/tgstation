/obj/machinery/computer
	icon = 'modular_skyrat/modules/connecting_computer/icons/obj/computer.dmi'
	///Determines if the computer can connect to other computers (no arcades, etc.)
	var/connectable = TRUE

/obj/machinery/computer/Destroy()
	for(var/obj/machinery/computer/selected in range(1, src))
		addtimer(CALLBACK(selected, .proc/callback_proc_issue), 2)
	. = ..()

/obj/machinery/computer/proc/callback_proc_issue()
	update_overlays()

/obj/machinery/computer/update_overlays()
	. = ..()
	if(icon_keyboard)
		if(machine_stat & NOPOWER)
			return . + "[icon_keyboard]_off"
		. += icon_keyboard

	// This whole block lets screens ignore lighting and be visible even in the darkest room
	var/overlay_state = icon_screen
	if(connectable)
		icon_state = initial(icon_state)
		var/obj/machinery/computer/left_turf = null
		var/obj/machinery/computer/right_turf = null
		switch(dir)
			if(NORTH)
				left_turf = locate(/obj/machinery/computer) in get_step(src, WEST)
				right_turf = locate(/obj/machinery/computer) in get_step(src, EAST)
			if(EAST)
				left_turf = locate(/obj/machinery/computer) in get_step(src, NORTH)
				right_turf = locate(/obj/machinery/computer) in get_step(src, SOUTH)
			if(SOUTH)
				left_turf = locate(/obj/machinery/computer) in get_step(src, EAST)
				right_turf = locate(/obj/machinery/computer) in get_step(src, WEST)
			if(WEST)
				left_turf = locate(/obj/machinery/computer) in get_step(src, SOUTH)
				right_turf = locate(/obj/machinery/computer) in get_step(src, NORTH)
		if(left_turf?.dir == dir && left_turf.connectable)
			icon_state = "[icon_state]_L"
		if(right_turf?.dir == dir && right_turf.connectable)
			icon_state = "[icon_state]_R"
	if(machine_stat & BROKEN)
		overlay_state = "[icon_state]_broken"
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, overlay_state)

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/frame/computer/A = new /obj/structure/frame/computer(src.loc)
			A.setDir(dir)
			A.circuit = circuit
			// Circuit removal code is handled in /obj/machinery/Exited()
			circuit.forceMove(A)
			A.set_anchored(TRUE)
			if(machine_stat & BROKEN)
				if(user)
					to_chat(user, span_notice("The broken glass falls out."))
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					to_chat(user, span_notice("You disconnect the monitor."))
				A.state = 4
				A.icon_state = "4"
		for(var/obj/C in src)
			C.forceMove(loc)
	for(var/obj/machinery/computer/selected in range(1,src))
		addtimer(CALLBACK(selected, .proc/callback_proc_issue), 2)
	qdel(src)
