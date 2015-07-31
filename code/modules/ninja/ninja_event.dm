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
		var/list/candidates = get_candidates(BE_NINJA)
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

	var/list/objectives = list(1,2,3,4)
	while(Mind.objectives.len < 6)	//still not enough objectives!
		switch(pick_n_take(objectives))
			if(1)	//research
				var/datum/objective/download/O = new /datum/objective/download()
				O.owner = Mind
				O.gen_amount_goal()
				Mind.objectives += O

			if(2)	//steal
				var/datum/objective/steal/special/O = new /datum/objective/steal/special()
				O.owner = Mind
				Mind.objectives += O

			if(3)	//protect/kill
				if(!possible_targets.len)	continue
				var/selected = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[selected]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(selected,selected+1)

				if(is_bad_guy ^ helping_station)			//kill (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/assassinate/O = new /datum/objective/assassinate()
					O.owner = Mind
					O.target = M
					O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
					Mind.objectives += O
				else										//protect
					var/datum/objective/protect/O = new /datum/objective/protect()
					O.owner = Mind
					O.target = M
					O.explanation_text = "Protect \the [M.current.real_name], the [M.assigned_role], from harm."
					Mind.objectives += O
			if(4)	//debrain/capture
				if(!possible_targets.len)	continue
				var/selected = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[selected]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(selected,selected+1)

				if(is_bad_guy ^ helping_station)			//debrain (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/debrain/O = new /datum/objective/debrain()
					O.owner = Mind
					O.target = M
					O.explanation_text = "Steal the brain of [M.current.real_name]."
					Mind.objectives += O
				else										//capture
					var/datum/objective/capture/O = new /datum/objective/capture()
					O.owner = Mind
					O.gen_amount_goal()
					Mind.objectives += O
			else
				break

	//Add a survival objective since it's usually broad enough for any round type.
	var/datum/objective/O = new /datum/objective/survive()
	O.owner = Mind
	Mind.objectives += O

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
	if(prob(50)) new_ninja.gender = "female"
	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.real_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	A.copy_to(new_ninja)
	ready_dna(new_ninja)
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
