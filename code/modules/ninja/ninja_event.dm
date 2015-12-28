//Note to future generations: I didn't write this god-awful code I just ported it to the event system and tried to make it less moon-speaky.
//Don't judge me D; ~Carn //Maximum judging occuring - Remie.


/*

Contents:
- The Ninja "Random" Event
- Ninja creation code

*/

/datum/round_event_control/ninja
	name = "Space Ninja"
	typepath = /datum/round_event/ninja
	max_occurrences = 1
	earliest_start = 30000 // 1 hour


/datum/round_event/ninja
	var/success_spawn = 0

	var/helping_station
	var/key
	var/spawn_loc

	var/mob/living/carbon/human/Ninja


/datum/round_event/ninja/setup()
	helping_station = rand(0,1)


/datum/round_event/ninja/kill()
	if(!success_spawn && control)
		control.occurrences--
	return ..()


/datum/round_event/ninja/start()
	//selecting a spawn_loc
	if(!spawn_loc)
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/L in landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("ninjaspawn","carpspawn")
						spawn_locs += L.loc
		if(!spawn_locs.len)
			return kill()
		spawn_loc = pick(spawn_locs)
	if(!spawn_loc)
		return kill()

	//selecting a candidate player
	if(!key)
		var/list/candidates = get_candidates(ROLE_NINJA)
		if(!candidates.len)
			return kill()
		var/client/C = pick(candidates)
		key = C.key
	if(!key)
		return kill()

	//Prepare ninja player mind
	var/datum/mind/Mind = create_ninja_mind(key)
	Mind.active = 1

	//generate objectives - You'll generally get 6 objectives (Ninja is meant to be hardmode!)
	var/list/possible_targets = list()
	for(var/datum/mind/M in ticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(istype(M.current,/mob/living/carbon/human))
				if(M.special_role)
					possible_targets[M] = 0						//bad-guy
				else if(M.assigned_role in command_positions)
					possible_targets[M] = 1						//good-guy

/*
	Alright, so, if I had my way I'd axe all this retarded bullshit entirely, but I know some people would complain because
	porting ninja specifics to the random gen system would go horribly. I can at the very least axe 99% of the autism
	and make ninja code slightly more bearable.
	- Iamgoofball
*/
	var/list/objectives = list(1,2,3,4)
	while(Mind.objectives.len < 6)	//still not enough objectives! // WHY DOES THIS CALL FOR 6 OBJECTIVES
		switch(pick_n_take(objectives)) // BUT THEN PREVENT YOU FROM GETTING 4 IN THE END
			if(1)	//research
				add_objective(Mind, /datum/objective/download)

			if(2)	//steal
				add_objective(Mind, /datum/objective/default/steal/special)

			if(3)	//protect/kill
				if(prob(50))
					add_objective(Mind, /datum/objective/default/assassinate)
				else
					add_objective(Mind, /datum/objective/default/protect)
			if(4)	//debrain/capture
				if(prob(50))
					add_objective(Mind, /datum/objective/default/debrain)
				else
					add_objective(Mind, /datum/objective/capture)
			else
				break

	//Add a survival objective since it's usually broad enough for any round type.
	add_objective(Mind, /datum/objective/escape_obj/survive)


	//add some RP-fluff
	Mind.store_memory("I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	Mind.store_memory("Suprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	Mind.store_memory("Officially, [helping_station?"Nanotrasen":"The Syndicate"] are my employer.")

	//spawn the ninja and assign the candidate
	Ninja = create_space_ninja(spawn_loc)
	Mind.transfer_to(Ninja)

	//initialise equipment
	if(istype(Ninja.wear_suit,/obj/item/clothing/suit/space/space_ninja))
		//Should be true but we have to check these things.
		var/obj/item/clothing/suit/space/space_ninja/N = Ninja.wear_suit
		N.randomize_param()

	Ninja.internal = Ninja.s_store
	if(Ninja.internals)
		Ninja.internals.icon_state = "internal1"

	if(Ninja.mind != Mind)			//something has gone wrong!
		throw EXCEPTION("Ninja created with incorrect mind")
		return

	Ninja << sound('sound/effects/ninja_greeting.ogg') //so ninja you probably wouldn't even know if you were made one

	success_spawn = 1


//=======//NINJA CREATION PROCS//=======//

/proc/create_space_ninja(spawn_loc)
	var/mob/living/carbon/human/new_ninja = new(spawn_loc)
	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.real_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	A.copy_to(new_ninja)
	new_ninja.dna.update_dna_identity()
	new_ninja.equip_space_ninja()
	return new_ninja


/proc/create_ninja_mind(key)
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.assigned_role = "Space Ninja"
	Mind.special_role = "Space Ninja"
	ticker.mode.traitors |= Mind			//Adds them to current traitor list. Which is really the extra antagonist list.
	return Mind


/mob/living/carbon/human/proc/equip_space_ninja(safety=0)//Safety in case you need to unequip stuff for existing characters.
	if(safety)
		qdel(w_uniform)
		qdel(wear_suit)
		qdel(wear_mask)
		qdel(head)
		qdel(shoes)
		qdel(gloves)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	var/obj/item/clothing/suit/space/space_ninja/theSuit = new(src)
	var/obj/item/weapon/katana/energy/EK = new(src)
	theSuit.energyKatana = EK

	equip_to_slot_or_del(R, slot_ears)
	equip_to_slot_or_del(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/space_ninja(src), slot_shoes)
	equip_to_slot_or_del(theSuit, slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/space_ninja(src), slot_gloves)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/space_ninja(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/voice/space_ninja(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/night(src), slot_glasses)
	equip_to_slot_or_del(EK, slot_belt)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/weapon/c4(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/weapon/tank/internals/emergency_oxygen(src), slot_s_store)
	equip_to_slot_or_del(new /obj/item/weapon/tank/jetpack/carbondioxide(src), slot_back)

	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive(src)
	E.implant(src)
	return 1
