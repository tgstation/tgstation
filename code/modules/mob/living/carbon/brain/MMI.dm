//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"
	var/braintype = "Cyborg"

	req_access = list(access_robotics)

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.

	var/locked = 0
	var/mob/living/carbon/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain

/obj/item/device/mmi/update_icon()
	if(brain)
		if(istype(brain,/obj/item/organ/brain/alien))
			icon_state = "mmi_alien"
			braintype = "Xenoborg" //HISS....Beep.
		else
			icon_state = "mmi_full"
			braintype = "Cyborg"
	else
		icon_state = "mmi_empty"

/obj/item/device/mmi/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O,/obj/item/organ/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/brain/newbrain = O
		if(brain)
			user << "<span class='danger'>There's already a brain in the MMI!</span>"
			return
		if(!newbrain.brainmob)
			user << "<span class='danger'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain.</span>"
			return
		visible_message("<span class='notice'>[user] sticks \a [newbrain] into \the [src]</span>")

		brainmob = newbrain.brainmob
		newbrain.brainmob = null
		brainmob.loc = src
		brainmob.container = src
		brainmob.stat = 0
		dead_mob_list -= brainmob //Update dem lists
		living_mob_list += brainmob

		user.drop_item()
		newbrain.loc = src //P-put your brain in it
		brain = newbrain

		name = "Man-Machine Interface: [brainmob.real_name]"
		update_icon()

		locked = 1

		feedback_inc("cyborg_mmis_filled",1)

		return

	if((istype(O,/obj/item/weapon/card/id)||istype(O,/obj/item/device/pda)) && brainmob)
		if(allowed(user))
			locked = !locked
			user << "<span class='notice'>You [locked ? "lock" : "unlock"] the brain holder.</span>"
		else
			user << "<span class='danger'>Access denied.</span>"
		return
	if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
		return
	..()

/obj/item/device/mmi/attack_self(mob/user as mob)
	if(!brain)
		user << "<span class='danger'>You upend the MMI, but there's nothing in it.</span>"
	else if(locked)
		user << "<span class='danger'>You upend the MMI, but the brain is clamped into place.</span>"
	else
		user << "<span class='notice'>You upend the MMI, spilling the brain onto the floor.</span>"

		brainmob.container = null //Reset brainmob mmi var.
		brainmob.loc = brain //Throw mob into brain.
		living_mob_list -= brainmob //Get outta here
		brain.brainmob = brainmob //Set the brain to use the brainmob
		brainmob = null //Set mmi brainmob var to null

		brain.loc = usr.loc
		brain = null //No more brain in here

		update_icon()
		name = "Man-Machine Interface"

/obj/item/device/mmi/proc/transfer_identity(var/mob/living/carbon/human/H) //Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	if(check_dna_integrity(H))
		brainmob.dna = H.dna
	brainmob.container = src

	if(istype(H))
		var/obj/item/organ/brain/newbrain = H.getorgan(/obj/item/organ/brain)
		newbrain.loc = src
		brain = newbrain

	name = "Man-Machine Interface: [brainmob.real_name]"
	update_icon()
	locked = 1
	return

/obj/item/device/mmi/radio_enabled
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations. This one comes with a built-in radio."
	origin_tech = "biotech=4"

	var/obj/item/device/radio/radio = null //Let's give it a radio.

/obj/item/device/mmi/radio_enabled/New()
	..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.broadcasting = 0 //researching radio mmis turned the robofabs into radios because this didnt start as 0.

/obj/item/device/mmi/radio_enabled/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = 0

	if(brainmob.stat)
		brainmob << "Can't do that while incapacitated or dead."

	radio.listening = radio.listening==1 ? 0 : 1
	brainmob << "<span class='notice'>Radio is [radio.listening==1 ? "now" : "no longer"] receiving broadcast.</span>"

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

/obj/item/device/mmi/Destroy()
	if(isrobot(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	..()
