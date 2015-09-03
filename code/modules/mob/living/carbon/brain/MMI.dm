//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"
	var/braintype = "Cyborg"

	var/syndiemmi = 0 //Whether or not this is a Syndicate MMI
	var/mob/living/carbon/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/internal/brain/brain = null //The actual brain

/obj/item/device/mmi/update_icon()
	if(brain)
		if(istype(brain,/obj/item/organ/internal/brain/alien))
			icon_state = "mmi_alien"
			braintype = "Xenoborg" //HISS....Beep.
		else
			icon_state = "mmi_full"
			braintype = "Cyborg"
	else
		icon_state = "mmi_empty"

/obj/item/device/mmi/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O,/obj/item/organ/internal/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/internal/brain/newbrain = O
		if(brain)
			user << "<span class='warning'>There's already a brain in the MMI!</span>"
			return
		if(!newbrain.brainmob)
			user << "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain!</span>"
			return

		if(!user.unEquip(O))
			return
		var/mob/living/carbon/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Someone has put your brain in a MMI!")
		visible_message("[user] sticks \a [newbrain] into \the [src].")

		brainmob = newbrain.brainmob
		newbrain.brainmob = null
		brainmob.loc = src
		brainmob.container = src
		brainmob.stat = 0
		dead_mob_list -= brainmob //Update dem lists
		living_mob_list += brainmob

		newbrain.loc = src //P-put your brain in it
		brain = newbrain

		name = "Man-Machine Interface: [brainmob.real_name]"
		update_icon()

		feedback_inc("cyborg_mmis_filled",1)

		return

	if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
		return
	..()

/obj/item/device/mmi/attack_self(mob/user)
	if(!brain)
		user << "<span class='warning'>You upend the MMI, but there's nothing in it!</span>"
	else
		user << "<span class='notice'>You unlock and upend the MMI, spilling the brain onto the floor.</span>"

		brainmob.container = null //Reset brainmob mmi var.
		brainmob.loc = brain //Throw mob into brain.
		living_mob_list -= brainmob //Get outta here
		brain.brainmob = brainmob //Set the brain to use the brainmob
		brainmob = null //Set mmi brainmob var to null

		brain.loc = usr.loc
		brain = null //No more brain in here

		update_icon()
		name = "Man-Machine Interface"

/obj/item/device/mmi/proc/transfer_identity(mob/living/carbon/human/H) //Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	if(check_dna_integrity(H))
		brainmob.dna = H.dna
	brainmob.container = src

	if(istype(H))
		var/obj/item/organ/internal/brain/newbrain = H.getorgan(/obj/item/organ/internal/brain)
		newbrain.loc = src
		brain = newbrain

	name = "Man-Machine Interface: [brainmob.real_name]"
	update_icon()
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
		brainmob << "<span class='warning'>Can't do that while incapacitated or dead!</span>"

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
	return ..()

/obj/item/device/mmi/examine(mob/user)
	..()
	if(brainmob)
		var/mob/living/carbon/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			user << "<span class='warning'>The MMI indicates the brain is completely unresponsive.</span>"

		else if(!B.client)
			user << "<span class='warning'>The MMI indicates the brain is currently inactive; it might change.</span>"

		else
			user << "<span class='notice'>The MMI indicates the brain is active.</span>"


/obj/item/device/mmi/syndie
	name = "Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs created with it, but doesn't fit in Nanotrasen AI cores."
	syndiemmi = 1