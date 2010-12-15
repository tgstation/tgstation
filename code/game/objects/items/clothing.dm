/*
CONTAINS:
ORANGE SHOES
MUZZLE
CAKEHAT
SUNGLASSES
CIGARETTE
SWAT SUIT
CHAMELEON JUMPSUIT
DEATH COMMANDO GAS MASK

*/


/*
/obj/item/clothing/fire_burn(obj/fire/raging_fire, datum/air_group/environment)
	if(raging_fire.internal_temperature > src.s_fire)
		spawn( 0 )
			var/t = src.icon_state
			src.icon_state = ""
			src.icon = 'b_items.dmi'
			flick(text("[]", t), src)
			spawn(14)
				del(src)
				return
			return
		return 0
	return 1
*/ //TODO FIX

/obj/item/clothing/gloves/examine()
	set src in usr
	..()
	return

/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/weapon/handcuffs( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/orange/attackby(H as obj, loc)
	if ((istype(H, /obj/item/weapon/handcuffs) && !( src.chained )))
		//H = null
		del(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "orange1"
	return

/obj/item/clothing/mask/muzzle/attack_paw(mob/user as mob)
	if (src == user.wear_mask)
		return
	else
		..()
	return

/obj/item/clothing/head/cakehat/var/processing = 0

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_items.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)


/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 15
		src.damtype = "fire"
		src.icon_state = "cake1"

		processing_items.Add(src)

	else
		src.force = 3
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/obj/item/clothing/mask/cigarette/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool)  && W:welding)
		if(src.lit == 0)
			src.lit = 1
			src.damtype = "fire"
			src.icon_state = "cigon"
			src.item_state = "cigon"
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] casually lights the cigarette with [], what a badass.", user, W), 1)
			spawn() //start fires while it's lit
				src.process()
	else if(istype(W, /obj/item/weapon/zippo) && W:lit)
		if(src.lit == 0)
			src.lit = 1
			src.icon_state = "cigon"
			src.item_state = "cigon"
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red With a single flick of his wrist, [] smoothly lights his cigarette with his []. Damn they're cool.", user, W), 1)
			spawn() //start fires while it's lit
				src.process()



/obj/item/clothing/mask/cigarette/process()

	var/atom/lastHolder = null

	while(src.lit == 1)
		var/turf/location = src.loc
		var/atom/holder = loc
		var/isHeld = 0
		var/mob/M = null
		src.smoketime--

		if(istype(location, /mob/))
			M = location
			if(M.l_hand == src || M.r_hand == src || M.wear_mask == src)
				location = M.loc
		if(src.smoketime < 1)
			var/obj/item/weapon/cigbutt/C = new /obj/item/weapon/cigbutt
			if(M != null)
				M << "\red Your cigarette goes out."
			C.loc = location
			del(src)
			return
		if (istype(location, /turf)) //start a fire if possible
			location.hotspot_expose(700, 5)
		if (ismob(holder))
			isHeld = 1
		else




			// note remove luminosity processing until can understand how to make this compatible
			// with the fire checks, etc.

			isHeld = 0
			if (lastHolder != null)
				//lastHolder.sd_SetLuminosity(0)
				lastHolder = null

		if (isHeld == 1)
			//if (holder != lastHolder && lastHolder != null)
				//lastHolder.sd_SetLuminosity(0)
			//holder.sd_SetLuminosity(1)
			lastHolder = holder

		//sd_SetLuminosity(1)
		sleep(10)

	if (lastHolder != null)
		//lastHolder.sd_SetLuminosity(0)
		lastHolder = null

	//sd_SetLuminosity(0)


/obj/item/clothing/mask/cigarette/dropped(mob/user as mob)
	if(src.lit == 1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] calmly drops and treads on the lit cigarette, putting it out instantly.", user), 1)
		src.lit = -1
		src.damtype = "brute"
		src.icon_state = "cigbutt"
		src.item_state = "cigoff"
		src.name = "Cigarette butt"
		src.desc = "A cigarette butt."
		return ..()
	else
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] drops the []. Guess they've had enough for the day.", user, src), 1)
		return ..()




/obj/item/clothing/under/chameleon/New()
	..()

	for(var/U in typesof(/obj/item/clothing/under/color)-(/obj/item/clothing/under/color))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	for(var/U in typesof(/obj/item/clothing/under/rank)-(/obj/item/clothing/under/rank))

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

	src.clothing_choices += new /obj/item/clothing/under/bartender
	src.clothing_choices += new /obj/item/clothing/under/cargo
	src.clothing_choices += new /obj/item/clothing/under/chef
	src.clothing_choices += new /obj/item/clothing/under/clown
	src.clothing_choices += new /obj/item/clothing/under/det
	src.clothing_choices += new /obj/item/clothing/under/librarian

	return


/obj/item/clothing/under/chameleon/all/New()
	..()

	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all)
	//to prevent an infinite loop

	for(var/U in typesof(/obj/item/clothing/under)-blocked)

		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V



/obj/item/clothing/under/chameleon/attackby(obj/item/clothing/under/U as obj, mob/user as mob)

	if(istype(U, /obj/item/clothing/under/chameleon))
		user << "\red Nothing happens."
		return

	if(istype(U, /obj/item/clothing/under))

		if(src.clothing_choices.Find(U))
			user << "\red Pattern is already recognised by the suit."
			return

		src.clothing_choices += U

		user << "\red Pattern absorbed by the suit."

/obj/item/clothing/under/chameleon/verb/change()
	set name = "Change"
	set src in usr

	if(icon_state == "psyche")
		usr << "\red Your suit is malfunctioning"
		return

	var/obj/item/clothing/under/A

	A = input("Select Colour to change it to", "BOOYEA", A) in clothing_choices

	if(!A)
		return

	desc = null
	permeability_coefficient = 0.90

	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	color = A.color

/obj/item/clothing/suit/swat_suit/death_commando
	name = "Death Commando Suit"
	icon_state = "death_commando_suit"
	item_state = "death_commando_suit"
	flags = FPRINT | TABLEPASS | SUITSPACE

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"



/obj/item/clothing/under/var/mode = 1 // 0 - Off, 1 - Binary Lifesigns, 2 - Vitals, 3 - Positioning and Vitals

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	if (istype (src, /obj/item/clothing/under/color/orange/))
		mode = 3
		usr << "There are no controls for the sensing equipment woven into the fabric."
		return
	mode += 1
	if(mode > 3)
		mode = 0
	switch(mode)
		if(0)
			usr << "You disable your suit's remote sensing equipment."
		if(1)
			usr << "You enable your suit's remote sensing equipment. It will now report whether you are live or dead."
		if(2)
			usr << "You enable more complicated sensors in your suit. It will now report your vital lifesigns."
		if(3)
			usr << "You activate the full suite of sensors in your suit. It will now report your vital lifesigns as well as your coordinate position."
	..()

/obj/item/clothing/under/examine()
	..()
	switch(mode)
		if(0)
			usr << "Its sensors appear to be disabled."
		if(1)
			usr << "Its binary life sensors appear to be enabled."
		if(2)
			usr << "Its vital tracker appears to be enabled."
		if(3)
			usr << "Its vital tracker and tracking beacon appear to be enabled."


/obj/item/clothing/under/color/orange/mode = 3

/obj/item/clothing/shoes/magboots/attack_self(mob/user as mob)
	if(src.flags&NOSLIP)
		src.flags &= ~NOSLIP
		src.slowdown = SHOES_SLOWDOWN
		icon_state = "magboots0"
		user << "You disable the mag-pulse traction system."
	else
		src.flags |= NOSLIP
		src.slowdown = 2
		icon_state = "magboots1"
		user << "You enable the mag-pulse traction system."

/obj/item/clothing/shoes/magboots/examine()
	..()
	var/state = "disabled"
	if(src.flags&NOSLIP)
		state = "enabled"
	usr << "Its mag-pulse traction system appears to be [state]."

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		user << "You raise the ear flaps on the ushanka."
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		user << "You lower the ear flaps on the ushanka."