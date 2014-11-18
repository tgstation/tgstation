/mob/living/carbon/human/proc/monkeyize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		if (W==w_uniform) // will be torn
			continue
		drop_from_inventory(W)
	regenerate_icons()

	monkeyizing = 1
	canmove = 0
	stunned = 1
	icon = null
	invisibility = 101

	for(var/t in organs)
		del(t)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null

	if(!species.primitive) //If the creature in question has no primitive set, this is going to be messy.
		gib()
		return

	var/mob/living/carbon/monkey/O = null

	O = new species.primitive(loc)

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

	O << "<B>You are now [O]. </B>"

	spawn(0)//To prevent the proc from returning null.
		del(src)
	del(animation)

	return O

/mob/living/carbon/human/proc/Cluwneize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)	//this really should not be necessary
		del(t)

	var/mob/living/simple_animal/hostile/retaliate/cluwne/new_mob = new (src.loc)
	new_mob.universal_speak = 1
	new_mob.gender=src.gender
	new_mob.name = pick(clown_names)
	new_mob.real_name = new_mob.name
	new_mob.mutations += M_CLUMSY
	new_mob.mutations += M_FAT
	new_mob.setBrainLoss(100)
	new_mob.a_intent = "hurt"
	new_mob.key = key

	new_mob << "<span class='sinister'>Instantly, what was your clothes fall off, and are replaced with a mockery of all that is clowning; Disgusting-looking garb that the foulest of creatures would be afraid of wearing. Your very face begins to shape, mold, into something truely disgusting. A mask made of flesh. Your body is feeling the worst pain it has ever felt. As you think it cannot get any worse, one of your arms turns into a horrific meld of flesh and plastic, making a limb made entirely of bike horns.</span>"
	new_mob << "<span class='sinister'>Your very soul is being torn apart. What was organs, blood, flesh, is now darkness. And inside the infernal void that was once a living being, something sinister takes root. As what you were goes away, you try to let out a frantic plea of 'Help me! Please god help me!' but your god has abandoned you, and all that leaves your horrible mouth is a strangled 'HONK!'.</span>"
	new_mob.say("HONK!")
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/mob/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/human/AIize()
	if (monkeyizing)
		return
	for(var/t in organs)
		del(t)

	return ..()

/mob/living/carbon/AIize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	return ..()

/mob/proc/AIize()
	if(client)
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jams for AIs
	var/mob/living/silicon/ai/O = new (loc, base_law_type,,1)//No MMI but safety is in effect.
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
	O << {"Use say ":b to speak to your cyborgs through binary."}
	if (!(ticker && ticker.mode && (O.mind in ticker.mode.malf_ai)))
		O.show_laws()
		O << "<b>These laws may be changed by other players, or by you being the traitor.</b>"

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
	del(src)


//human -> robot
/mob/living/carbon/human/proc/Robotize(var/delete_items = 0)
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		if(delete_items)
			del(W)
		else
			drop_from_inventory(W)
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( loc )

	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 7500

	O.gender = gender
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

	O.Namepick()

	spawn(0)//To prevent the proc from returning null.
		del(src)
	return O

//human -> mommi
/mob/living/carbon/human/proc/MoMMIfy(round_start = 0)
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)

	var/mob/living/silicon/robot/mommi/O = new /mob/living/silicon/robot/mommi( loc )

	// MoMMIs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = (round_start ? 7500 : 15000)
	O.cell.charge = (round_start ? 7500 : 15000)


	O.gender = gender
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

	O.Namepick()


	spawn(0)//To prevent the proc from returning null.
		del(src)
	return O

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)

	new_xeno.a_intent = "hurt"
	new_xeno.key = key

	new_xeno << "<B>You are now an alien.</B>"
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/mob/living/carbon/human/proc/slimeize(adult as num, reproduce as num)
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)
		del(t)

	var/mob/living/carbon/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/carbon/slime/M = new/mob/living/carbon/slime(loc)
			M.nutrition = round(nutrition/number)
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		if(adult)
			new_slime = new /mob/living/carbon/slime/adult(loc)
		else
			new_slime = new /mob/living/carbon/slime(loc)
	new_slime.a_intent = "hurt"
	new_slime.key = key

	new_slime << "<B>You are now a slime. Skreee!</B>"
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/mob/living/carbon/human/proc/corgize()
	if (monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in organs)	//this really should not be necessary
		del(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)
	new_corgi.a_intent = "hurt"
	new_corgi.key = key

	new_corgi << "<B>You are now a Corgi. Yap Yap!</B>"
	spawn(0)//To prevent the proc from returning null.
		del(src)
	return

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		usr << "\red Sorry but this mob type is currently unavailable."
		return

	if(monkeyizing)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)

	regenerate_icons()
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	for(var/t in organs)
		del(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = "hurt"


	new_mob << "You suddenly feel more... animalistic."
	spawn()
		del(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		usr << "\red Sorry but this mob type is currently unavailable."
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = "hurt"
	new_mob << "You feel more... animalistic"

	del(src)

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



