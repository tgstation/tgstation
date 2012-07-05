//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:

WRENCH
SCREWDRIVER
WELDINGTOOOL
*/


// WRENCH
/obj/item/weapon/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'items.dmi'
	icon_state = "wrench"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 150
	origin_tech = "materials=1;engineering=1"



// SCREWDRIVER
/obj/item/weapon/screwdriver/New()
	switch(pick("red","blue","purple","brown","green","cyan","yellow"))
		if ("red")
			icon_state = "screwdriver2"
			item_state = "screwdriver"
		if ("blue")
			icon_state = "screwdriver"
			item_state = "screwdriver_blue"
		if ("purple")
			icon_state = "screwdriver3"
			item_state = "screwdriver_purple"
		if ("brown")
			icon_state = "screwdriver4"
			item_state = "screwdriver_brown"
		if ("green")
			icon_state = "screwdriver5"
			item_state = "screwdriver_green"
		if ("cyan")
			icon_state = "screwdriver6"
			item_state = "screwdriver_cyan"
		if ("yellow")
			icon_state = "screwdriver7"
			item_state = "screwdriver_yellow"

	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))	return ..()
	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()
	if((CLUMSY in user.mutations) && prob(50))
		M = user
	return eyestab(M,user)



// WELDING TOOL
/obj/item/weapon/weldingtool
	name = "welding tool"
	icon = 'items.dmi'
	icon_state = "welder"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT

	//Amount of OUCH when it's thrown
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

	//Cost to make in the autolathe
	m_amt = 70
	g_amt = 30

	//R&D tech level
	origin_tech = "engineering=1"

	//Welding tool specific stuff
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold

/obj/item/weapon/weldingtool/New()
//	var/random_fuel = min(rand(10,20),max_fuel)
	var/datum/reagents/R = new/datum/reagents(max_fuel)
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)
	return


/obj/item/weapon/weldingtool/examine()
	set src in usr
	usr << text("\icon[] [] contains []/[] units of fuel!", src, src.name, get_fuel(),src.max_fuel )
	return


/obj/item/weapon/weldingtool/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/screwdriver))
		if(welding)
			user << "\red Stop welding first!"
			return
		status = !status
		if(status)
			user << "\blue You resecure the welder."
		else
			user << "\blue The welder can now be attached and modified."
		src.add_fingerprint(user)
		return

	if((!status) && (istype(W,/obj/item/stack/rods)))
		var/obj/item/stack/rods/R = W
		R.use(1)
		var/obj/item/weapon/flamethrower/F = new/obj/item/weapon/flamethrower(user.loc)
		src.loc = F
		F.weldtool = src
		if (user.client)
			user.client.screen -= src
		if (user.r_hand == src)
			user.u_equip(src)
		else
			user.u_equip(src)
		src.master = F
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = F
		src.add_fingerprint(user)
		return

	..()
	return


/obj/item/weapon/weldingtool/process()
	switch(welding)
		//If off
		if(0)
			if(src.icon_state != "welder") //Check that the sprite is correct, if it isnt, it means toggle() was not called
				src.force = 3
				src.damtype = "brute"
				src.icon_state = "welder"
				src.welding = 0
			processing_objects.Remove(src)
			return
		//Welders left on now use up fuel, but lets not have them run out quite that fast
		if(1)
			if(src.icon_state != "welder1") //Check that the sprite is correct, if it isnt, it means toggle() was not called
				src.force = 15
				src.damtype = "fire"
				src.icon_state = "welder1"
			if(prob(5))
				remove_fuel(1)

		//If you're actually actively welding, use fuel faster.
		//Is this actually used or set anywhere? - Nodrak
		if(2)
			if(prob(75))
				remove_fuel(1)


	//I'm not sure what this does. I assume it has to do with starting fires...
	//...but it doesnt check to see if the welder is on or not.
	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = get_turf(M)
	if (istype(location, /turf))
		location.hotspot_expose(700, 5)


/obj/item/weapon/weldingtool/afterattack(obj/O as obj, mob/user as mob)
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && !src.welding)
		O.reagents.trans_to(src, max_fuel)
		user << "\blue Welder refueled"
		playsound(src.loc, 'refill.ogg', 50, 1, -6)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && src.welding)
		message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
		log_game("[key_name(user)] triggered a fueltank explosion.")
		user << "\red That was stupid of you."
		explosion(O.loc,-1,0,2)
		if(O)
			del(O)
		return
	if (src.welding)
		remove_fuel(1)
		var/turf/location = get_turf(user)
		if (istype(location, /turf))
			location.hotspot_expose(700, 50, 1)
	return


/obj/item/weapon/weldingtool/attack_self(mob/user as mob)
	toggle()
	return

//Returns the amount of fuel in the welder
/obj/item/weapon/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount("fuel")


//Removes fuel from the welding tool. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/weapon/weldingtool/proc/remove_fuel(var/amount = 1, var/mob/M = null)
	if(!welding || !check_fuel())
		return 0
	if(get_fuel() >= amount)
		reagents.remove_reagent("fuel", amount)
		check_fuel()
		if(M)
			eyecheck(M)
		return 1
	else
		if(M)
			M << "\blue You need more welding fuel to complete this task."
		return 0

//Returns whether or not the welding tool is currently on.
/obj/item/weapon/weldingtool/proc/isOn()
	return src.welding

//Sets the welding state of the welding tool. If you see W.welding = 1 anywhere, please change it to W.setWelding(1)
//so that the welding tool updates accordingly
/obj/item/weapon/weldingtool/proc/setWelding(var/temp_welding)
	//If we're turning it on
	if(temp_welding > 0)
		if (remove_fuel(1))
			usr << "\blue The [src] switches on."
			src.force = 15
			src.damtype = "fire"
			src.icon_state = "welder1"
			processing_objects.Add(src)
		else
			usr << "\blue Need more fuel!"
			src.welding = 0
			return
	//Otherwise
	else
		usr << "\blue The [src] switches off."
		src.force = 3
		src.damtype = "brute"
		src.icon_state = "welder"
		src.welding = 0

//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weapon/weldingtool/proc/check_fuel()
	if((get_fuel() <= 0) && welding)
		toggle(1)
		return 0
	return 1


//Toggles the welder off and on
/obj/item/weapon/weldingtool/proc/toggle(var/message = 0)
	if(!status)	return
	src.welding = !( src.welding )
	if (src.welding)
		if (remove_fuel(1))
			usr << "\blue You switch the [src] on."
			src.force = 15
			src.damtype = "fire"
			src.icon_state = "welder1"
			processing_objects.Add(src)
		else
			usr << "\blue Need more fuel!"
			src.welding = 0
			return
	else
		if(!message)
			usr << "\blue You switch the [src] off."
		else
			usr << "\blue The [src] shuts off!"
		src.force = 3
		src.damtype = "brute"
		src.icon_state = "welder"
		src.welding = 0

//Decides whether or not to damage a player's eyes based on what they're wearing as protection
//Note: This should probably be moved to mob
/obj/item/weapon/weldingtool/proc/eyecheck(mob/user as mob)
	if(!iscarbon(user))	return 1
	var/safety = user:eyecheck()
	switch(safety)
		if(1)
			usr << "\red Your eyes sting a little."
			user.eye_stat += rand(1, 2)
			if(user.eye_stat > 12)
				user.eye_blurry += rand(3,6)
		if(0)
			usr << "\red Your eyes burn."
			user.eye_stat += rand(2, 4)
			if(user.eye_stat > 10)
				user.eye_blurry += rand(4,10)
		if(-1)
			usr << "\red Your thermals intensify the welder's glow. Your eyes itch and burn severely."
			user.eye_blurry += rand(12,20)
			user.eye_stat += rand(12, 16)
	if(user.eye_stat > 10 && safety < 2)
		user << "\red Your eyes are really starting to hurt. This can't be good for you!"
	if (prob(user.eye_stat - 25 + 1))
		user << "\red You go blind!"
		user.sdisabilities |= BLIND
	else if (prob(user.eye_stat - 15 + 1))
		user << "\red You go blind!"
		user.eye_blind = 5
		user.eye_blurry = 5
		user.disabilities |= NEARSIGHTED
		spawn(100)
			user.disabilities &= ~NEARSIGHTED
	return


/obj/item/weapon/weldingtool/largetank
	name = "Industrial Welding Tool"
	max_fuel = 40
	m_amt = 70
	g_amt = 60
	origin_tech = "engineering=2"

/obj/item/weapon/weldingtool/hugetank
	name = "Upgraded Welding Tool"
	max_fuel = 80
	w_class = 3.0
	m_amt = 70
	g_amt = 120
	origin_tech = "engineering=3"

/obj/item/weapon/weldingtool/experimental
	name = "Experimental Welding Tool"
	max_fuel = 40
	w_class = 3.0
	m_amt = 70
	g_amt = 120
	origin_tech = "engineering=4;plasma=3"
	icon_state = "ewelder"
	var/last_gen = 0



/obj/item/weapon/weldingtool/experimental/proc/fuel_gen()//Proc to make the experimental welder generate fuel, optimized as fuck -Sieve
	var/gen_amount = ((world.time-last_gen)/25)
	reagents += (gen_amount)
	if(reagents > max_fuel)
		reagents = max_fuel
/obj/item/weapon/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'items.dmi'
	icon_state = "cutters"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	m_amt = 80
	origin_tech = "materials=1;engineering=1"

/obj/item/weapon/wirecutters/New()
	if(prob(50))
		icon_state = "cutters-y"
		item_state = "cutters_yellow"

/obj/item/weapon/wirecutters/attack(mob/M as mob, mob/user as mob)
	if((M.handcuffed) && (istype(M:handcuffed, /obj/item/weapon/handcuffs/cable)))
		usr.visible_message("\The [usr] cuts \the [M]'s restraints with \the [src]!",\
		"You cut \the [M]'s restraints with \the [src]!",\
		"You hear cable being cut.")
		M.handcuffed = null
		M.update_inv_handcuffed()
		return
	else
		..()