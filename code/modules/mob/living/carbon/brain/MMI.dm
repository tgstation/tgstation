<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=2;programming=3;engineering=2"
	var/braintype = "Cyborg"
	var/obj/item/device/radio/radio = null //Let's give it a radio.
	var/hacked = 0 //Whether or not this is a Syndicate MMI
	var/mob/living/carbon/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain
	var/clockwork = FALSE //If this is a soul vessel

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
		var/mob/living/carbon/brain/B = newbrain.brainmob
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
		if(clockwork)
			add_servant_of_ratvar(brainmob, TRUE)
		newbrain.loc = src //P-put your brain in it
		brain = newbrain

		name = "Man-Machine Interface: [brainmob.real_name]"
		update_icon()

		feedback_inc("cyborg_mmis_filled",1)

		return

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
		return
	..()

/obj/item/device/mmi/attack_self(mob/user)
	if(!brain)
		radio.on = !radio.on
		user << "<span class='notice'>You toggle the MMI's radio system [radio.on==1 ? "on" : "off"].</span>"
	else
		user << "<span class='notice'>You unlock and upend the MMI, spilling the brain onto the floor.</span>"

		brainmob.container = null //Reset brainmob mmi var.
		brainmob.loc = brain //Throw mob into brain.
		brainmob.stat = DEAD
		brainmob.emp_damage = 0
		brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
		living_mob_list -= brainmob //Get outta here
		dead_mob_list += brainmob
		brain.brainmob = brainmob //Set the brain to use the brainmob
		brainmob = null //Set mmi brainmob var to null

		user.put_in_hands(brain) //puts brain in the user's hand or otherwise drops it on the user's turf
		brain = null //No more brain in here

		update_icon()
		name = "Man-Machine Interface"

/obj/item/device/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.dna)
			brainmob.dna = new /datum/dna(brainmob)
		C.dna.copy_dna(brainmob.dna)
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
	if(!brainmob)
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
	origin_tech = "biotech=4;programming=4;syndicate=2"
	hacked = 1

/obj/item/device/mmi/syndie/New()
	..()
	radio.on = 0
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = W_CLASS_MEDIUM
	origin_tech = "biotech=3"

	var/list/mommi_assembly_parts = list(
		/obj/item/weapon/cell = 1,
		/obj/item/robot_parts/l_leg = 2,
		/obj/item/robot_parts/r_leg = 2,
		/obj/item/robot_parts/r_arm = 1,
		/obj/item/robot_parts/l_arm = 1
	)

	req_access = list(access_robotics)

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.

	var/locked = 0
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/mob/living/silicon/robot = null//Appears unused.
	var/obj/mecha = null//This does not appear to be used outside of reference in mecha.dm.

obj/item/device/mmi/Destroy()
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	..()

	// Return true if handled
/obj/item/device/mmi/proc/try_handling_mommi_construction(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/weapon/screwdriver))
		for(var/t in mommi_assembly_parts)
			var/cc=contents_count(t)
			var/req=mommi_assembly_parts[t]
			if(cc<req)
				var/temppart = new t(src)
				to_chat(user, "<span class='warning'>You're short [req-cc] [temppart]\s.</span>")
				qdel(temppart)
				temppart = null
				return TRUE
		if(!istype(loc,/turf))
			to_chat(user, "<span class='warning'>You can't assemble the MoMMI, \the [src] has to be standing on the ground (or a table) to be perfectly precise.</span>")
			return TRUE
		if(!brainmob)
			to_chat(user, "<span class='warning'>What are you doing oh god put the brain back in.</span>")
			return TRUE
		if(!brainmob.key)
			if(!mind_can_reenter(brainmob.mind))
				to_chat(user, "<span class='notice'>\The [src] indicates that their mind is completely unresponsive; there's no point.</span>")
				return TRUE
		if(brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>Yeah, good idea. Give something deader than the pizza in your fridge legs.  Mom would be so proud.</span>")
			return TRUE
		if(brainmob.mind in ticker.mode.head_revolutionaries)
			to_chat(user, "<span class='warning'>The [src]'s firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept the brain.</span>")
			return TRUE
		if(jobban_isbanned(brainmob, "Mobile MMI"))
			to_chat(user, "<span class='warning'>This brain does not seem to fit.</span>")
			return TRUE
		//canmove = 0
		icon = null
		invisibility = 101
		var/mob/living/silicon/robot/mommi/M = new /mob/living/silicon/robot/mommi(get_turf(loc))
		if(!M)	return
		M.invisibility = 0
		//M.custom_name = created_name
		M.Namepick()
		M.updatename()
		brainmob.mind.transfer_to(M)

		if(M.mind && M.mind.special_role)
			M.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

		M.job = "MoMMI"

		M.cell = locate(/obj/item/weapon/cell) in contents
		M.cell.loc = M
		src.loc = M//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
		M.mmi = src
		return TRUE
	for(var/t in mommi_assembly_parts)
		if(istype(O,t))
			var/cc=contents_count(t)
			if(cc<mommi_assembly_parts[t])
				if(!brainmob)
					to_chat(user, "<span class='warning'>Why are you sticking robot legs on an empty [src], you idiot?</span>")
					return TRUE
				if(!user.drop_item(O, src))
					to_chat(user, "<span class='warning'>You can't let go of \the [src]!</span>")
					return FALSE

				contents += O
				to_chat(user, "<span class='notice'>You successfully add \the [O] to the contraption,</span>")
				return TRUE
			else if(cc==mommi_assembly_parts[t])
				to_chat(user, "<span class='warning'>You have enough of these.</span>")
				return TRUE
	return FALSE

/obj/item/device/mmi/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(try_handling_mommi_construction(O,user))
		return
	if(istype(O,/obj/item/organ/brain) && !brainmob) //Time to stick a brain in it --NEO
		// MaMIs inherit from brain, but they shouldn't be insertable into a MMI
		if (istype(O, /obj/item/organ/brain/mami))
			to_chat(user, "<span class='warning'>You are only able to fit organic brains on a MMI. [src] won't work.</span>")
			return TRUE

		var/obj/item/organ/brain/BO = O
		if(!BO.brainmob)
			to_chat(user, "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain.</span>")
			return TRUE
		// Checking to see if the ghost has been moused/borer'd/etc since death.
		var/mob/living/carbon/brain/BM = BO.brainmob
		if(!BM.client)
			var/mob/dead/observer/ghost = get_ghost_from_mind(BM.mind)
			if(ghost && ghost.client && ghost.can_reenter_corpse)
				to_chat(user, "<span class='warning'>\The [src] indicates that \the [O] seems slow to respond. Try again in a few seconds.</span>")
				ghost << 'sound/effects/adminhelp.ogg'
				to_chat(ghost, "<span class='interface'><b><font size = 3>Someone is trying to put your brain in a MMI. Return to your body if you want to be resurrected!</b> \
					(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[ghost];reentercorpse=1'>click here!</a>)</font></span>")
				return TRUE
			to_chat(user, "<span class='warning'>\The [src] indicates that \the [O] is completely unresponsive; there's no point.</span>")
			return TRUE
		if(!user.drop_item(O))
			to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
			return TRUE

		src.visible_message("<span class='notice'>[user] sticks \a [O] into \the [src].</span>")

		brainmob = BO.brainmob
		BO.brainmob = null
		brainmob.loc = src
		brainmob.container = src
		brainmob.stat = 0
		brainmob.resurrect()

		qdel(O)
		O = null

		name = "[initial(name)]: [brainmob.real_name]"
		icon_state = "mmi_full"

		locked = 1

		feedback_inc("cyborg_mmis_filled",1)

		return TRUE

	if((istype(O,/obj/item/weapon/card/id)||istype(O,/obj/item/device/pda)) && brainmob)
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return TRUE

	if(istype(O, /obj/item/weapon/implanter))
		return//toplel

	if(brainmob)
		O.attack(brainmob, user)//Oh noooeeeee
		return
	..()

	//TODO: ORGAN REMOVAL UPDATE. Make the brain remain in the MMI so it doesn't lose organ data.
/obj/item/device/mmi/attack_self(mob/user as mob)
	if(!brainmob)
		to_chat(user, "<span class='warning'>You upend \the [src], but there's nothing in it.")
	else if(locked)
		to_chat(user, "<span class='warning'>You upend \the [src], but the brain is clamped into place.")
	else
		to_chat(user, "<span class='notice'>You upend \the [src], spilling the brain onto the floor.</span>")
		var/obj/item/organ/brain/brain = new(user.loc)
		brainmob.container = null//Reset brainmob mmi var.
		brainmob.loc = brain//Throw mob into brain.
		living_mob_list -= brainmob//Get outta here
		brain.brainmob = brainmob//Set the brain to use the brainmob
		brainmob = null//Set mmi brainmob var to null

		icon_state = "mmi_empty"
		name = initial(name)

/obj/item/device/mmi/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	if(istype(H) && H.dna)
		brainmob.dna = H.dna.Clone()
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

/obj/item/device/mmi/radio_enabled/New()
	..()
	radio = new(src)//Spawns a radio inside the MMI.
	radio.broadcasting = 0//So it's broadcasting from the start.

/obj/item/device/mmi/radio_enabled/Destroy()
	..()
	qdel(radio)
	radio = null

/obj/item/device/mmi/radio_enabled/verb/Toggle_Broadcasting()
	set name = "Toggle Broadcasting"
	set desc = "Toggle broadcasting channel on or off."
	set category = "MMI"
	set src = usr.loc//In user location, or in MMI in this case.
	set popup_menu = 0//Will not appear when right clicking.

	if(brainmob.stat)//Only the brainmob will trigger these so no further check is necessary.
		to_chat(brainmob, "Can't do that while incapacitated or dead.")

	radio.broadcasting = radio.broadcasting==1 ? 0 : 1
	to_chat(brainmob, "<<span class='notice'>Radio is [radio.broadcasting==1 ? "now" : "no longer"] broadcasting.</span>")

/obj/item/device/mmi/radio_enabled/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = 0

	if(brainmob.stat)
		to_chat(brainmob, "Can't do that while incapacitated or dead.")

	radio.listening = radio.listening==1 ? 0 : 1
	to_chat(brainmob, "<span class='notice'>Radio is [radio] receiving broadcast.</span>")

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

/obj/item/device/mmi/proc/contents_count(var/type)
	var/c=0
	for(var/O in contents)
		if(istype(O,type))
			c++
	return c



/obj/item/device/mmi/examine(mob/user)
	to_chat(user, "<span class='info'>*---------*</span>")
	..()
	if(locked!=2)
		if(src.brainmob)
			if(src.brainmob.stat == DEAD)
				to_chat(user, "<span class='deadsay'>It appears the brain has suffered irreversible tissue degeneration</span>")//suicided

			else if(!src.brainmob.client)
				to_chat(user, "<span class='notice'>It appears to be lost in its own thoughts</span>")//closed game window

			else if(!src.brainmob.key)
				to_chat(user, "<span class='warning'>It seems to be in a deep dream-state</span>")//ghosted

		to_chat(user, "<span class='info'>It's interface is [locked ? "locked" : "unlocked"] </span>")
	to_chat(user, "<span class='info'>*---------*</span>")

/obj/item/device/mmi/OnMobDeath(var/mob/living/carbon/brain/B)
	icon_state = "mmi_dead"
	visible_message(message = "<span class='danger'>[B]'s MMI flatlines!</span>", blind_message = "<span class='warning'>You hear something flatline.</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
