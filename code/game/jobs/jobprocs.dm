/proc/SetupOccupationsList()
	var/list/new_occupations = list()

	for(var/occupation in occupations)
		if (!(new_occupations.Find(occupation)))
			new_occupations[occupation] = 1
		else
			new_occupations[occupation] += 1

	occupations = new_occupations
	return

/proc/FindOccupationCandidates(list/unassigned, job, level)
	var/list/candidates = list()

	for (var/mob/new_player/player in unassigned)
		if (level == 1 && player.preferences.occupation1 == job && !jobban_isbanned(player, job))
			candidates += player

		if (level == 2 && player.preferences.occupation2 == job && !jobban_isbanned(player, job))
			candidates += player

		if (level == 3 && player.preferences.occupation3 == job && !jobban_isbanned(player, job))
			candidates += player

	return candidates

/proc/PickOccupationCandidate(list/candidates)
	if (candidates.len > 0)
		var/list/randomcandidates = shuffle(candidates)
		candidates -= randomcandidates[1]
		return randomcandidates[1]

	return null

/proc/DivideOccupations()
	var/list/unassigned = list()
	var/list/occupation_choices = occupations.Copy()
	var/list/occupation_eligible = occupations.Copy()
	occupation_choices = shuffle(occupation_choices)

	for (var/mob/new_player/player in world)
		if (player.client && player.ready && !player.mind.assigned_role)
			unassigned += player

			// If someone picked AI before it was disabled, or has a saved profile with it
			// on a game that now lacks it, this will make sure they don't become the AI,
			// by changing that choice to Captain.
			if (!config.allow_ai)
				if (player.preferences.occupation1 == "AI")
					player.preferences.occupation1 = "Captain"
				if (player.preferences.occupation2 == "AI")
					player.preferences.occupation2 = "Captain"
				if (player.preferences.occupation3 == "AI")
					player.preferences.occupation3 = "Captain"
			if (jobban_isbanned(player, player.preferences.occupation1))
				player.preferences.occupation1 = "Assistant"
			if (jobban_isbanned(player, player.preferences.occupation2))
				player.preferences.occupation2 = "Assistant"
			if (jobban_isbanned(player, player.preferences.occupation3))
				player.preferences.occupation3 = "Assistant"

	if (unassigned.len == 0)
		return 0

	var/mob/new_player/captain_choice = null

	for (var/level = 1 to 3)
		var/list/captains = FindOccupationCandidates(unassigned, "Captain", level)
		var/mob/new_player/candidate = PickOccupationCandidate(captains)

		if (candidate != null)
			captain_choice = candidate
			unassigned -= captain_choice
			break
	/*
	// Not forcing a Captain -- TLE
	if (captain_choice == null && unassigned.len > 0)
		unassigned = shuffle(unassigned)
		for(var/mob/new_player/player in unassigned)
			if(jobban_isbanned(player, "Captain"))
				continue
			else
				captain_choice = player
				break
		unassigned -= captain_choice
		*/




	if (captain_choice == null)
		world << "Captainship not forced on anyone."
	else
		captain_choice.mind.assigned_role = "Captain"

	//so that an AI is chosen during this game mode
	if(ticker.mode.name == "AI malfunction" && unassigned.len > 0)
		var/mob/new_player/ai_choice = null

		for (var/level = 1 to 3)
			var/list/ais = FindOccupationCandidates(unassigned, "AI", level)
			var/mob/new_player/candidate = PickOccupationCandidate(ais)

			if (candidate != null)
				ai_choice = candidate
				unassigned -= ai_choice
				break

		if (ai_choice == null && unassigned.len > 0)
			unassigned = shuffle(unassigned)
			for(var/mob/new_player/player in unassigned)
				if(jobban_isbanned(player, "AI"))
					continue
				else
					ai_choice = player
					break
			unassigned -= ai_choice

		if (ai_choice != null)
			ai_choice.mind.assigned_role = "AI"
		else
			world << "It is [ticker.mode.name] and there is no AI, someone should fix this"

	for (var/level = 1 to 3)
		if (unassigned.len == 0)	//everyone is assigned
			break

		for (var/occupation in assistant_occupations)
			if (unassigned.len == 0)
				break
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			for (var/mob/new_player/candidate in candidates)
				candidate.mind.assigned_role = occupation
				unassigned -= candidate

		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			if(ticker.mode.name == "AI malfunction" && occupation == "AI")
				continue
			var/eligible = occupation_eligible[occupation]
			if (eligible == 0)
				continue
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			var/eligiblechange = 0
			while (eligible--)
				var/mob/new_player/candidate = PickOccupationCandidate(candidates)
				if (candidate == null)
					break
				candidate.mind.assigned_role = occupation
				unassigned -= candidate
				eligiblechange++
			occupation_eligible[occupation] -= eligiblechange

	if (unassigned.len)
		unassigned = shuffle(unassigned)
		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			if(ticker.mode.name == "AI malfunction" && occupation == "AI")
				continue
			var/eligible = occupation_eligible[occupation]
			while (eligible-- && unassigned.len > 0)
				var/mob/new_player/candidate = unassigned[1]
				if (candidate == null)
					break
				candidate.mind.assigned_role = occupation
				unassigned -= candidate

	for (var/mob/new_player/player in unassigned)
		player.mind.assigned_role = pick(assistant_occupations)

	return 1

/mob/living/carbon/human/proc/Equip_Rank(rank, joined_late)
	/*if(joined_late && ticker.mode.name == "ctf")
		var/red_team
		var/green_team

		for(var/mob/living/carbon/human/M in world)
			if(M.client)
				if(M.client.team == "Red")
					red_team++
				if(M.client.team == "Green")
					green_team++

		if(!src.client.team)
			if(red_team > green_team)
				src.client.team = "Green"
			else
				src.client.team = "Red"


		src << "You are in the [src.client.team] Team!"
		var/obj/item/device/radio/headset/H = new /obj/item/device/radio/headset(src)
		src.equip_if_possible(H, slot_w_radio)
		if(src.client.team == "Red")
			H.set_frequency(1465)
			src.equip_if_possible(new /obj/item/clothing/under/color/red(src), src.slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/tdome/red(src), slot_wear_suit)
		else if(src.client.team == "Green")
			H.set_frequency(1449)
			src.equip_if_possible(new /obj/item/clothing/under/color/green(src), src.slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/tdome/green(src), slot_wear_suit)
		src.equip_if_possible(new /obj/item/clothing/shoes/black(src), src.slot_shoes)
		src.equip_if_possible(new /obj/item/clothing/mask/gas/emergency(src), src.slot_wear_mask)
		src.equip_if_possible(new /obj/item/clothing/gloves/swat(src), src.slot_gloves)

		src.equip_if_possible(new /obj/item/clothing/glasses/thermal(src), src.slot_glasses)

		var/obj/item/weapon/tank/air/O = new /obj/item/weapon/tank/air(src)
		src.equip_if_possible(O, src.slot_back)
		src.internal = O

		var/obj/item/weapon/card/id/W = new(src)
		W.name = "[src.real_name]'s ID card ([src.client.team] Team)"
		if(src.client.team == "Red")
			W.access = access_red
		else if(src.client.team == "Green")
			W.access = access_green
		else
			world << "Unspecified team, [src.client.team]"

		W.assignment = "[src.client.team] Team"
		W.registered = src.real_name
		src.equip_if_possible(W, src.slot_wear_id)

		return

	if(joined_late && ticker.mode.name == "deathmatch")
		src.equip_if_possible(new /obj/item/clothing/under/color/black(src), src.slot_w_uniform)
		src.equip_if_possible(new /obj/item/clothing/shoes/black(src), src.slot_shoes)
		src.equip_if_possible(new /obj/item/clothing/suit/swat_suit/death_commando(src), src.slot_wear_suit)
		src.equip_if_possible(new /obj/item/clothing/mask/gas/death_commando(src), src.slot_wear_mask)
		src.equip_if_possible(new /obj/item/clothing/gloves/swat(src), src.slot_gloves)
		src.equip_if_possible(new /obj/item/clothing/glasses/thermal(src), src.slot_glasses)
		src.equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle(src), src.slot_l_hand)
		src.equip_if_possible(new /obj/item/weapon/flashbang(src), src.slot_r_store)

		var/obj/item/weapon/tank/air/O = new /obj/item/weapon/tank/air(src)
		src.equip_if_possible(O, src.slot_back)
		src.internal = O

		var/randomname = "Killiam Shakespeare"
		if(commando_names.len)
			randomname = pick(commando_names)
			commando_names -= randomname
		var/newname = input(src,"You are a death commando. Would you like to change your name?", "Character Creation", randomname)
		if(!length(newname))
			newname = randomname
		newname = strip_html(newname,40)

		src.real_name = newname
		src.name = newname // there are WAY more things than this to change, I'm almost certain

		var/obj/item/weapon/card/id/W = new(src)
		W.name = "[newname]'s ID card (Death Commando)"
		W.access = get_all_accesses()
		W.assignment = "Death Commando"
		W.registered = newname
		src.equip_if_possible(W, src.slot_wear_id)
		return
	*/

	switch(rank)
		if ("Chaplain")
			src.equip_if_possible(new /obj/item/weapon/storage/bible(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/device/pda/chaplain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chaplain(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			if(prob(15))
				src.see_invisible = 15

		if ("Geneticist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)

		if ("Chemist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/toxins(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)

		if ("Janitor")
			src.equip_if_possible(new /obj/item/device/pda/janitor(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/janitor(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)

		if ("Clown")
			src.equip_if_possible(new /obj/item/device/pda/clown(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/clown(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/mask/clown_hat(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/banana(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/bikehorn(src), slot_in_backpack)
			src.mutations |= 16

		if ("Station Engineer")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/engineering(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/engineer(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/orange(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/t_scanner(src), slot_r_store)

		if ("Assistant")
			src.equip_if_possible(new /obj/item/clothing/under/color/grey(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)

		if ("Detective")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/security(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/det(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/det_hat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/fcard_kit(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/fcardholder(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/suit/det_suit(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/detective_scanner(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/zippo(src), slot_l_store)

		if ("Medical Doctor")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/medical(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_l_hand)

		if ("Captain")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_com (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/captain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/captain(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/captain(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/caphat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
//			src.equip_if_possible(new /obj/item/weapon/gun/energy/laser_gun(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)


		if ("Security Officer")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/security(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/color/red(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/weapon/storage/flashbang_kit(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/weapon/baton(src), slot_belt)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)


		if ("Scientist")
			src.equip_if_possible(new /obj/item/device/pda/toxins(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/scientist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
//			src.equip_if_possible(new /obj/item/clothing/suit/bio_suit(src), slot_wear_suit)
//			src.equip_if_possible(new /obj/item/clothing/head/bio_hood(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/mask/gas(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/tank/air(src), slot_l_hand)

		if ("Head of Security")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_security(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/HoS(src), slot_head)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
//			src.equip_if_possible(new /obj/item/weapon/gun/energy/laser_gun(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)


		if ("Head of Personnel")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_com (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_personnel(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
//			src.equip_if_possible(new /obj/item/weapon/gun/energy/laser_gun(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)


		if ("Atmospheric Technician")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)

		if ("Barman")
			src.equip_if_possible(new /obj/item/clothing/under/bartender(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)

		if ("Chef")
			src.equip_if_possible(new /obj/item/clothing/under/chef(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/chefhat(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/kitchen/rollingpin(src), slot_in_backpack)

		if ("Roboticist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/gloves/latex(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)

		if ("Botanist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/hydroponics(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/latex(src), slot_gloves)
			src.equip_if_possible(new /obj/item/device/analyzer/plant_analyzer(src), slot_l_hand)

		if ("Librarian")

			src.equip_if_possible(new /obj/item/clothing/under/suit_jacket/red(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/barcodescanner(src), slot_l_hand)

		if ("Quartermaster")
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/cargo(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/quartermaster(src), slot_belt)
			//src.equip_if_possible(new /obj/item/clothing/suit/exo_suit(src), slot_wear_suit)

		if ("Chief Engineer")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/glasses/meson(src), slot_glasses)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(src), slot_w_uniform)

		if ("Research Director")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_com (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/research_director(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/pen(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/weapon/clipboard(src), slot_r_hand)

		else
			src << "RUH ROH! Your job is [rank] and the game just can't handle it! Please report this bug to an administrator."

	src.equip_if_possible(new /obj/item/device/radio/headset(src), slot_ears)
	src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

	spawnId(rank)
	if(rank == "Captain")
		world << "<b>[src] is the captain!</b>"
	src << "<B>You are the [rank].</B>"
	src.job = rank
	src.mind.assigned_role = rank

	if (!joined_late && rank != "Tourist")
		var/obj/S = null
		for(var/obj/landmark/start/sloc in world)
			if (sloc.name != rank)
				continue
			if (locate(/mob) in sloc.loc)
				continue
			S = sloc
			break
		if (!S)
			S = locate("start*[rank]") // use old stype
		if (istype(S, /obj/landmark/start) && istype(S.loc, /turf))
			src.loc = S.loc
	else
		var/list/L = list()
		for(var/area/arrival/start/S in world)
			L += S
		if(L.len < 1) // Added this check to stop the empty list bug -- TLE
			return	 // **
		var/A = pick(L)
		var/list/NL = list()
		for(var/turf/T in A)
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					NL += T
		src.loc = pick(NL)
	return

/mob/living/carbon/human/proc/spawnId(rank)
	var/obj/item/weapon/card/id/C = null
	switch(rank)
		if("Captain")
			C = new /obj/item/weapon/card/id/gold(src)
		else
			C = new /obj/item/weapon/card/id(src)
	if(C)
		C.registered = src.real_name
		C.assignment = rank
		C.name = "[C.registered]'s ID Card ([C.assignment])"
		C.access = get_access(C.assignment)
		src.equip_if_possible(C, slot_wear_id)
	src.equip_if_possible(new /obj/item/weapon/pen(src), slot_r_store)
	//src.equip_if_possible(new /obj/item/device/radio/signaler(src), slot_belt)
	src.equip_if_possible(new /obj/item/device/pda(src), slot_belt)
	if (istype(src.belt, /obj/item/device/pda))
		src.belt:owner = src.real_name
		src.belt.name = "PDA-[src.real_name]"