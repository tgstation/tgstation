/*	Pens!
 *	Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 *		Edaggers
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
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=10)
	pressure_resistance = 2
	var/colour = "black"	//what colour the ink is!

/obj/item/weapon/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
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

/obj/item/weapon/pen/fourcolor
	desc = "It's a fancy four-color ink pen, set to black."
	name = "four-color pen"
	colour = "black"

/obj/item/weapon/pen/fourcolor/attack_self(mob/living/carbon/user)
	switch(colour)
		if("black")
			colour = "red"
		if("red")
			colour = "green"
		if("green")
			colour = "blue"
		else
			colour = "black"
	user << "<span class='notice'>\The [src] will now write in [colour].</span>"
	desc = "It's a fancy four-color ink pen, set to [colour]."

/obj/item/weapon/pen/attack(mob/living/M, mob/user,stealth)
	if(!istype(M))
		return

	if(!force)
		if(M.can_inject(user, 1))
			user << "<span class='warning'>You stab [M] with the pen.</span>"
			if(!stealth)
				M << "<span class='danger'>You feel a tiny prick!</span>"
			. = 1

		add_logs(user, M, "stabbed", src)

	else
		. = ..()

/*
 * Sleepypens
 */
/obj/item/weapon/pen/sleepy
	origin_tech = "engineering=4;syndicate=2"
	flags = OPENCONTAINER


/obj/item/weapon/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

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

/*
 * (Alan) Edaggers
 */
/obj/item/weapon/pen/edagger
	origin_tech = "combat=3;syndicate=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") //these wont show up if the pen is off
	var/on = 0

/obj/item/weapon/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = 0
		force = initial(force)
		w_class = initial(w_class)
		name = initial(name)
		hitsound = initial(hitsound)
		embed_chance = initial(embed_chance)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 5, 1)
		user << "<span class='warning'>[src] can now be concealed.</span>"
	else
		on = 1
		force = 18
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		hitsound = 'sound/weapons/blade1.ogg'
		embed_chance = 100 //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 5, 1)
		user << "<span class='warning'>[src] is now active.</span>"
	update_icon()

/obj/item/weapon/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)
