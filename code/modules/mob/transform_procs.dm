<<<<<<< HEAD
/mob/living/carbon/proc/monkeyize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_DEFAULTMSG))
	if (notransform)
		return
	//Handle items on mob

	//first implants & organs
	var/list/implants = list()
	var/list/int_organs = list()

	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/weapon/implant/W in src)
			implants += W

	if (tr_flags & TR_KEEPORGANS)
		for(var/obj/item/organ/I in internal_organs)
			int_organs += I
			I.Remove(src, 1)

	if(tr_flags & TR_KEEPITEMS)
		for(var/obj/item/W in (src.contents-implants-int_organs))
			unEquip(W)

	//Make mob invisible and spawn animation
	notransform = 1
	canmove = 0
	stunned = 1
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	var/atom/movable/overlay/animation = new( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(22)
	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey( loc )
	qdel(animation)

	// hash the original name?
	if(tr_flags & TR_HASHNAME)
		O.name = "monkey ([copytext(md5(real_name), 2, 6)])"
		O.real_name = "monkey ([copytext(md5(real_name), 2, 6)])"

	//handle DNA and other attributes
	dna.transfer_identity(O)
	O.updateappearance(icon_update=0)

	if(tr_flags & TR_KEEPSE)
		O.dna.struc_enzymes = dna.struc_enzymes
		var/datum/mutation/human/race/R = mutations_list[RACEMUT]
		O.dna.struc_enzymes = R.set_se(O.dna.struc_enzymes, on=1)//we don't want to keep the race block inactive

	if(suiciding)
		O.suiciding = suiciding
	if(hellbound)
		O.hellbound = hellbound
	O.loc = loc
	O.a_intent = "harm"

	//keep viruses?
	if (tr_flags & TR_KEEPVIRUS)
		O.viruses = viruses
		viruses = list()
		for(var/datum/disease/D in O.viruses)
			D.affected_mob = O
			D.holder = O

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		O.setToxLoss(getToxLoss())
		O.adjustBruteLoss(getBruteLoss())
		O.setOxyLoss(getOxyLoss())
		O.adjustFireLoss(getFireLoss())
		O.radiation = radiation

	//re-add implants to new mob
	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O

	//re-add organs to new mob
	if(tr_flags & TR_KEEPORGANS)
		for(var/obj/item/organ/I in O.internal_organs)
			qdel(I)

		for(var/obj/item/organ/I in int_organs)
			I.Insert(O, 1)

	//transfer mind and delete old mob
	if(mind)
		mind.transfer_to(O)
		if(O.mind.changeling)
			O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
	if (tr_flags & TR_DEFAULTMSG)
		O << "<B>You are now a monkey.</B>"

	for(var/A in loc.vars)
		if(loc.vars[A] == src)
			loc.vars[A] = O

	. = O

	qdel(src)

//////////////////////////           Humanize               //////////////////////////////
//Could probably be merged with monkeyize but other transformations got their own procs, too

/mob/living/carbon/proc/humanize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_DEFAULTMSG))
	if (notransform)
		return
	//Handle items on mob

	//first implants & organs
	var/list/implants = list()
	var/list/int_organs = list()

	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/weapon/implant/W in src)
			implants += W

	if (tr_flags & TR_KEEPORGANS)
		for(var/obj/item/organ/I in internal_organs)
			int_organs += I
			I.Remove(src, 1)

	//now the rest
	if (tr_flags & TR_KEEPITEMS)
		for(var/obj/item/W in (src.contents-implants-int_organs))
			unEquip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)

	//Make mob invisible and spawn animation
	notransform = 1
	canmove = 0
	stunned = 1
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM
	var/atom/movable/overlay/animation = new( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(22)
	var/mob/living/carbon/human/O = new( loc )
	for(var/obj/item/C in O.loc)
		O.equip_to_appropriate_slot(C)
	qdel(animation)

	dna.transfer_identity(O)
	O.updateappearance(mutcolor_update=1)

	if(cmptext("monkey",copytext(O.dna.real_name,1,7)))
		O.real_name = random_unique_name(O.gender)
		O.dna.generate_unique_enzymes(O)
	else
		O.real_name = O.dna.real_name
	O.name = O.real_name

	if(tr_flags & TR_KEEPSE)
		O.dna.struc_enzymes = dna.struc_enzymes
		var/datum/mutation/human/race/R = mutations_list[RACEMUT]
		O.dna.struc_enzymes = R.set_se(O.dna.struc_enzymes, on=0)//we don't want to keep the race block active
		O.domutcheck()

	if(suiciding)
		O.suiciding = suiciding
	if(hellbound)
		O.hellbound = hellbound

	O.loc = loc

	//keep viruses?
	if (tr_flags & TR_KEEPVIRUS)
		O.viruses = viruses
		viruses = list()
		for(var/datum/disease/D in O.viruses)
			D.affected_mob = O
			D.holder = O
		O.med_hud_set_status()

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		O.setToxLoss(getToxLoss())
		O.adjustBruteLoss(getBruteLoss())
		O.setOxyLoss(getOxyLoss())
		O.adjustFireLoss(getFireLoss())
		O.radiation = radiation

	//re-add implants to new mob
	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O
		O.sec_hud_set_implants()

	if(tr_flags & TR_KEEPORGANS)
		for(var/obj/item/organ/I in O.internal_organs)
			qdel(I)

		for(var/obj/item/organ/I in int_organs)
			I.Insert(O, 1)

	if(mind)
		mind.transfer_to(O)
		if(O.mind.changeling)
			for(var/obj/effect/proc_holder/changeling/humanform/HF in O.mind.changeling.purchasedpowers)
				mind.changeling.purchasedpowers -= HF

	O.a_intent = "help"
	if (tr_flags & TR_DEFAULTMSG)
		O << "<B>You are now a human.</B>"

	. = O

	for(var/A in loc.vars)
		if(loc.vars[A] == src)
			loc.vars[A] = O

	qdel(src)


/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/human/AIize()
	if (notransform)
		return
	for(var/t in bodyparts)
		qdel(t)

	return ..()

/mob/living/carbon/AIize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	return ..()

/mob/proc/AIize()
	if(client)
		stopLobbySound()
	var/mob/living/silicon/ai/O = new (loc,,,1)//No MMI but safety is in effect.

	if(mind)
		mind.transfer_to(O)
	else
		O.key = key

	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if (sloc.name != "AI")
			continue
		if (locate(/mob/living) in sloc.loc)
			continue
		loc_landmark = sloc
	if (!loc_landmark)
		for(var/obj/effect/landmark/tripai in landmarks_list)
			if (tripai.name == "tripai")
				if(locate(/mob/living) in tripai.loc)
					continue
				loc_landmark = tripai
	if (!loc_landmark)
		O << "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone."
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if (sloc.name == "AI")
				loc_landmark = sloc

	O.loc = loc_landmark.loc
	for (var/obj/item/device/radio/intercom/comm in O.loc)
		comm.ai += O

	O << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
	O << "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>"
	O << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
	O << "To use something, simply click on it."
	O << {"Use say ":b to speak to your cyborgs through binary."} //"
	O << "For department channels, use the following say commands:"
	O << ":o - AI Private, :c - Command, :s - Security, :e - Engineering, :u - Supply, :v - Service, :m - Medical, :n - Science."
	O.show_laws()
	O << "<b>These laws may be changed by other players, or by you being the traitor.</b>"

	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
	O.verbs += /mob/living/silicon/ai/proc/ai_statuschange

	O.job = "AI"

	O.rename_self("ai")
	. = O
	qdel(src)
	return


//human -> robot
/mob/living/carbon/human/proc/Robotize(delete_items = 0)
	if (notransform)
		return
	for(var/obj/item/W in src)
		if(delete_items)
			qdel(W)
		else
			unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot(loc)

	// cyborgs produced by Robotize get an automatic power cell
	R.cell = new(R)
	R.cell.maxcharge = 7500
	R.cell.charge = 7500


	R.gender = gender
	R.invisibility = 0


	if(mind)		//TODO
		mind.transfer_to(R)
		if(mind.special_role)
			R.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		R.key = key

	if (config.rename_cyborg)
		R.rename_self("cyborg")

	if(R.mmi)
		R.mmi.name = "Man-Machine Interface: [real_name]"
		if(R.mmi.brain)
			R.mmi.brain.name = "[real_name]'s brain"
		if(R.mmi.brainmob)
			R.mmi.brainmob.real_name = real_name //the name of the brain inside the cyborg is the robotized human's name.
			R.mmi.brainmob.name = real_name

	R.loc = loc
	R.job = "Cyborg"
	R.notify_ai(1)

	. = R
	qdel(src)

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)

	new_xeno.a_intent = "harm"
	new_xeno.key = key

	new_xeno << "<B>You are now an alien.</B>"
	. = new_xeno
	qdel(src)

/mob/living/carbon/human/proc/slimeize(reproduce as num)
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

	var/mob/living/simple_animal/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/simple_animal/slime/M = new/mob/living/simple_animal/slime(loc)
			M.nutrition = round(nutrition/number)
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		new_slime = new /mob/living/simple_animal/slime(loc)
	new_slime.a_intent = "harm"
	new_slime.key = key

	new_slime << "<B>You are now a slime. Skreee!</B>"
	. = new_slime
	qdel(src)

/mob/proc/become_overmind(mode_made = 0)
	var/mob/camera/blob/B = new /mob/camera/blob(loc, 0, mode_made)
	if(mind)
		mind.transfer_to(B)
	else
		B.key = key
	. = B
	qdel(src)


/mob/proc/become_god(var/side_colour)
	var/mob/camera/god/G = new /mob/camera/god(loc)
	G.side = side_colour
	if(mind)
		mind.transfer_to(G)
	else
		G.key = key

	G.job = "Deity"
	G.rename_self("deity")
	G.update_icons()

	. = G
	qdel(src)



/mob/living/carbon/human/proc/corgize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.a_intent = "harm"
	new_corgi.key = key

	new_corgi << "<B>You are now a Corgi. Yap Yap!</B>"
	. = new_corgi
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		usr << "<span class='danger'>Sorry but this mob type is currently unavailable.</span>"
		return

	if(notransform)
		return
	for(var/obj/item/W in src)
		unEquip(W)

	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	for(var/t in bodyparts)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = "harm"


	new_mob << "You suddenly feel more... animalistic."
	. = new_mob
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		usr << "<span class='danger'>Sorry but this mob type is currently unavailable.</span>"
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = "harm"
	new_mob << "You feel more... animalistic"

	. = new_mob
	qdel(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/hostile/construct))
		return 0 //Verbs do not appear for players.

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/pet/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/pet/dog/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/shade))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/killertomato))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse))
		return 1 //It is impossible to pull up the player panel for mice (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1 //Bears will auto-attack mobs, even if they're player controlled (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1 //Parrots are no longer unfinished! -Nodrak

	//Not in here? Must be untested!
	return 0
=======
/mob/living/carbon/human/proc/monkeyize()
	if (monkeyizing)
		return

	for(var/obj/item/W in src)
		if (W==w_uniform) // will be torn
			continue
		drop_from_inventory(W)
	regenerate_icons()
	dropBorers()
	monkeyizing = 1
	canmove = 0
	delayNextAttack(50)
	icon = null
	invisibility = 101

	for(var/t in organs)
		qdel(t)
	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "h2monkey", sleeptime = 15)
	sleep(33)

	if(!species.primitive) //If the creature in question has no primitive set, this is going to be messy.
		gib()
		return

	var/mob/living/carbon/monkey/O = null

	O = new species.primitive(get_turf(src))

	O.dna = dna.Clone()
	O.dna.SetSEState(MONKEYBLOCK,1)
	O.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)
	O.loc = loc
	O.viruses = viruses
	viruses = list()
	for(var/datum/disease/D in O.viruses)
		D.affected_mob = O

	if (client)
		client.mob = O
	if(mind)
		mind.transfer_to(O)

	to_chat(O, "<B>You are now [O]. </B>")

	qdel(src)

	return O

/mob/living/carbon/human/proc/Cluwneize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	dropBorers()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)
	for(var/t in organs)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/hostile/retaliate/cluwne/new_mob = new (get_turf(src))
	new_mob.setGender(gender)
	new_mob.name = pick(clown_names)
	new_mob.real_name = new_mob.name
	new_mob.mutations += M_CLUMSY
	new_mob.mutations += M_FAT
	new_mob.setBrainLoss(100)
	new_mob.a_intent = I_HURT
	new_mob.key = key

	to_chat(new_mob, "<span class='sinister'>Instantly, what was your clothes fall off, and are replaced with a mockery of all that is clowning; Disgusting-looking garb that the foulest of creatures would be afraid of wearing. Your very face begins to shape, mold, into something truely disgusting. A mask made of flesh. Your body is feeling the worst pain it has ever felt. As you think it cannot get any worse, one of your arms turns into a horrific meld of flesh and plastic, making a limb made entirely of bike horns.</span>")
	to_chat(new_mob, "<span class='sinister'>Your very soul is being torn apart. What was organs, blood, flesh, is now darkness. And inside the infernal void that was once a living being, something sinister takes root. As what you were goes away, you try to let out a frantic plea of 'Help me! Please god help me!' but your god has abandoned you, and all that leaves your horrible mouth is a strangled 'HONK!'.</span>")
	new_mob.say("HONK!")
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return new_mob

/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/human/AIize()
	if (monkeyizing)
		return
	for(var/t in organs)
		qdel(t)

	return ..()

/mob/living/carbon/AIize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	dropBorers()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)
	return ..()

/mob/proc/AIize()
	if(client)
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)// stop the jams for AIs

	var/mob/living/silicon/ai/O = new (get_turf(src), base_law_type,,1)//No MMI but safety is in effect.
	O.invisibility = 0
	O.aiRestorePowerRoutine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key

	var/obj/loc_landmark
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if (sloc.name != "AI")
			continue
		if (locate(/mob/living) in sloc.loc)
			continue
		loc_landmark = sloc
	if (!loc_landmark)
		for(var/obj/effect/landmark/tripai in landmarks_list)
			if (tripai.name == "tripai")
				if(locate(/mob/living) in tripai.loc)
					continue
				loc_landmark = tripai
	if (!loc_landmark)
		to_chat(O, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if (sloc.name == "AI")
				loc_landmark = sloc

	O.loc = loc_landmark.loc
	for (var/obj/item/device/radio/intercom/comm in O.loc)
		comm.ai += O

	to_chat(O, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(O, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(O, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(O, "To use something, simply click on it.")
	to_chat(O, {"Use say ":b to speak to your cyborgs through binary."})
	if (!(ticker && ticker.mode && (O.mind in ticker.mode.malf_ai)))
		O.show_laws()
		to_chat(O, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

	//O.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
	//O.verbs += /mob/living/silicon/ai/proc/ai_camera_track
	//O.verbs += /mob/living/silicon/ai/proc/ai_alerts
	//O.verbs += /mob/living/silicon/ai/proc/ai_camera_list
	O.verbs += /mob/living/silicon/ai/proc/ai_statuschange
	//O.verbs += /mob/living/silicon/ai/proc/ai_roster

	O.job = "AI"

	O.rename_self("ai",1)
	. = O
	qdel(src)


//human -> robot
/mob/living/carbon/human/proc/Robotize(var/delete_items = 0)
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		if(delete_items)
			qdel(W)
		else
			drop_from_inventory(W)
	dropBorers()
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)
	for(var/t in organs)
		qdel(t)

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(src))
	. = O
	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 7500

	O.setGender(gender)
	O.invisibility = 0

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.original = O
		else if(mind&&mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.loc = loc
	O.job = "Cyborg"

	O.mmi = new /obj/item/device/mmi(O)
	O.mmi.transfer_identity(src)//Does not transfer key/client.

	spawn() O.Namepick()

	spawn(0)//To prevent the proc from returning null.
		qdel(src)


//human -> mommi
/mob/living/carbon/human/proc/MoMMIfy(round_start = 0)
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	dropBorers()
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)
	for(var/t in organs)
		qdel(t)

	var/mob/living/silicon/robot/mommi/O = new /mob/living/silicon/robot/mommi(get_turf(src))
	. = O
	// MoMMIs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = (round_start ? 10000 : 15000)
	O.cell.charge = (round_start ? 10000 : 15000)


	O.setGender(gender)
	O.invisibility = 0


	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.original = O
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.loc = loc
	O.job = "Cyborg"

	O.mmi = new /obj/item/device/mmi(O)
	O.mmi.transfer_identity(src)//Does not transfer key/client.

	spawn() O.Namepick()


	spawn(0)//To prevent the proc from returning null.
		qdel(src)

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	dropBorers()
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)
	for(var/t in organs)
		qdel(t)

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(get_turf(src))
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(get_turf(src))
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(get_turf(src))

	new_xeno.a_intent = I_HURT
	new_xeno.key = key

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return new_xeno

/mob/living/carbon/human/proc/slimeize(adult as num, reproduce as num)
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	dropBorers()
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)
	for(var/t in organs)
		qdel(t)

	var/mob/living/carbon/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/carbon/slime/M = new/mob/living/carbon/slime(get_turf(src))
			M.nutrition = round(nutrition/number)
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		if(adult)
			new_slime = new /mob/living/carbon/slime/adult(get_turf(src))
		else
			new_slime = new /mob/living/carbon/slime(get_turf(src))
	new_slime.a_intent = I_HURT
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return new_slime

/mob/living/carbon/human/proc/corgize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	dropBorers()
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)
	for(var/t in organs)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (get_turf(src))
	new_corgi.a_intent = I_HURT
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return new_corgi

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	dropBorers()

	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	delayNextAttack(50)

	for(var/t in organs)
		qdel(t)

	var/mob/new_mob = new mobpath(get_turf(src))

	new_mob.key = key
	new_mob.a_intent = I_HURT


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	spawn()
		qdel(src)
	return new_mob

/mob/proc/Animalize()


	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(get_turf(src))

	new_mob.key = key
	new_mob.a_intent = I_HURT
	to_chat(new_mob, "You feel more... animalistic")

	spawn()
		qdel(src)
	return new_mob

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(var/MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/space_worm))
		return 0 //Unfinished. Very buggy, they seem to just spawn additional space worms everywhere and eating your own tail results in new worms spawning.

	if(ispath(MP, /mob/living/simple_animal/construct/behemoth))
		return 0 //I think this may have been an unfinished WiP or something. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/armoured))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/wraith))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/builder))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/shade))
		return 1
	if(ispath(MP, /mob/living/simple_animal/tomato))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse))
		return 1 //It is impossible to pull up the player panel for mice (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1 //Bears will auto-attack mobs, even if they're player controlled (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1 //Parrots are no longer unfinished! -Nodrak

	//Not in here? Must be untested!
	return 0



>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
