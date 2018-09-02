/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	max_integrity = 200
	integrity_failure = 100
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 20)
	var/brightness_on = 1
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/clockwork = FALSE

/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	power_change()
	if(!QDELETED(C))
		qdel(circuit)
		circuit = C
		C.moveToNullspace()

/obj/machinery/computer/Destroy()
	QDEL_NULL(circuit)
	return ..()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/ratvar_act()
	if(!clockwork)
		clockwork = TRUE
		icon_screen = "ratvar[rand(1, 4)]"
		icon_keyboard = "ratvar_key[rand(1, 6)]"
		icon_state = "ratvarcomputer[rand(1, 4)]"
		update_icon()

/obj/machinery/computer/narsie_act()
	if(clockwork && clockwork != initial(clockwork)) //if it's clockwork but isn't normally clockwork
		clockwork = FALSE
		icon_screen = initial(icon_screen)
		icon_keyboard = initial(icon_keyboard)
		icon_state = initial(icon_state)
		update_icon()

/obj/machinery/computer/update_icon()
	cut_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	if(stat & NOPOWER)
		add_overlay("[icon_keyboard]_off")
		return
	add_overlay(icon_keyboard)

	// This whole block lets screens ignore lighting and be visible even in the darkest room
	// We can't do this for many things that emit light unfortunately because it layers over things that would be on top of it
	var/overlay_state = icon_screen
	if(stat & BROKEN)
		overlay_state = "[icon_state]_broken"
	SSvis_overlays.add_vis_overlay(src, icon, overlay_state, layer, plane, dir)
	SSvis_overlays.add_vis_overlay(src, icon, overlay_state, ABOVE_LIGHTING_LAYER, ABOVE_LIGHTING_PLANE, dir, alpha=128)

/obj/machinery/computer/power_change()
	..()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(brightness_on)
	update_icon()
	return

/obj/machinery/computer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, "<span class='notice'>You start to disconnect the monitor...</span>")
		if(I.use_tool(src, user, 20, volume=50))
			deconstruct(TRUE, user)
	return TRUE


/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/computer/obj_break(damage_flag)
	if(circuit && !(flags_1 & NODECONSTRUCT_1)) //no circuit, no breaking
		if(!(stat & BROKEN))
			playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)
			stat |= BROKEN
			update_icon()
			set_light(0)

/obj/machinery/computer/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		switch(severity)
			if(1)
				if(prob(50))
					obj_break("energy")
			if(2)
				if(prob(10))
					obj_break("energy")

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/frame/computer/A = new /obj/structure/frame/computer(src.loc)
			A.setDir(dir)
			A.circuit = circuit
			A.setAnchored(TRUE)
			if(stat & BROKEN)
				if(user)
					to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"
			circuit = null
		for(var/obj/C in src)
			C.forceMove(loc)

	qdel(src)
