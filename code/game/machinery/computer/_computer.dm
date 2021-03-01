/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	max_integrity = 200
	integrity_failure = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 40, ACID = 20)
	var/brightness_on = 1
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/time_to_screwdrive = 20
	var/authenticated = 0

/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	power_change()

/obj/machinery/computer/Destroy()
	. = ..()

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	return TRUE

/obj/machinery/computer/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		. += "[icon_keyboard]_off"
		return
	. += icon_keyboard

	// This whole block lets screens ignore lighting and be visible even in the darkest room
	var/overlay_state = icon_screen
	if(machine_stat & BROKEN)
		overlay_state = "[icon_state]_broken"
	SSvis_overlays.add_vis_overlay(src, icon, overlay_state, layer, plane, dir)
	SSvis_overlays.add_vis_overlay(src, icon, overlay_state, layer, EMISSIVE_PLANE, dir)

/obj/machinery/computer/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
	else
		set_light(brightness_on)

/obj/machinery/computer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, "<span class='notice'>You start to disconnect the monitor...</span>")
		if(I.use_tool(src, user, time_to_screwdrive, volume=50))
			deconstruct(TRUE, user)
	return TRUE

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/computer/obj_break(damage_flag)
	if(!circuit) //no circuit, no breaking
		return
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		set_light(0)

/obj/machinery/computer/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		switch(severity)
			if(1)
				if(prob(50))
					obj_break(ENERGY)
			if(2)
				if(prob(10))
					obj_break(ENERGY)

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
					to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"
		for(var/obj/C in src)
			C.forceMove(loc)
	qdel(src)

/obj/machinery/computer/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, !issilicon(user)) || !is_operational)
		return
