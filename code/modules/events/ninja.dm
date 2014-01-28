//Note to future generations: I didn't write this god-awful code I just ported it to the event system and tried to make it less moon-speaky.
//Don't judge me D; ~Carn

/datum/round_event_control/ninja
	name = "Space Ninja"
	typepath = /datum/round_event/ninja
	max_occurrences = 1

/datum/round_event/ninja
	var/success_spawn = 0

	var/helping_station
	var/key
	var/spawn_loc
	var/mission

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

	//We prepare the mind before we spawn the ninja mob, so we cannot simply do mob.key = key then modify the mind.
	//instead we make the mind and modify it, then make sure it is active and mind.transfer_to(mob)
	//alternatively we could do mob.mind = mind;mob.key=key
	var/datum/mind/Mind = create_ninja_mind(key)
	Mind.active = 1

	//generate objectives - You'll generally get 6 objectives (Ninja is meant to be hardmode!)
	if(mission)
		var/datum/objective/O = new /datum/objective(mission)
		O.owner = Mind
		Mind.objectives += O
	else
		if(helping_station)	//DS are the highest priority (if we're a helpful ninja)
			for(var/datum/mind/M in ticker.minds)
				if(M.current && M.current.stat != DEAD)
					if(M.special_role == "Death Commando")
						var/datum/objective/assassinate/O = new /datum/objective/assassinate()
						O.owner = Mind
						O.target = M
						O.explanation_text = "Slay \the [M.current.real_name], the Death Commando."
						Mind.objectives += O

		else				//Xenos are the highest priority (if we're not so helpful) Although this makes zero sense at all...
			for(var/mob/living/carbon/alien/humanoid/queen/Q in player_list)
				if(Q.mind && Q.stat != DEAD)
					var/datum/objective/assassinate/O = new /datum/objective/assassinate()
					O.owner = Mind
					O.target = Q.mind
					O.explanation_text = "Slay \the [Q.real_name]."
					Mind.objectives += O

		if(Mind.objectives.len < 4)	//not enough objectives still!
			var/list/possible_targets = list()
			for(var/datum/mind/M in ticker.minds)
				if(M.current && M.current.stat != DEAD)
					if(istype(M.current,/mob/living/carbon/human))
						if(M.special_role)
							possible_targets[M] = 0						//bad-guy
						else if(M.assigned_role in command_positions)
							possible_targets[M] = 1						//good-guy

			var/list/objectives = list(1,2,3,4)
			while(Mind.objectives.len < 4)	//still not enough objectives!
				switch(pick_n_take(objectives))
					if(1)	//research
						var/datum/objective/download/O = new /datum/objective/download()
						O.owner = Mind
						O.gen_amount_goal()
						Mind.objectives += O

					if(2)	//steal
						var/datum/objective/steal/O = new /datum/objective/steal()
						O.set_target(pick(O.possible_items_special))
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

	//Finally, add their RP-directive
	var/directive = generate_ninja_directive()
	O = new /datum/objective(directive)		//making it an objective so admins can reward the for completion
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
	Ninja.wear_suit:randomize_param()
	Ninja.internal = Ninja.s_store
	if(Ninja.internals)
		Ninja.internals.icon_state = "internal1"

	if(Ninja.mind != Mind)			//something has gone wrong!
		error("The ninja wasn't assigned the right mind. ;(")

	success_spawn = 1

/*
This proc will give the ninja a directive to follow. They are not obligated to do so but it's a fun roleplay reminder.
Making this random or semi-random will probably not work without it also being incredibly silly.
As such, it's hard-coded for now. No reason for it not to be, really.
*/
/datum/round_event/ninja/proc/generate_ninja_directive()
	switch(rand(1,13))
		if(1)	return "The Spider Clan must not be linked to this operation. Remain as hidden and covert as possible."
		if(2)	return "[station_name] is financed by an enemy of the Spider Clan. Cause as much structural damage as possible."
		if(3)	return "A wealthy animal rights activist has made a request we cannot refuse. Prioritize saving animal lives whenever possible."
		if(4)	return "The Spider Clan absolutely cannot be linked to this operation. Eliminate all witnesses using most extreme prejudice."
		if(5)	return "We are currently negotiating with Nanotrasen command. Prioritize saving human lives over ending them."
		if(6)	return "We are engaged in a legal dispute over [station_name]. If a laywer is present on board, force their cooperation in the matter."
		if(7)	return "A financial backer has made an offer we cannot refuse. Implicate Syndicate involvement in the operation."
		if(8)	return "Let no one question the mercy of the Spider Clan. Ensure the safety of all non-essential personnel you encounter."
		if(9)	return "A free agent has proposed a lucrative business deal. Implicate Nanotrasen involvement in the operation."
		if(10)	return "Our reputation is on the line. Harm as few civilians or innocents as possible."
		if(11)	return "Our honor is on the line. Utilize only honorable tactics when dealing with opponents."
		if(12)	return "We are currently negotiating with a Syndicate leader. Disguise assassinations as suicide or another natural cause."
		else	return "There are no special supplemental instructions at this time."




//=======//CURRENT GHOST VERB//=======//

/client/proc/send_space_ninja()
	set category = "Fun"
	set name = "Spawn Space Ninja"
	set desc = "Spawns a space ninja for when you need a teenager with attitude."
	set popup_menu = 0

	if(!holder)
		src << "Only administrators may use this command."
		return
	if(!ticker.mode)
		alert("The game hasn't started yet!")
		return
	if(alert("Are you sure you want to send in a space ninja?",,"Yes","No")=="No")
		return

	var/mission = copytext(sanitize(input(src, "Please specify which mission the space ninja shall undertake.", "Specify Mission", null) as text|null),1,MAX_MESSAGE_LEN)

	var/client/C = input("Pick character to spawn as the Space Ninja", "Key", "") as null|anything in clients
	if(!C)
		return

	var/datum/round_event/ninja/E = new /datum/round_event/ninja()
	E.key=C.key
	E.mission=mission

	message_admins("\blue [key_name_admin(key)] has spawned [key_name_admin(C.key)] as a Space Ninja.")
	log_admin("[key] used Spawn Space Ninja.")

	return







