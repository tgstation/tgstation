//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"

	var/list/construction_cost = list("metal"=1000,"glass"=500)
	var/construction_time = 75
	//these vars are so the mecha fabricator doesn't shit itself anymore. --NEO

	req_access = list(access_robotics)

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.

	var/locked = 0
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/mob/living/silicon/robot = null//Appears unused.
	var/obj/mecha = null//This does not appear to be used outside of reference in mecha.dm.

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O,/obj/item/brain) && !brainmob) //Time to stick a brain in it --NEO
			if(!O:brainmob)
				user << "\red You aren't sure where this brain came from, but you're pretty sure it's a useless brain."
				return
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] sticks \a [O] into \the [src]."))

			brainmob = O:brainmob
			O:brainmob = null
			brainmob.loc = src
			brainmob.container = src
			brainmob.stat = 0
			dead_mob_list -= brainmob//Update dem lists
			living_mob_list += brainmob

			user.drop_item()
			del(O)

			name = "Man-Machine Interface: [brainmob.real_name]"
			icon_state = "mmi_full"

			locked = 1

			feedback_inc("cyborg_mmis_filled",1)

			return

		if((istype(O,/obj/item/weapon/card/id)||istype(O,/obj/item/device/pda)) && brainmob)
			if(allowed(user))
				locked = !locked
				user << "\blue You [locked ? "lock" : "unlock"] the brain holder."
			else
				user << "\red Access denied."
			return
		if(brainmob)
			O.attack(brainmob, user)//Oh noooeeeee
			return
		..()

	attack_self(mob/user as mob)
		if(!brainmob)
			user << "\red You upend the MMI, but there's nothing in it."
		else if(locked)
			user << "\red You upend the MMI, but the brain is clamped into place."
		else
			user << "\blue You upend the MMI, spilling the brain onto the floor."
			var/obj/item/brain/brain = new(user.loc)
			brainmob.container = null//Reset brainmob mmi var.
			brainmob.loc = brain//Throw mob into brain.
			living_mob_list -= brainmob//Get outta here
			brain.brainmob = brainmob//Set the brain to use the brainmob
			brainmob = null//Set mmi brainmob var to null

			icon_state = "mmi_empty"
			name = "Man-Machine Interface"

	proc
		transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
			brainmob = new(src)
			brainmob.name = H.real_name
			brainmob.real_name = H.real_name
			brainmob.dna = H.dna
			brainmob.container = src

			name = "Man-Machine Interface: [brainmob.real_name]"
			icon_state = "mmi_full"
			locked = 1
			return

/obj/item/device/mmi/radio_enabled
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	origin_tech = "biotech=4"

	var/obj/item/device/radio/radio = null//Let's give it a radio.

	New()
		..()
		radio = new(src)//Spawns a radio inside the MMI.
		radio.broadcasting = 1//So it's broadcasting from the start.

	verb//Allows the brain to toggle the radio functions.
		Toggle_Broadcasting()
			set name = "Toggle Broadcasting"
			set desc = "Toggle broadcasting channel on or off."
			set category = "MMI"
			set src = usr.loc//In user location, or in MMI in this case.
			set popup_menu = 0//Will not appear when right clicking.

			if(brainmob.stat)//Only the brainmob will trigger these so no further check is necessary.
				brainmob << "Can't do that while incapacitated or dead."

			radio.broadcasting = radio.broadcasting==1 ? 0 : 1
			brainmob << "\blue Radio is [radio.broadcasting==1 ? "now" : "no longer"] broadcasting."

		Toggle_Listening()
			set name = "Toggle Listening"
			set desc = "Toggle listening channel on or off."
			set category = "MMI"
			set src = usr.loc
			set popup_menu = 0

			if(brainmob.stat)
				brainmob << "Can't do that while incapacitated or dead."

			radio.listening = radio.listening==1 ? 0 : 1
			brainmob << "\blue Radio is [radio.listening==1 ? "now" : "no longer"] receiving broadcast."

/obj/item/device/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()