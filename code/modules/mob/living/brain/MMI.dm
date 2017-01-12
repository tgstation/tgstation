

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=2;programming=3;engineering=2"
	var/braintype = "Cyborg"
	var/obj/item/device/radio/radio = null //Let's give it a radio.
	var/mob/living/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain
	var/datum/ai_laws/laws = new()
	var/force_replace_ai_name = FALSE

/obj/item/device/mmi/update_icon()
	if(brain)
		if(istype(brain,/obj/item/organ/brain/alien))
			if(brainmob && brainmob.stat == DEAD)
				icon_state = "mmi_alien_dead"
			else
				icon_state = "mmi_alien"
			braintype = "Xenoborg" //HISS....Beep.
		else
			if(brainmob && brainmob.stat == DEAD)
				icon_state = "mmi_dead"
			else
				icon_state = "mmi_full"
			braintype = "Cyborg"
	else
		icon_state = "mmi_empty"

/obj/item/device/mmi/New()
	..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.broadcasting = 0 //researching radio mmis turned the robofabs into radios because this didnt start as 0.
	if(config)
		laws.set_laws_config()

/obj/item/device/mmi/initialize()
	..()
	laws.set_laws_config()

/obj/item/device/mmi/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O,/obj/item/organ/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/brain/newbrain = O
		if(brain)
			user << "<span class='warning'>There's already a brain in the MMI!</span>"
			return
		if(!newbrain.brainmob)
			user << "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain!</span>"
			return

		if(!user.unEquip(O))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Someone has put your brain in a MMI!", source = src)
		visible_message("[user] sticks \a [newbrain] into \the [src].")

		brainmob = newbrain.brainmob
		newbrain.brainmob = null
		brainmob.loc = src
		brainmob.container = src
		if(!newbrain.damaged_brain) // the brain organ hasn't been beaten to death.
			brainmob.stat = CONSCIOUS //we manually revive the brain mob
			dead_mob_list -= brainmob
			living_mob_list += brainmob

		brainmob.reset_perspective()
		newbrain.loc = src //P-put your brain in it
		brain = newbrain

		name = "Man-Machine Interface: [brainmob.real_name]"
		update_icon()

		feedback_inc("cyborg_mmis_filled",1)

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()


/obj/item/device/mmi/attack_self(mob/user)
	if(!brain)
		radio.on = !radio.on
		user << "<span class='notice'>You toggle the MMI's radio system [radio.on==1 ? "on" : "off"].</span>"
	else
		user << "<span class='notice'>You unlock and upend the MMI, spilling the brain onto the floor.</span>"
		eject_brain(user)
		update_icon()
		name = "Man-Machine Interface"

/obj/item/device/mmi/proc/eject_brain(mob/user)
	brainmob.container = null //Reset brainmob mmi var.
	brainmob.loc = brain //Throw mob into brain.
	brainmob.stat = DEAD
	brainmob.emp_damage = 0
	brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
	living_mob_list -= brainmob //Get outta here
	dead_mob_list += brainmob
	brain.brainmob = brainmob //Set the brain to use the brainmob
	brainmob = null //Set mmi brainmob var to null
	if(user)
		user.put_in_hands(brain) //puts brain in the user's hand or otherwise drops it on the user's turf
	else
		brain.forceMove(get_turf(src))
	brain = null //No more brain in here


/obj/item/device/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.container = src

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/brain/newbrain = H.getorgan(/obj/item/organ/brain)
		newbrain.loc = src
		brain = newbrain
	else if(!brain)
		brain = new(src)
		brain.name = "[L.real_name]'s brain"

	name = "Man-Machine Interface: [brainmob.real_name]"
	update_icon()
	return

/obj/item/device/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/device/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = 0

	if(brainmob.stat)
		brainmob << "<span class='warning'>Can't do that while incapacitated or dead!</span>"
	if(!radio.on)
		brainmob << "<span class='warning'>Your radio is disabled!</span>"
		return

	radio.listening = radio.listening==1 ? 0 : 1
	brainmob << "<span class='notice'>Radio is [radio.listening==1 ? "now" : "no longer"] receiving broadcast.</span>"

/obj/item/device/mmi/emp_act(severity)
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")
	..()

/obj/item/device/mmi/Destroy()
	if(iscyborg(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	if(brain)
		qdel(brain)
		brain = null
	if(mecha)
		mecha = null
	if(radio)
		qdel(radio)
		radio = null
	return ..()

/obj/item/device/mmi/deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()
	qdel(src)

/obj/item/device/mmi/examine(mob/user)
	..()
	if(brainmob)
		var/mob/living/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			user << "<span class='warning'>The MMI indicates the brain is completely unresponsive.</span>"

		else if(!B.client)
			user << "<span class='warning'>The MMI indicates the brain is currently inactive; it might change.</span>"

		else
			user << "<span class='notice'>The MMI indicates the brain is active.</span>"


/obj/item/device/mmi/syndie
	name = "Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs and AIs created with it."
	origin_tech = "biotech=4;programming=4;syndicate=2"

/obj/item/device/mmi/syndie/New()
	..()
	laws = new /datum/ai_laws/syndicate_override()
	radio.on = 0
