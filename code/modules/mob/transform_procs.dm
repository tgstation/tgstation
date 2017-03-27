/mob/living/carbon/proc/monkeyize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_DEFAULTMSG))
	if (notransform)
		return
	//Handle items on mob

	//first implants & organs
	var/list/stored_implants = list()
	var/list/int_organs = list()

	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/X in implants)
			var/obj/item/weapon/implant/IMP = X
			stored_implants += IMP
			IMP.removed(src, 1, 1)

	if (tr_flags & TR_KEEPORGANS)
		for(var/X in internal_organs)
			var/obj/item/organ/I = X
			int_organs += I
			I.Remove(src, 1)

	var/list/missing_bodyparts_zones = get_missing_limbs()

	var/obj/item/cavity_object

	var/obj/item/bodypart/chest/CH = get_bodypart("chest")
	if(CH.cavity_item)
		cavity_object = CH.cavity_item
		CH.cavity_item = null

	if(tr_flags & TR_KEEPITEMS)
		var/Itemlist = get_equipped_items()
		Itemlist += held_items
		for(var/obj/item/W in Itemlist)
			dropItemToGround(W)

	//Make mob invisible and spawn animation
	notransform = 1
	canmove = 0
	stunned = 1
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	new /obj/effect/overlay/temp/monkeyify(get_turf(src))
	sleep(22)
	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey( loc )

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
	O.a_intent = INTENT_HARM

	//keep viruses?
	if (tr_flags & TR_KEEPVIRUS)
		O.viruses = viruses
		viruses = list()
		for(var/datum/disease/D in O.viruses)
			D.affected_mob = O
			D.holder = O

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		O.setToxLoss(getToxLoss(), 0)
		O.adjustBruteLoss(getBruteLoss(), 0)
		O.setOxyLoss(getOxyLoss(), 0)
		O.setCloneLoss(getCloneLoss(), 0)
		O.adjustFireLoss(getFireLoss(), 0)
		O.setBrainLoss(getBrainLoss(), 0)
		O.updatehealth()
		O.radiation = radiation

	//re-add implants to new mob
	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/Y in implants)
			var/obj/item/weapon/implant/IMP = Y
			IMP.implant(O, null, 1)

	//re-add organs to new mob
	if(tr_flags & TR_KEEPORGANS)
		for(var/X in O.internal_organs)
			qdel(X)

		for(var/X in int_organs)
			var/obj/item/organ/I = X
			I.Insert(O, 1)

	var/obj/item/bodypart/chest/torso = O.get_bodypart("chest")
	if(cavity_object)
		torso.cavity_item = cavity_object //cavity item is given to the new chest
		cavity_object.loc = O

	for(var/missing_zone in missing_bodyparts_zones)
		var/obj/item/bodypart/BP = O.get_bodypart(missing_zone)
		BP.drop_limb(1)
		if(!(tr_flags & TR_KEEPORGANS)) //we didn't already get rid of the organs of the newly spawned mob
			for(var/X in O.internal_organs)
				var/obj/item/organ/G = X
				if(BP.body_zone == check_zone(G.zone))
					if(mind && mind.changeling && istype(G, /obj/item/organ/brain))
						continue //so headless changelings don't lose their brain when transforming
					qdel(G) //we lose the organs in the missing limbs
		qdel(BP)

	//transfer mind and delete old mob
	if(mind)
		mind.transfer_to(O)
		if(O.mind.changeling)
			O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)


	if (tr_flags & TR_DEFAULTMSG)
		to_chat(O, "<B>You are now a monkey.</B>")

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
	var/list/stored_implants = list()
	var/list/int_organs = list()

	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/X in implants)
			var/obj/item/weapon/implant/IMP = X
			stored_implants += IMP
			IMP.removed(src, 1, 1)

	if (tr_flags & TR_KEEPORGANS)
		for(var/X in internal_organs)
			var/obj/item/organ/I = X
			int_organs += I
			I.Remove(src, 1)

	var/list/missing_bodyparts_zones = get_missing_limbs()

	var/obj/item/cavity_object

	var/obj/item/bodypart/chest/CH = get_bodypart("chest")
	if(CH.cavity_item)
		cavity_object = CH.cavity_item
		CH.cavity_item = null

	//now the rest
	if (tr_flags & TR_KEEPITEMS)
		var/Itemlist = get_equipped_items()
		Itemlist += held_items
		for(var/obj/item/W in Itemlist)
			dropItemToGround(W, TRUE)
			if (client)
				client.screen -= W



	//Make mob invisible and spawn animation
	notransform = 1
	canmove = 0
	stunned = 1
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM
	new /obj/effect/overlay/temp/monkeyify/humanify(get_turf(src))
	sleep(22)
	var/mob/living/carbon/human/O = new( loc )
	for(var/obj/item/C in O.loc)
		O.equip_to_appropriate_slot(C)

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
		O.setToxLoss(getToxLoss(), 0)
		O.adjustBruteLoss(getBruteLoss(), 0)
		O.setOxyLoss(getOxyLoss(), 0)
		O.setCloneLoss(getCloneLoss(), 0)
		O.adjustFireLoss(getFireLoss(), 0)
		O.setBrainLoss(getBrainLoss(), 0)
		O.updatehealth()
		O.radiation = radiation

	//re-add implants to new mob
	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/Y in implants)
			var/obj/item/weapon/implant/IMP = Y
			IMP.implant(O, null, 1)

	if(tr_flags & TR_KEEPORGANS)
		for(var/X in O.internal_organs)
			qdel(X)

		for(var/X in int_organs)
			var/obj/item/organ/I = X
			I.Insert(O, 1)


	var/obj/item/bodypart/chest/torso = get_bodypart("chest")
	if(cavity_object)
		torso.cavity_item = cavity_object //cavity item is given to the new chest
		cavity_object.loc = O

	for(var/missing_zone in missing_bodyparts_zones)
		var/obj/item/bodypart/BP = O.get_bodypart(missing_zone)
		BP.drop_limb(1)
		if(!(tr_flags & TR_KEEPORGANS)) //we didn't already get rid of the organs of the newly spawned mob
			for(var/X in O.internal_organs)
				var/obj/item/organ/G = X
				if(BP.body_zone == check_zone(G.zone))
					if(mind && mind.changeling && istype(G, /obj/item/organ/brain))
						continue //so headless changelings don't lose their brain when transforming
					qdel(G) //we lose the organs in the missing limbs
		qdel(BP)

	if(mind)
		mind.transfer_to(O)
		if(O.mind.changeling)
			for(var/obj/effect/proc_holder/changeling/humanform/HF in O.mind.changeling.purchasedpowers)
				mind.changeling.purchasedpowers -= HF

	O.a_intent = INTENT_HELP
	if (tr_flags & TR_DEFAULTMSG)
		to_chat(O, "<B>You are now a human.</B>")

	. = O

	for(var/A in loc.vars)
		if(loc.vars[A] == src)
			loc.vars[A] = O

	qdel(src)

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
		dropItemToGround(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	return ..()

/mob/proc/AIize(transfer_after = TRUE)
	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)

	var/turf/loc_landmark
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if(sloc.name != "AI")
			continue
		if(locate(/mob/living/silicon/ai) in sloc.loc)
			continue
		loc_landmark = sloc.loc
	if(!loc_landmark)
		for(var/obj/effect/landmark/tripai in landmarks_list)
			if(tripai.name == "tripai")
				if(locate(/mob/living/silicon/ai) in tripai.loc)
					continue
				loc_landmark = tripai.loc
	if(!loc_landmark)
		to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if (sloc.name == "AI")
				loc_landmark = sloc.loc

	if(!transfer_after)
		mind.active = FALSE

	. = new /mob/living/silicon/ai(loc_landmark, null, src)

	qdel(src)

/mob/living/carbon/human/proc/Robotize(delete_items = 0, transfer_after = TRUE)
	if (notransform)
		return
	for(var/obj/item/W in src)
		if(delete_items)
			qdel(W)
		else
			dropItemToGround(W)
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
		if(!transfer_after)
			mind.active = FALSE
		mind.transfer_to(R)
		if(mind.special_role)
			R.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else if(transfer_after)
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
	R.notify_ai(NEW_BORG)

	. = R
	qdel(src)

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		dropItemToGround(W)
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

	new_xeno.a_intent = INTENT_HARM
	new_xeno.key = key

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	. = new_xeno
	qdel(src)

/mob/living/carbon/human/proc/slimeize(reproduce as num)
	if (notransform)
		return
	for(var/obj/item/W in src)
		dropItemToGround(W)
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
	new_slime.a_intent = INTENT_HARM
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	. = new_slime
	qdel(src)

/mob/proc/become_overmind(mode_made, starting_points = 60)
	var/mob/camera/blob/B = new /mob/camera/blob(loc, 0, mode_made, starting_points)
	if(mind)
		mind.transfer_to(B)
	else
		B.key = key
	. = B
	qdel(src)


/mob/living/carbon/human/proc/corgize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		dropItemToGround(W)
	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.a_intent = INTENT_HARM
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	. = new_corgi
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='danger'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(notransform)
		return
	for(var/obj/item/W in src)
		dropItemToGround(W)

	regenerate_icons()
	notransform = 1
	canmove = 0
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	for(var/t in bodyparts)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	. = new_mob
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='danger'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You feel more... animalistic")

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
