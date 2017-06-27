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
	var/traitor_unlock_degrees = 0
	var/degrees = 0
	var/font = PEN_FONT

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
	to_chat(user, "<span class='notice'>\The [src] will now write in [colour].</span>")
	desc = "It's a fancy four-color ink pen, set to [colour]."

/obj/item/weapon/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT

/obj/item/weapon/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
	materials = list(MAT_GOLD = 750)
	sharpness = IS_SHARP
	resistance_flags = FIRE_PROOF
	unique_reskin = list("Oak" = "pen-fountain-o",
						"Gold" = "pen-fountain-g",
						"Rosewood" = "pen-fountain-r",
						"Black and Silver" = "pen-fountain-b",
						"Command Blue" = "pen-fountain-cb"
						)

/obj/item/weapon/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = "It's an expensive [current_skin] fountain pen. The nib is quite sharp."

/obj/item/weapon/pen/attack_self(mob/living/carbon/user)
	var/deg = input(user, "What angle would you like to rotate the pen head to? (1-360)", "Rotate Pen Head") as null|num
	if(deg && (deg > 0 && deg <= 360))
		degrees = deg
		to_chat(user, "<span class='notice'>You rotate the top of the pen to [degrees] degrees.</span>")
		if(hidden_uplink && degrees == traitor_unlock_degrees)
			to_chat(user, "<span class='warning'>Your pen makes a clicking noise, before quickly rotating back to 0 degrees!</span>")
			degrees = 0
			hidden_uplink.interact(user)


/obj/item/weapon/pen/attackby(obj/item/I, mob/user, params)
	if(hidden_uplink)
		return hidden_uplink.attackby(I, user, params)
	else
		return ..()


/obj/item/weapon/pen/attack(mob/living/M, mob/user,stealth)
	if(!istype(M))
		return

	if(!force)
		if(M.can_inject(user, 1))
			to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
			if(!stealth)
				to_chat(M, "<span class='danger'>You feel a tiny prick!</span>")
			. = 1

		add_logs(user, M, "stabbed", src)

	else
		. = ..()

/obj/item/weapon/pen/afterattack(obj/O, mob/living/user, proximity)
	//Changing Name/Description of items. Only works if they have the 'unique_rename' var set
	if(isobj(O) && proximity)
		if(O.unique_rename)
			var/penchoice = input(user, "What would you like to edit?", "Rename or change description?") as null|anything in list("Rename","Change description")
			if(!QDELETED(O) && user.canUseTopic(O, be_close = TRUE))

				if(penchoice == "Rename")
					var/input = stripped_input(user,"What do you want to name \the [O.name]?", ,"", MAX_NAME_LEN)
					var/oldname = O.name
					if(!QDELETED(O) && user.canUseTopic(O, be_close = TRUE))
						if(oldname == input)
							to_chat(user, "You changed \the [O.name] to... well... \the [O.name].")
							return
						else
							O.name = input
							to_chat(user, "\The [oldname] has been successfully been renamed to \the [input].")
							return
					else
						to_chat(user, "You are too far away!")

				if(penchoice == "Change description")
					var/input = stripped_input(user,"Describe \the [O.name] here", ,"", 100)
					if(!QDELETED(O) && user.canUseTopic(O, be_close = TRUE))
						O.desc = input
						to_chat(user, "You have successfully changed \the [O.name]'s description.")
						return
					else
						to_chat(user, "You are too far away!")
			else
				to_chat(user, "You are too far away!")
				return
	else
		return

/*
 * Sleepypens
 */
/obj/item/weapon/pen/sleepy
	origin_tech = "engineering=4;syndicate=2"
	container_type = OPENCONTAINER


/obj/item/weapon/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(..())
		if(reagents.total_volume)
			if(M.reagents)
				reagents.trans_to(M, reagents.total_volume)


/obj/item/weapon/pen/sleepy/New()
	create_reagents(45)
	reagents.add_reagent("chloralhydrate2", 20)
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
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
	else
		on = 1
		force = 18
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		hitsound = 'sound/weapons/blade1.ogg'
		embed_chance = 100 //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 5, 1)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
	update_icon()

/obj/item/weapon/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)
