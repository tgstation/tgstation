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

	/*
	if(rank=="Clown")
		if(alert("Do you want to be a clown or a mime?",,"Clown","Mime")=="Mime")
			rank="Mime" //Why no work -- Urist
	*/

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
			var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible/booze(src)
			src.equip_if_possible(B, slot_l_hand)
			src.equip_if_possible(new /obj/item/device/pda/chaplain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chaplain(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			//if(prob(15))
			//	src.see_invisible = 15 -- Doesn't work as see_invisible is reset every world cycle. -- Skie
			//The two procs below allow the Chaplain to choose their religion. All it really does is change their bible.
			spawn(0)
				var/religion_name = "Imperium"
				var/new_religion = input(src, "You are the Chaplain. Would you like to change your religion? Default is the Imperial Cult.", "Name change", religion_name)

				if ((length(new_religion) == 0) || (new_religion == "Imperium"))
					new_religion = religion_name

				if (new_religion)
					if (length(new_religion) >= 26)
						new_religion = copytext(new_religion, 1, 26)
					new_religion = dd_replacetext(new_religion, ">", "'")
					if(new_religion == "Imperium")
						B.name = "Uplifting Primer"
					else
						B.name = "The Holy Book of [new_religion]"

			spawn(1)
				var/deity_name = "Emperor"
				var/new_deity = input(src, "Would you like to change your deity? Default is the God Emperor of Mankind.", "Name change", deity_name)

				if ( (length(new_deity) == 0) || (new_deity == "God Emperor of Mankind") )
					new_deity = deity_name

				if(new_deity)
					if (length(new_deity) >= 26)
						new_deity = copytext(new_deity, 1, 26)
						new_deity = dd_replacetext(new_deity, ">", "'")
				B.deity_name = new_deity

		if ("Geneticist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_r_store)

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
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/clown (src), slot_back)
			src.equip_if_possible(new /obj/item/device/pda/clown(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/clown(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/banana(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/bikehorn(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/stamp/clown(src), slot_in_backpack)
			src.mutations |= 16

		if ("Mime")
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/device/pda/mime(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/mime(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/white(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/mask/mime(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/clothing/head/beret(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/suit/suspenders(src), slot_wear_suit)
			src.verbs += /client/proc/mimespeak
			src.verbs += /client/proc/mimewall
			src.mind.special_verbs += /client/proc/mimespeak
			src.mind.special_verbs += /client/proc/mimewall
			src.miming = 1

		if ("Station Engineer")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/engineering(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/engineer(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/orange(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves)
			src.equip_if_possible(new /obj/item/device/t_scanner(src), slot_r_store)

		if ("Shaft Miner")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_mine (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/under/rank/miner(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/satchel(src), slot_in_backpack)

		if ("Assistant")
			src.equip_if_possible(new /obj/item/clothing/under/color/grey(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)

		if ("Detective")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
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
			src.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/candy_corn(src), slot_h_store)

		if ("Medical Doctor")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/under/rank/medical(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_r_store)

		if ("Captain")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/captain (src), slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/device/pda/captain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/captain(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/captain(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/caphat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)


		if ("Security Officer")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security (src), slot_back)
			src.equip_if_possible(new /obj/item/device/pda/security(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/color/red(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/weapon/storage/flashbang_kit(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/weapon/baton(src), slot_belt)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)

		if ("Warden")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security (src), slot_back)
			src.equip_if_possible(new /obj/item/device/pda/security(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/warden(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
			src.equip_if_possible(new /obj/item/clothing/mask/gas/emergency(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/gun/energy/general(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/flashbang_kit(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)

		if ("Scientist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sci (src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/toxins(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/scientist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/mask/gas(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/tank/air(src), slot_l_hand)

		if ("Head of Security")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/hos (src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_security(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/hos(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/HoS(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security (src), slot_back)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
//			src.equip_if_possible(new /obj/item/weapon/gun/energy/laser_gun(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)


		if ("Head of Personnel")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/hop (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_personnel(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/storage/id_kit(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)


		if ("Atmospheric Technician")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)

		if ("Barman")
			src.equip_if_possible(new /obj/item/clothing/under/rank/bartender(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/weapon/ammo/shell/beanbag(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/ammo/shell/beanbag(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/ammo/shell/beanbag(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/ammo/shell/beanbag(src), slot_in_backpack)

		if ("Chef")
			src.equip_if_possible(new /obj/item/clothing/under/rank/chef(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/chefhat(src), slot_head)
//			src.equip_if_possible(new /obj/item/weapon/kitchen/rollingpin(src), slot_in_backpack) // it's in his office

		if ("Roboticist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_rob (src), slot_ears) // -- DH
			src.equip_if_possible(new /obj/item/device/pda/engineering(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/roboticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)

		if ("Botanist")
			src.equip_if_possible(new /obj/item/clothing/under/rank/hydroponics(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/botanic_leather(src), slot_gloves)
			src.equip_if_possible(new /obj/item/device/analyzer/plant_analyzer(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/clothing/suit/apron(src), slot_wear_suit)

		if ("Librarian")

			src.equip_if_possible(new /obj/item/clothing/under/suit_jacket/red(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/barcodescanner(src), slot_l_hand)

		if ("Lawyer")  //muskets 160910
			src.equip_if_possible(new /obj/item/clothing/under/lawyer/blue(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/device/detective_scanner(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/briefcase(src), slot_l_hand)

		if ("Quartermaster")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/qm (src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/cargo(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/quartermaster(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
			src.equip_if_possible(new /obj/item/weapon/clipboard(src), slot_l_hand)

		if ("Cargo Technician")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_cargo(src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/cargo(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/quartermaster(src), slot_belt)

		if ("Mail Sorter")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_cargo(src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/cargo(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/quartermaster(src), slot_belt)

		if ("Chief Engineer")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/ce (src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/glasses/meson(src), slot_glasses)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(src), slot_w_uniform)

		if ("Research Director")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/rd (src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/heads(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/research_director(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/pen(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/weapon/clipboard(src), slot_r_hand)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_r_store)

		if ("Chief Medical Officer")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/cmo (src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/medical(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat/cmo(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_r_store)

		if ("Virologist")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med (src), slot_ears) // -- TLE
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic (src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/under/rank/medical(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/flashlight/pen(src), slot_r_store)

		if ("Cyborg")
			Robotize()

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

	/*
	spawn(10)
		var/obj/item/weapon/camera_test/CT = new/obj/item/weapon/camera_test(src.loc)
		CT.afterattack(src, src, 10)
		var/obj/item/weapon/photo/PH
		PH = locate(/obj/item/weapon/photo,src.loc)
		if(PH)
			PH.layer = 3
			src.equip_if_possible(PH, slot_in_backpack)
		del(CT)*/ //--For another day - errorage
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
		var/obj/item/device/pda/pda = src.belt
		pda.owner = src.real_name
		pda.ownjob = src.wear_id.assignment
		pda.name = "PDA-[src.real_name] ([pda.ownjob])"
/*
	if (istype(src.r_store, /obj/item/device/pda))  //damned mime PDAs not starting in belt slot
		var/obj/item/device/pda/pda = src.r_store
		pda.owner = src.real_name
		pda.ownjob = src.wear_id.assignment
		pda.name = "PDA-[src.real_name] ([pda.ownjob])"
*/
	if (rank == "Clown")
		spawn clname(src)

/client/proc/mimewall()
	set category = "Mime"
	set name = "Invisible wall"
	set desc = "Create an invisible wall on your location."
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(!usr.miming)
		usr << "You still haven't atoned for your speaking transgression. Wait."
		return
	usr.verbs -= /client/proc/mimewall
	spawn(100)
		usr.verbs += /client/proc/mimewall
	for (var/mob/V in viewers(usr))
		if(V!=usr)
			V.show_message("[usr] looks as if a wall is in front of them.", 3, "", 2)
	usr << "You form a wall in front of yourself."
	var/obj/forcefield/F =  new /obj/forcefield(locate(usr.x,usr.y,usr.z))
	F.icon_state = "empty"
	F.name = "invisible wall"
	F.desc = "You have a bad feeling about this."
	spawn (300)
		del (F)
	return

/client/proc/mimespeak()
	set category = "Mime"
	set name = "Speech"
	set desc = "Toggle your speech."
	if(usr.miming)
		usr.miming = 0
	else
		usr << "You'll have to wait if you want to atone for your sins."
		spawn(3000)
			usr.miming = 1
	return