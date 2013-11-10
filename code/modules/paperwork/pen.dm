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
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
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


/obj/item/weapon/pen/attack(mob/M, mob/user)
	if(!ismob(M))
		return

	user << "<span class='warning'>You stab [M] with the pen.</span>"
	M << "\red You feel a tiny prick!"

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to stab [M.name] ([M.ckey])</font>")
	log_attack("<font color='red'>[user.name] ([user.ckey]) Used the [name] to stab [M.name] ([M.ckey])</font>")


/*
 * Sleepy Pens
 */
/obj/item/weapon/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepypen/New()
	create_reagents(30)
	reagents.add_reagent("chloralhydrate", 22)	//Used to be 100 sleep toxin	//30 Chloral seems to be fatal, reducing it to 22.
	..()


/obj/item/weapon/pen/sleepypen/attack(mob/M, mob/user)
	if(!istype(M))	return

	..()
	if(reagents.total_volume)
		if(M.reagents)
			reagents.trans_to(M, 30) //used to be 150


/*
 * Parapens
 */
 /obj/item/weapon/pen/paralysis
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/paralysis/attack(mob/M, mob/user)
	if(!istype(M))	return

	..()
	if(reagents.total_volume)
		if(M.reagents)
			reagents.trans_to(M, 50)


/obj/item/weapon/pen/paralysis/New()
	create_reagents(50)
	reagents.add_reagent("zombiepowder", 10)
	reagents.add_reagent("impedrezene", 25)
	reagents.add_reagent("cryptobiolin", 15)
	..()