////////////////////////////////////////////////////////////////////////////////////////////////////
//										EIGENSTASIUM
///////////////////////////////////////////////////////////////////////////////////////////////////
//eigenstate Chem
//Teleports you to chemistry and back
//OD teleports you randomly around the Station
//Addiction send you on a wild ride and replaces you with an alternative reality version of yourself.
//During the process you get really hungry, then your items start teleporting randomly,
//then alternative versions of yourself are brought in from a different universe and they yell at you.
//and finally you yourself get teleported to an alternative universe, and character your playing is replaced with said alternative

/datum/reagent/fermi/eigenstate
	name = "Eigenstasium"
	id = "eigenstate"
	description = "A strange mixture formed from a controlled reaction of bluespace with plasma, that causes localised eigenstate fluxuations within the patient"
	taste_description = "wiggly cosmic dust."
	color = "#5020F4" // rgb: 50, 20, 255
	overdose_threshold = 15
	addiction_threshold = 15
	metabolization_rate = 1.2 * REAGENTS_METABOLISM
	addiction_stage2_end = 30
	addiction_stage3_end = 41
	addiction_stage4_end = 44 //Incase it's too long
	data = list("location_created" = null)
	var/turf/location_created
	var/obj/effect/overlay/holo_pad_hologram/Eigenstate
	var/turf/open/location_return = null
	var/addictCyc3 = 0
	var/mob/living/carbon/fermi_Tclone = null
	var/teleBool = FALSE
	pH = 3.7
	can_synth = TRUE

/datum/reagent/fermi/eigenstate/on_new(list/data)
	location_created = data.["location_created"]

//Main functions
/datum/reagent/fermi/eigenstate/on_mob_life(mob/living/M) //Teleports to chemistry!
	if(current_cycle == 0)
		log_game("FERMICHEM: [M] ckey: [M.key] took eigenstasium")

		//make hologram at return point
		Eigenstate = new(loc)
		Eigenstate.appearance = M.appearance
		Eigenstate.alpha = 170
		Eigenstate.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
		Eigenstate.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
		Eigenstate.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
		Eigenstate.setAnchored(TRUE)//So space wind cannot drag it.
		Eigenstate.name = "[M]'s' eigenstate"//If someone decides to right click.
		Eigenstate.set_light(2)	//hologram lighting

		location_return = get_turf(M)	//sets up return point
		to_chat(M, "<span class='userdanger'>You feel your wavefunction split!</span>")
		if(purity > 0.9) //Teleports you home if it's pure enough
			if(!location_created && data) //Just in case
				location_created = data.["location_created"]
			log_game("FERMICHEM: [M] ckey: [M.key] returned to [location_created] using eigenstasium")
			do_sparks(5,FALSE,M)
			do_teleport(M, location_created, 0, asoundin = 'sound/effects/phasein.ogg')
			do_sparks(5,FALSE,M)
			SSblackbox.record_feedback("tally", "fermi_chem", 1, "Pure eigentstate jumps")


	if(prob(20))
		do_sparks(5,FALSE,M)
	..()

/datum/reagent/fermi/eigenstate/on_mob_delete(mob/living/M) //returns back to original location
	do_sparks(5,FALSE,M)
	to_chat(M, "<span class='userdanger'>You feel your wavefunction collapse!</span>")
	do_teleport(M, location_return, 0, asoundin = 'sound/effects/phasein.ogg') //Teleports home
	do_sparks(5,FALSE,M)
	qdel(Eigenstate)
	..()

/datum/reagent/fermi/eigenstate/overdose_start(mob/living/M) //Overdose, makes you teleport randomly
	. = ..()
	to_chat(M, "<span class='userdanger'>Oh god, you feel like your wavefunction is about to tear.</span>")
	log_game("FERMICHEM: [M] ckey: [M.key] has overdosed on eigenstasium")
	M.Jitter(20)
	metabolization_rate += 0.5 //So you're not stuck forever teleporting.

/datum/reagent/fermi/eigenstate/overdose_process(mob/living/M) //Overdose, makes you teleport randomly, probably one of my favourite effects. Sometimes kills you.
	do_sparks(5,FALSE,M)
	do_teleport(M, get_turf(M), 10, asoundin = 'sound/effects/phasein.ogg')
	do_sparks(5,FALSE,M)
	..()

//Addiction
/datum/reagent/fermi/eigenstate/addiction_act_stage1(mob/living/M) //Welcome to Fermis' wild ride.
	if(addiction_stage == 1)
		to_chat(M, "<span class='userdanger'>Your wavefunction feels like it's been ripped in half. You feel empty inside.</span>")
		log_game("FERMICHEM: [M] ckey: [M.key] has become addicted to eigenstasium")
		M.Jitter(10)
	M.nutrition = M.nutrition - (M.nutrition/15)
	..()

/datum/reagent/fermi/eigenstate/addiction_act_stage2(mob/living/M)
	if(addiction_stage == 11)
		to_chat(M, "<span class='userdanger'>You start to convlse violently as you feel your consciousness split and merge across realities as your possessions fly wildy off your body.</span>")
		M.Jitter(200)
		M.Knockdown(200)
		M.Stun(80)
	var/items = M.get_contents()
	if(!LAZYLEN(items))
		return ..()
	var/obj/item/I = pick(items)
	if(istype(I, /obj/item/implant))
		qdel(I)
		to_chat(M, "<span class='userdanger'>You feel your implant rip itself out of you, sent flying off to another dimention!</span>")
	else
		M.dropItemToGround(I, TRUE)
	do_sparks(5,FALSE,I)
	do_teleport(I, get_turf(I), 5, no_effects=TRUE);
	do_sparks(5,FALSE,I)
	..()

/datum/reagent/fermi/eigenstate/addiction_act_stage3(mob/living/M)//Pulls multiple copies of the character from alternative realities while teleporting them around!
	//Clone function - spawns a clone then deletes it - simulates multiple copies of the player teleporting in
	switch(addictCyc3) //Loops 0 -> 1 -> 2 -> 1 -> 2 -> 1 ...ect.
		if(0)
			M.Jitter(100)
			to_chat(M, "<span class='userdanger'>Your eigenstate starts to rip apart, causing a localised collapsed field as you're ripped from alternative universes, trapped around the densisty of the event horizon.</span>")
		if(1)
			var/typepath = M.type
			fermi_Tclone = new typepath(M.loc)
			var/mob/living/carbon/C = fermi_Tclone
			fermi_Tclone.appearance = M.appearance
			C.real_name = M.real_name
			M.visible_message("[M] collapses in from an alternative reality!")
			do_teleport(C, get_turf(C), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
			do_sparks(5,FALSE,C)
			C.emote("spin")
			M.emote("spin")
			M.emote("me",1,"flashes into reality suddenly, gasping as they gaze around in a bewildered and highly confused fashion!",TRUE)
			C.emote("me",1,"[pick("says", "cries", "mewls", "giggles", "shouts", "screams", "gasps", "moans", "whispers", "announces")], \"[pick("Bugger me, whats all this then?", "Hot damn, where is this?", "sacre bleu! Ou suis-je?!", "Yee haw! This is one hell of a hootenanny!", "WHAT IS HAPPENING?!", "Picnic!", "Das ist nicht deutschland. Das ist nicht akzeptabel!!!", "I've come from the future to warn you to not take eigenstasium! Oh no! I'm too late!", "You fool! You took too much eigenstasium! You've doomed us all!", "What...what's with these teleports? It's like one of my Japanese animes...!", "Ik stond op het punt om mehki op tafel te zetten, en nu, waar ben ik?", "This must be the will of Stein's gate.", "Fermichem was a mistake", "This is one hell of a beepsky smash.", "Now neither of us will be virgins!")]\"")
		if(2)
			var/mob/living/carbon/C = fermi_Tclone
			do_sparks(5,FALSE,C)
			qdel(C) //Deletes CLONE, or at least I hope it is.
			M.visible_message("[M] is snapped across to a different alternative reality!")
			addictCyc3 = 0 //counter
			fermi_Tclone = null
	addictCyc3++
	do_teleport(M, get_turf(M), 2, no_effects=TRUE) //Teleports player randomly
	do_sparks(5,FALSE,M)
	..()

/datum/reagent/fermi/eigenstate/addiction_act_stage4(mob/living/M) //Thanks for riding Fermis' wild ride. Mild jitter and player buggery.
	if(addiction_stage == 42)
		do_sparks(5,FALSE,M)
		do_teleport(M, get_turf(M), 2, no_effects=TRUE) //teleports clone so it's hard to find the real one!
		do_sparks(5,FALSE,M)
		M.Sleeping(100, 0)
		M.Jitter(50)
		M.Knockdown(100)
		to_chat(M, "<span class='userdanger'>You feel your eigenstate settle, snapping an alternative version of yourself into reality. All your previous memories are lost and replaced with the alternative version of yourself. This version of you feels more [pick("affectionate", "happy", "lusty", "radical", "shy", "ambitious", "frank", "voracious", "sensible", "witty")] than your previous self, sent to god knows what universe.</span>")
		M.emote("me",1,"flashes into reality suddenly, gasping as they gaze around in a bewildered and highly confused fashion!",TRUE)
		log_game("FERMICHEM: [M] ckey: [M.key] has become an alternative universe version of themselves.")
		M.reagents.remove_all_type(/datum/reagent, 100, 0, 1)
		/*
		for(var/datum/mood_event/Me in M)
			SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, Me) //Why does this not work?
		*/
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "Alternative dimension", /datum/mood_event/eigenstate)
		SSblackbox.record_feedback("tally", "fermi_chem", 1, "Wild rides ridden")

	if(prob(20))
		do_sparks(5,FALSE,M)
	SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[id]_overdose")//holdover until above fix works
	..()

/datum/reagent/fermi/eigenstate/reaction_turf(turf/T, reac_volume)
	//if(cached_purity < 0.99) To add with next batch of fixes and tweaks.
	var/obj/structure/closet/First
	var/obj/structure/closet/Previous
	for(var/obj/structure/closet/C in T.contents)
		if(C.eigen_teleport == TRUE)
			C.visible_message("[C] fizzes, it's already linked to something else!")
			continue
		if(!Previous)
			First = C
			Previous = C
			continue
		C.eigen_teleport = TRUE
		C.eigen_target = Previous
		C.color = "#9999FF" //Tint the locker slightly.
		C.alpha = 200
		do_sparks(5,FALSE,C)
		Previous = C
	if(!First)
		return
	if(Previous == First)
		return
	First.eigen_teleport = TRUE
	First.eigen_target = Previous
	First.color = "#9999FF"
	First.alpha = 200
	do_sparks(5,FALSE,First)
	First.visible_message("The lockers' eigenstates spilt and merge, linking each of their contents together.")

//eigenstate END
