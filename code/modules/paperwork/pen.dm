/*	Pens!
 *	Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */


/*
 * Pens
 */
/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	m_amt = 10
	pressure_resistance = 2
	var/colour = "black"	//what colour the ink is!


/obj/item/weapon/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/weapon/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/weapon/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"


/obj/item/weapon/pen/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(M.can_inject(user, 1))
		user << "<span class='warning'>You stab [M] with the pen.</span>"
		M << "<span class='danger'>You feel a tiny prick!</span>"
		. = 1

	add_logs(user, M, "stabbed", object="[name]")

/*
 * Sleepypens
 */
/obj/item/weapon/pen/sleepy
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))	return

	if(..())
		if(reagents.total_volume)
			if(M.reagents)
				reagents.trans_to(M, 55)


/obj/item/weapon/pen/sleepy/New()
	create_reagents(55)
	reagents.add_reagent("morphine", 30)
	reagents.add_reagent("mutetoxin", 15)
	reagents.add_reagent("tirizene", 10)
	..()

/*
 * Gang Boss Pens
 */
/obj/item/weapon/pen/gang
	origin_tech = "materials=2;syndicate=5"
	var/cooldown

/obj/item/weapon/pen/gang/attack(mob/living/M, mob/user)
	if(!istype(M))	return
	if(..())
		if(ishuman(M) && ishuman(user) && M.stat != DEAD)
			if(user.mind && ((user.mind in ticker.mode.A_bosses) || (user.mind in ticker.mode.B_bosses)))
				if(cooldown)
					user << "<span class='warning'>[src] needs more time to recharge before it can be used.</span>"
					return
				if(M.client)
					M.mind_initialize()		//give them a mind datum if they don't have one.
					if(user.mind in ticker.mode.A_bosses)
						if(ticker.mode.add_gangster(M.mind,"A"))
							M.Paralyse(5)
							cooldown(ticker.mode.A_gang.len, )
						else
							user << "<span class='warning'>This mind is resistant to recruitment!</span>"
					else if(user.mind in ticker.mode.B_bosses)
						if(ticker.mode.add_gangster(M.mind,"B"))
							M.Paralyse(5)
							cooldown(ticker.mode.B_gang.len)
						else
							user << "<span class='warning'>This mind is resistant to recruitment!</span>"
				else
					user << "<span class='warning'>This mind is so vacant that it is not susceptible to influence!</span>"

/obj/item/weapon/pen/gang/proc/cooldown(modifier)
	if(!modifier)
		return
	cooldown = 1
	icon_state = "pen_blink"
	//The more gang members there are the longer the cooldown will be
	var/time = 500 + (100 * modifier) //50 seconds + 10 seconds for every member in the gang
	spawn(time)
		cooldown = 0
		icon_state = "pen"
		var/mob/M = get(src, /mob)
		M << "<span class='notice'>\icon[src] [src][(src.loc == M)?(""):(" in your [src.loc]")] vibrates softly.</span>"
