/obj/machinery/power/am_engine
	icon = 'AM_Engine.dmi'
	density = 1
	anchored = 1.0
	flags = ON_BORDER

/obj/machinery/power/am_engine/bits
	name = "Antimatter Engine"
	icon_state = "1"

/obj/machinery/power/am_engine/engine
	name = "Antimatter Engine"
	icon_state = "am_engine"
	var/engine_id = 0
	var/H_fuel = 0
	var/antiH_fuel = 0
	var/operating = 0
	var/stopping = 0
	var/obj/machinery/power/am_engine/injector/connected = null

/obj/machinery/power/am_engine/injector
	name = "Injector"
	icon_state = "injector"
	var/engine_id = 0
	var/injecting = 0
	var/fuel = 0
	var/obj/machinery/power/am_engine/engine/connected = null

//injector

/obj/machinery/power/am_engine/injector/New()
	..()
	spawn( 13 )
		var/loc = get_step(src, NORTH)
		src.connected = locate(/obj/machinery/power/am_engine/engine, get_step(loc, NORTH))
		return
	return


/obj/machinery/power/am_engine/injector/attackby(obj/item/weapon/fuel/F, mob/user)
	if( (stat & BROKEN) || !connected) return

	if(istype(F, /obj/item/weapon/fuel/H))
		if(injecting)
			user << "Theres already a fuel rod in the injector!"
			return
		user << "You insert the rod into the injector"
		injecting = 1
		var/fuel = F.fuel
		del(F)
		spawn( 300 )
			injecting = 0
			new/obj/item/weapon/fuel(src.loc)
			connected.H_fuel += fuel

	if(istype(F, /obj/item/weapon/fuel/antiH))
		if(injecting)
			user << "Theres already a fuel rod in the injector!"
			return
		user << "You insert the rod into the injector"
		injecting = 1
		var/fuel = F.fuel
		del(F)
		spawn( 300 )
			injecting = 0
			new /obj/item/weapon/fuel(src.loc)
			connected.antiH_fuel += fuel

	return


//engine


/obj/machinery/power/am_engine/engine/New()
	..()
	spawn( 7 )
		var/loc = get_step(src, SOUTH)
		src.connected = locate(/obj/machinery/power/am_engine/injector, get_step(loc, SOUTH))
		return
	return


/obj/machinery/power/am_engine/engine/proc/engine_go()

	if( (!src.connected) || (stat & BROKEN) )
		return

	if(!antiH_fuel || !H_fuel)
		return

	operating = 1
	var/energy = 0

	if(antiH_fuel == H_fuel)
		var/mass = antiH_fuel + H_fuel
		energy = convert2energy(mass)
		H_fuel = 0
		antiH_fuel = 0
	else
		var/residual_matter = modulus(H_fuel - antiH_fuel)
		var/mass = antiH_fuel + H_fuel - residual_matter
		energy = convert2energy(mass)
		if( H_fuel > antiH_fuel )
			H_fuel = residual_matter
			antiH_fuel = 0
		else
			H_fuel = 0
			antiH_fuel = residual_matter

	for(var/mob/M in hearers(src, null))
		M.show_message(text("\red You hear a loud bang!"))

	//Q = k x (delta T)

	energy = energy*0.75
	operating = 0

	//TODO: DEFERRED Heat tile

	return


/obj/machinery/power/am_engine/engine/proc/engine_process()

	do
		if( (!src.connected) || (stat & BROKEN) )
			return

		if(!antiH_fuel || !H_fuel)
			return

		if(operating)
			return

		operating = 1

		sleep(50)

		var/energy	//energy from the reaction
		var/H		//residual matter if H
		var/antiH	//residual matter if antiH
		var/mass	//total mass

		if(antiH_fuel == H_fuel)		//if they're equal then convert the whole mass to energy
			mass = antiH_fuel + H_fuel
			energy = convert2energy(mass)

		else	//else if they're not equal determine which isn't equal
				//and set it equal to either H or antiH so we don't lose anything

			var/residual_matter = modulus(H_fuel - antiH_fuel)
			mass = antiH_fuel + H_fuel - residual_matter
			energy = convert2energy(mass)

			if( H_fuel > antiH_fuel )
				H = residual_matter
			else
				antiH = residual_matter


		if(energy > convert2energy(8e-12))	//TOO MUCH ENERGY
			for(var/mob/M in hearers(src, null))
				M.show_message(text("\red You hear a loud whirring!"))
			sleep(20)

			//Q = k x (delta T)
			//Too much energy so machine panics and dissapates half of it as heat
			//The rest of the energetic photons then form into H and anti H particles again!

			H_fuel -= H
			antiH_fuel -= antiH
			antiH_fuel = antiH_fuel/2
			H_fuel = H_fuel/2

			energy = convert2energy(H_fuel + antiH_fuel)

			H_fuel += H
			antiH_fuel += antiH

			if(energy > convert2energy(8e-12))	//FAR TOO MUCH ENERGY STILL
				for(var/mob/M in hearers(src, null))
					M.show_message(text("\red <big>BANG!</big>"))
				new /obj/effect/bhole(src.loc)

		else	//this amount of energy is okay so it does the proper output thing

			sleep(60)
			//E = Pt
			//Lets say its 86% efficient
			var/output = 0.86*energy/20
			add_avail(output)
	//yeah the machine realises that something isn't right and accounts for it if H or antiH
			H_fuel -= H
			antiH_fuel -= antiH
			antiH_fuel = antiH_fuel/4
			H_fuel = H_fuel/4
			H_fuel += H
			antiH_fuel += antiH
		operating = 0
		sleep(100)

	while(!stopping)

	stopping = 0

	return