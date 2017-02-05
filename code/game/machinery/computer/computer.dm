

/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = 1
	anchored = 1
	use_power = 1
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
	var/list/printer_spooler = list()
	var/printing = FALSE
	var/printer_jammed = FALSE
	// "my_printer" = list(string/startSound, string/printSound, string/jamSound, number/warmupTime, number/printTimeTillEject, number/printTimeFinish, number/jamProb)
	var/list/printer_type = list(
		"text_only" = list(0, 0, 0, 150, 200, 25, 10),
		"inkjet" = list("sound/machines/printer/inkjet/start.ogg", "sound/machines/printer/inkjet/printing.ogg", 0, 150, 200, 25, 10),
		"dot_matrix" = list(0, "sound/machines/printer/dotmatrix/printing.ogg", 0, 0, 190, 10, 0) // Dot matrix printers are bulletproof man
	)
	var/default_printer = "inkjet"


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
	..()
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
	if(clockwork && clockwork != initial(clockwork) && prob(20)) //if it's clockwork but isn't normally clockwork
		clockwork = FALSE
		icon_screen = initial(icon_screen)
		icon_keyboard = initial(icon_keyboard)
		icon_state = initial(icon_state)
		update_icon()

/obj/machinery/computer/verb/clear_printer()
	set name = "Clear printer"
	set src in view(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(printer_jammed)
		new/obj/item/weapon/paper(src.loc)
		usr.visible_message("<span class='notice'>[usr] removes a jam in the [src]'s printer.</span>", "<span class='notice'>You remove a jam in the [src]'s printer.</span>")
		printer_jammed = FALSE
		printing = TRUE
		do_print()
	else
		usr << "<span class='notice'>There's no jam of any kind in [src]'s printer.</span>"

/obj/machinery/computer/proc/do_print()
	if(!(stat & (NOPOWER|BROKEN)) & printing)
		if(printer_jammed)
			src.visible_message("<span class='danger'>The [src] printer beeps with a message: PAPER JAM</span>")
			return
		var/list/printjob = printer_spooler[1]
		var/list/printer = printer_type[default_printer]
		if(printer[7])
			if(prob(printer[7]))
				if(printer[3])
					playsound(src.loc, printer[2], 100, 0)
					src.visible_message("<span class='danger'>The [src] printer beeps with a message: PAPER JAM</span>")
				else
					src.visible_message("<span class='danger'>The [src] printer makes a cringing crunch before it beeps with a message: PAPER JAM</span>")
				printer_jammed = TRUE
				printing = FALSE
				return
		if(printer[2])
			playsound(src.loc, printer[2], 100, 0)
		else
			src.visible_message("<span class='notice'>The printer whirrs noisly as it prints a document.</span>")
		if(printer[5])
			sleep(printer[5]) // Paper is being ejected after this point
		var/obj/item/weapon/paper/P = new/obj/item/weapon/paper(src.loc)
		P.name = printjob[1]
		P.info = printjob[2]
		P.update_icon()
		P.updateinfolinks()
		printer_spooler.Cut(1,2)
		if(printer[6])
			sleep(printer[6]) // Finish the sound
		if(printer_spooler.len > 0)
			do_print()
		else
			printing = FALSE
	else
		printer_spooler = new/list()


/obj/machinery/computer/proc/new_printjob(title = "Printed Paper" , text = "")
	if(printer_spooler.len > 4)
		if(prob(20))
			src.visible_message("<span class='danger'>The [src] printer beeps with a message: PC LOAD LETTER</span>")
		else
			src.visible_message("<span class='danger'>The [src] printer beeps with a message: MEMORY FULL</span>")
		return
	else
		if(!(stat & (NOPOWER|BROKEN)))
			printer_spooler[++printer_spooler.len] = list(title, text)
		else
			return
	if(!printing)
		if(printer_jammed)
			src.visible_message("<span class='danger'>The [src] printer beeps with a message: PAPER JAM</span>")
			return
		var/list/printer = printer_type[default_printer]
		printing = TRUE
		if(printer[1])
			playsound(src.loc, printer[1], 100, 0)
		else
			src.visible_message("<span class='notice'>The [src] printer makes a nosiy clatter as it warms up.</span>")
		if(printer[4])
			sleep(printer[4]) // Wait until printer is warmed up
		do_print()



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
		SetLuminosity(0)
	else
		SetLuminosity(brightness_on)
	update_icon()
	return

/obj/machinery/computer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver) && circuit && !(flags&NODECONSTRUCT))
		playsound(src.loc, I.usesound, 50, 1)
		user << "<span class='notice'> You start to disconnect the monitor...</span>"
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
				playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/machinery/computer/obj_break(damage_flag)
	if(circuit && !(flags & NODECONSTRUCT)) //no circuit, no breaking
		if(!(stat & BROKEN))
			playsound(loc, 'sound/effects/Glassbr3.ogg', 100, 1)
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
					user << "<span class='notice'>The broken glass falls out.</span>"
				else
					playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
				new /obj/item/weapon/shard(src.loc)
				new /obj/item/weapon/shard(src.loc)
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					user << "<span class='notice'>You disconnect the monitor.</span>"
				A.state = 4
				A.icon_state = "4"
			circuit = null
		for(var/obj/C in src)
			C.forceMove(loc)

	qdel(src)
