/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 100
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 40, acid = 20)
	var/obj/item/weapon/circuitboard/computer/circuit = null // if circuit==null, computer can't disassembly
	var/processing = 0
	var/brightness_on = 2
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/clockwork = FALSE

/obj/machinery/computer/New(location, obj/item/weapon/circuitboard/C)
	..(location)
	if(C && istype(C))
		circuit = C
	//Some machines, oldcode arcades mostly, new themselves, so circuit
	//can already be an instance of a type and trying to new that will
	//cause a runtime
	else if(ispath(circuit))
		circuit = new circuit(null)

/obj/machinery/computer/Destroy()
	if(circuit)
		qdel(circuit)
		circuit = null
	return ..()

/obj/machinery/computer/Initialize()
	. = ..()
	power_change()

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
	if(stat & NOPOWER)
		add_overlay("[icon_keyboard]_off")
		return
	add_overlay(icon_keyboard)
	if(stat & BROKEN)
		add_overlay("[icon_state]_broken")
	else
		add_overlay(icon_screen)

/obj/machinery/computer/power_change()
	..()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(brightness_on)
	update_icon()
	return

/obj/machinery/computer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver) && circuit && !(flags&NODECONSTRUCT))
		playsound(src.loc, I.usesound, 50, 1)
		to_chat(user, "<span class='notice'> You start to disconnect the monitor...</span>")
		if(do_after(user, 20*I.toolspeed, target = src))
			deconstruct(TRUE, user)
	else
		return ..()

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
	if(circuit && !(flags & NODECONSTRUCT)) //no circuit, no breaking
		if(!(stat & BROKEN))
			playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)
			stat |= BROKEN
			update_icon()

/obj/machinery/computer/emp_act(severity)
	switch(severity)
		if(1)
			if(prob(50))
				obj_break("energy")
		if(2)
			if(prob(10))
				obj_break("energy")
	..()

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags & NODECONSTRUCT))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/frame/computer/A = new /obj/structure/frame/computer(src.loc)
			A.circuit = circuit
			A.anchored = 1
			if(stat & BROKEN)
				if(user)
					to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				else
					playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
				new /obj/item/weapon/shard(src.loc)
				new /obj/item/weapon/shard(src.loc)
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
