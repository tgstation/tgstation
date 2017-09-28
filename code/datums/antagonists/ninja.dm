/datum/antagonist/ninja
	name = "Ninja"
	var/team
	var/helping_station = 0
	var/give_objectives = TRUE

/datum/antagonist/ninja/friendly
	helping_station = 1

/datum/antagonist/ninja/friendly/noobjective
	give_objectives = FALSE

/datum/antagonist/ninja/New(datum/mind/new_owner)
	if(new_owner && !ishuman(new_owner.current))//It's fine if we aren't passed a mind, but if we are, they have to be human.
		throw EXCEPTION("Only humans and/or humanoids may be ninja'ed")
	..(new_owner)

/datum/antagonist/ninja/randomAllegiance/New(datum/mind/new_owner)
	..(new_owner)
	helping_station = rand(0,1)

/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/H = owner.current, safety=0)//Safety in case you need to unequip stuff for existing characters.
	if(safety)
		qdel(H.w_uniform)
		qdel(H.wear_suit)
		qdel(H.wear_mask)
		qdel(H.head)
		qdel(H.shoes)
		qdel(H.gloves)

	var/obj/item/clothing/suit/space/space_ninja/theSuit = new(H)
	var/obj/item/dash/energy_katana/EK = new(H)
	theSuit.energyKatana = EK

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), slot_ears)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/space_ninja(H), slot_shoes)
	H.equip_to_slot_or_del(theSuit, slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/space_ninja(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/space_ninja(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/space_ninja(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(H), slot_glasses)
	H.equip_to_slot_or_del(EK, slot_belt)
	H.equip_to_slot_or_del(new /obj/item/grenade/plastic/x4(H), slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/tank/internals/emergency_oxygen(H), slot_s_store)
	H.equip_to_slot_or_del(new /obj/item/tank/jetpack/carbondioxide(H), slot_back)
	theSuit.randomize_param()

	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	return 1

/datum/antagonist/ninja/proc/addMemories()
	owner.store_memory("I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	owner.store_memory("Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	owner.store_memory("Officially, [helping_station?"Nanotrasen":"The Syndicate"] are my employer.")

/datum/antagonist/ninja/proc/addObjectives(quantity = 6)
	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				if(M.special_role)
					possible_targets[M] = 0						//bad-guy
				else if(M.assigned_role in GLOB.command_positions)
					possible_targets[M] = 1						//good-guy

	var/list/objectives = list(1,2,3,4)
	while(owner.objectives.len < quantity)
		switch(pick_n_take(objectives))
			if(1)	//research
				var/datum/objective/download/O = new /datum/objective/download()
				O.owner = owner
				O.gen_amount_goal()
				owner.objectives += O

			if(2)	//steal
				var/datum/objective/steal/special/O = new /datum/objective/steal/special()
				O.owner = owner
				owner.objectives += O

			if(3)	//protect/kill
				if(!possible_targets.len)	continue
				var/index = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[index]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(index,index+1)

				if(is_bad_guy ^ helping_station)			//kill (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/assassinate/O = new /datum/objective/assassinate()
					O.owner = owner
					O.target = M
					O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
					owner.objectives += O
				else										//protect
					var/datum/objective/protect/O = new /datum/objective/protect()
					O.owner = owner
					O.target = M
					O.explanation_text = "Protect \the [M.current.real_name], the [M.assigned_role], from harm."
					owner.objectives += O
			if(4)	//debrain/capture
				if(!possible_targets.len)	continue
				var/selected = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[selected]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(selected,selected+1)

				if(is_bad_guy ^ helping_station)			//debrain (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/debrain/O = new /datum/objective/debrain()
					O.owner = owner
					O.target = M
					O.explanation_text = "Steal the brain of [M.current.real_name]."
					owner.objectives += O
				else										//capture
					var/datum/objective/capture/O = new /datum/objective/capture()
					O.owner = owner
					O.gen_amount_goal()
					owner.objectives += O
			else
				break
	var/datum/objective/O = new /datum/objective/survive()
	O.owner = owner
	owner.objectives += O


/proc/remove_ninja(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/datum = L.mind.has_antag_datum(ANTAG_DATUM_NINJA)
	datum.on_removal()
	return TRUE

/proc/add_ninja(mob/living/carbon/human/H, type = ANTAG_DATUM_NINJA_RANDOM)
	if(!H || !H.mind)
		return FALSE
	return H.mind.add_antag_datum(type)

/proc/is_ninja(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_NINJA)


/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/effects/ninja_greeting.ogg'))
	to_chat(owner.current, "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	to_chat(owner.current, "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	to_chat(owner.current, "Officially, [helping_station?"Nanotrasen":"The Syndicate"] are my employer.")
	return

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		addObjectives()
	addMemories()
