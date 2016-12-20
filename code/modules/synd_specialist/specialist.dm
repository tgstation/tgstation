//The syndicate elite
//I have no business making something this advanced


//Trying to keep it all in one file
/*----------------
     CLOTHING
----------------*/

/obj/item/clothing/suit/agent_coat//the coat
	name = "Trenchcoat"
	desc = "A fashionable black leather trenchcoat. Supposedly inconspicuous."
	allowed = /obj/item/weapon/gun //They can only carry guns in their coat
	icon_state = "hos"
	item_state = "greatcoat"
	slowdown = 0
	unacidable = 1
	armor = list(melee = 85, bullet = 70, laser = 70, energy = 0, bomb = 30, bio = 0, rad = 0)
	strip_delay = INFINITY//No, you can't have it

/obj/item/clothing/under/syndicate/agent_suit
	name = "Black Ops suit"
	desc = "Nanotrasen sure pissed off somebody important."
	strip_delay = INFINITY


/*----------------
    ABILITIES
----------------*/
/obj/effect/proc_holder/spell/proc/agent_check(var/mob/living/carbon/human/H)//shamelessly stolen from sling
	if(!H || !istype(H)) return
	if(H.dna.species.id == "agent") return 1
	if(!H.dna.species.id== "agent") usr << "You aren't augmented enough to do this."
	return 0
//Make gangs
/obj/effect/proc_holder/spell/targeted/gang //Opens a selected airlock
	name = "Recruit"
	desc = "Brainwashes a target using your augmented glare to start up a syndicate gang."
	panel = "Augmentation"
	charge_max = 500
	clothes_req = 0
	action_icon_state = "mech_overload_off"


/obj/effect/proc_holder/spell/targeted/gang/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		if(!ishuman(target))
			user << "<span class='warning'>You may only brainwash humans!</span>"
			revert_cast()
			return
		if(locate(/obj/item/weapon/implant/loyalty) in target)
			user << "<span class='warning'>[target]'s Nanotrasen microchip prevents brainwashing.</span>"
		if(target.stat)
			user << "<span class='warning'>[target] must be conscious!</span>"
			revert_cast()
			return
		var/mob/living/carbon/human/M = target
		user.visible_message("<span class='warning'><b>[user] locks [target] in their gaze!</b></span>")
		target.visible_message("<span class='danger'>[target] looks like they realized a revelation!</span>")
		if(in_range(target, user))
			target << "<span class='userdanger'>Your gaze is forcibly drawn into [user]'s augmented eyes and you are filled with hatred.</span>"
		else //Only alludes to the shadowling if the target is close by
			target << "<span class='userdanger'>You feel as though you need to stand up to Nanotrasen!</span>"
		target.Stun(2)
		M.silent += 2
		ticker.mode.add_gangster(target.mind,user.mind.gang_datum)

//Set gang objectives
//UHHHHH ??? HOW I DO THIS??

//Disguise itself (should only affect silicons and loyalty implanted)
//wew I don't even know how to do this

//Steal research from servers
//(we steal this from ninja code :^)

//Super strength
//Force doors, hit hard, etc.


/*----------------
     EVENT
----------------*/
/datum/round_event_control/agent
	name = "Syndicate Lawyer"
	typepath = /datum/round_event/agent
	max_occurrences = 1
	earliest_start = 25000 // 40 minutes

/datum/round_event/agent
	var/success_spawn = 0

	var/helping_station
	var/key
	var/spawn_loc

	var/mob/living/carbon/human/Agent

/datum/round_event/agent/kill()
	if(!success_spawn && control)
		control.occurrences--
	return ..()

/datum/round_event/agent/start()
	//selecting a spawn_loc
	if(!spawn_loc)
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/L in landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("agentspawn")
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
	var/datum/mind/Mind = create_agent_mind(key)
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
	Mind.store_memory("I am the pinnacle of corporate warfare. The crew is my weapon. (You can create gangs to propogate loyalty implants and serve as a distraction!)")
	Mind.store_memory("I will turn Nanotrasen's loyalty against them. (Most of your abilities only affect loyalty implanted people!)")

	//spawn the ninja and assign the candidate
	Agent = create_syndicate_agent(spawn_loc)
	Mind.transfer_to(Agent)



	if(Agent.mind != Mind)			//something has gone wrong!
		throw EXCEPTION("Agent created with incorrect mind")
		return

	Agent << sound('sound/effects/ninja_greeting.ogg') //THIS NEEDS TO BE CHANGED

	success_spawn = 1


//Creation procs
/proc/create_agent_mind(key)
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.assigned_role = "Syndicate Lawyer"
	Mind.special_role = "Syndicate Lawyer"
	ticker.mode.traitors |= Mind			//Adds them to current traitor list. Which is really the extra antagonist list.
	return Mind

/proc/create_syndicate_agent(spawn_loc)
	var/mob/living/carbon/human/new_agent = new(spawn_loc)
	var/datum/preferences/A = new()//Shameless copypaste
	A.real_name = "Unknown"
	A.copy_to(new_agent)
	var/datum/gang/G = new()
	var/new_agent/mind/gang_datum = G
	new_agent.mind.gang_datum.name = "Syndicate"
	new_agent.dna.update_dna_identity()
	new_agent.equip_syndicate_agent()
	return new_agent


/mob/living/carbon/human/proc/equip_syndicate_agent(safety=0)//Safety in case you need to unequip stuff for existing characters.
	if(safety)
		qdel(w_uniform)
		qdel(wear_suit)
		qdel(wear_mask)
		qdel(head)
		qdel(shoes)
		qdel(gloves)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	var/obj/item/clothing/suit/agent_coat/theSuit = new(src)
	var/obj/item/weapon/gun/projectile/automatic/gyropistol/P = new(src)

	equip_to_slot_or_del(R, slot_ears)
	equip_to_slot_or_del(new /obj/item/clothing/under/syndicate/agent_suit(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(src), slot_shoes)
	equip_to_slot_or_del(theSuit, slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), slot_gloves)
	equip_to_slot_or_del(P, slot_s_store)
	equip_to_slot_or_del(new /obj/item/weapon/c4(src), slot_l_store)

	var/obj/item/weapon/implant/adrenalin/E = new/obj/item/weapon/implant/adrenalin(src)
	E.implant(src)
	E.implant(src)
	E.implant(src)
	return 1
