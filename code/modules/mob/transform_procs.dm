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
		for(var/obj/item/organ/internal/I in internal_organs)
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
	overlays.Cut()
	invisibility = 101

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
		for(var/obj/item/organ/internal/I in O.internal_organs)
			qdel(I)

		for(var/obj/item/organ/internal/I in int_organs)
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
		for(var/obj/item/organ/internal/I in internal_organs)
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
	overlays.Cut()
	invisibility = 101
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
		for(var/obj/item/organ/internal/I in O.internal_organs)
			qdel(I)

		for(var/obj/item/organ/internal/I in int_organs)
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
	for(var/t in organs)
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
	invisibility = 101
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
	invisibility = 101
	for(var/t in organs)
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
	invisibility = 101
	for(var/t in organs)
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
	invisibility = 101
	for(var/t in organs)
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
	invisibility = 101
	for(var/t in organs)	//this really should not be necessary
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
	invisibility = 101

	for(var/t in organs)
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
