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
	icon_state = pick("screwdriver","screwdriver2","screwdriver3","screwdriver4","screwdriver5","screwdriver6","screwdriver7")
	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))	return ..()
	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()
	if((user.mutations & CLUMSY) && prob(50))
		M = user
	return eyestab(M,user)



// WELDING TOOL
/obj/item/weapon/weldingtool
	name = "Welding Tool"
	icon = 'items.dmi'
	icon_state = "welder"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	m_amt = 70
	g_amt = 30
	origin_tech = "engineering=1"
	var/welding = 0
	var/status = 1
	var/max_fuel = 20
	proc
		get_fuel()
		remove_fuel(var/amount = 1, var/mob/M = null)
		check_status()
		toggle(var/message = 0)
		eyecheck(mob/user as mob)


	New()
		var/random_fuel = min(rand(10,20),max_fuel)
		var/datum/reagents/R = new/datum/reagents(max_fuel)
		reagents = R
		R.my_atom = src
		R.add_reagent("fuel", random_fuel)
		return


	examine()
		set src in usr
		usr << text("\icon[] [] contains []/[] units of fuel!", src, src.name, get_fuel(),src.max_fuel )
		return


	attackby(obj/item/W as obj, mob/user as mob)
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


	process()
		switch(welding)
			if(0)
				processing_objects.Remove(src)
				return
			if(1)
				if(prob(5))//Welders left on now use up fuel, but lets not have them run out quite that fast
					remove_fuel(1)
			if(2)
				if(prob(75))
					remove_fuel(1)
					//if you're actually actively welding, use fuel faster.

		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = get_turf(M)
		if (istype(location, /turf))
			location.hotspot_expose(700, 5)


	afterattack(obj/O as obj, mob/user as mob)
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


	attack_self(mob/user as mob)
		toggle()
		user.update_clothing()
		return


///GET prop for fuel
	get_fuel()
		return reagents.get_reagent_amount("fuel")


///SET prop for fuel
///Will also turn it off if it is out of fuel
///The mob argument is not needed but if included will call eyecheck() on it if the welder is on.
	remove_fuel(var/amount = 1, var/mob/M = null)
		if(!welding || !check_status())
			return 0
		if(get_fuel() >= amount)
			reagents.remove_reagent("fuel", amount)
			check_status()
			if(M)
				eyecheck(M)//TODO:eyecheck should really be in mob not here
			return 1
		else
			if(M)
				M << "\blue You need more welding fuel to complete this task."
			return 0


///Quick check to see if we even have any fuel and should shut off
///This could use a better name
	check_status()
		if((get_fuel() <= 0) && welding)
			toggle(1)
			return 0
		return 1


//toggles the welder off and on
	toggle(var/message = 0)
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


	eyecheck(mob/user as mob)
		//check eye protection
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
			user.disabilities |= 128
		else if (prob(user.eye_stat - 15 + 1))
			user << "\red You go blind!"
			user.eye_blind = 5
			user.eye_blurry = 5
			user.disabilities |= 1
//			spawn(100)
//				user.disabilities &= ~1 //Simpler to just leave them short sighted.
		return

	attack(mob/M as mob, mob/user as mob)
		if(hasorgans(M))
			var/datum/organ/external/S = M:organs[user.zone_sel.selecting]
			if(S)
				message_admins("It appears [M] has \"null\" where there should be a [user.zone_sel.selecting].  Check into this, and tell SkyMarshal: \"[M.type]\"")
				return ..()
			if(!S.robot || user.a_intent != "help")
				return ..()
			if(S.brute_dam)
				S.heal_damage(15,0,0,1)
				if(user != M)
					user.visible_message("\red You patch some dents on \the [M]'s [S.display_name]",\
					"\red \The [user] patches some dents on \the [M]'s [S.display_name] with \the [src]",\
					"You hear a welder.")
				else
					user.visible_message("\red You patch some dents on your [S.display_name]",\
					"\red \The [user] patches some dents on their [S.display_name] with \the [src]",\
					"You hear a welder.")
			else
				user << "Nothing to fix!"
		else
			return ..()


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
	max_fuel = 80
	w_class = 3.0
	m_amt = 70
	g_amt = 120



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

	New()
		if(prob(50))
			icon_state = "cutters-y"

/obj/item/weapon/wirecutters/attack(mob/M as mob, mob/user as mob)
	if((M.handcuffed) && (istype(M:handcuffed, /obj/item/weapon/handcuffs/cable)))
		M.visible_message("You cut \the [M]'s restraints with \the [src]!",\
		"\The [usr] cuts \the [M]'s restraints with \the [src]!",\
		"You hear cable being cut.")
		M.handcuffed = null
		M.update_clothing()
		return
	else
		..()