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
	materials = list(MAT_METAL=10)
	pressure_resistance = 2
	var/colour = "black"	//what colour the ink is!

/obj/item/weapon/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scribbling numbers all over themself with [src]! It looks like they're trying to commit sudoku!</span>")
	return(BRUTELOSS)

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


/obj/item/weapon/pen/attack(mob/living/M, mob/user,var/stealth)
	if(!istype(M))
		return

	if(M.can_inject(user, 1))
		user << "<span class='warning'>You stab [M] with the pen.</span>"
		if(!stealth)
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
				reagents.trans_to(M, reagents.total_volume)


/obj/item/weapon/pen/sleepy/New()
	create_reagents(45)
	reagents.add_reagent("morphine", 20)
	reagents.add_reagent("mutetoxin", 15)
	reagents.add_reagent("tirizene", 10)
	..()
