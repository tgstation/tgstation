/datum/game_mode
	var/list/datum/mind/syndicates = list()


/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	required_players = 6
	required_players_secret = 25 // 25 players - 5 players to be the nuke ops = 20 players remaining
	required_enemies = 5
	recommended_enemies = 5

	uplink_welcome = "Corporate Backed Uplink Console:"
	uplink_uses = 40

	var/obj/nuclear_uplink
	var/const/agents_possible = 5 //If we ever need more syndicate agents.
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level


/datum/game_mode/nuclear/announce()
	to_chat(world, "<B>The current game mode is - Nuclear Emergency!</B>")
	to_chat(world, "<B>A [syndicate_name()] Strike Force is approaching [station_name()]!</B>")
	to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!")

/datum/game_mode/nuclear/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0

	var/list/possible_syndicates = get_players_for_role(ROLE_OPERATIVE)
	var/agent_number = 0

	if(possible_syndicates.len < 1)
		return 0

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	var/n_players = num_players()
	if(agent_number > n_players)
		agent_number = n_players/2

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(possible_syndicates)
		syndicates += new_syndicate
		possible_syndicates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		synd_mind.special_role = "Syndicate"//So they actually have a special role/N
	return 1


/datum/game_mode/nuclear/pre_setup()
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_synd_icons()
	spawn(0)
		for(var/datum/mind/synd_mind in syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/image/I in synd_mind.current.client.images)
						if(I.icon_state == "synd")
							synd_mind.current.client.images -= I

		for(var/datum/mind/synd_mind in syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in syndicates)
						if(synd_mind_1.current)
							var/imageloc = synd_mind_1.current
							if(istype(synd_mind_1.current.loc,/obj/mecha))
								imageloc = synd_mind_1.current.loc
							var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "synd", layer = 13)
							synd_mind.current.client.images += I

/datum/game_mode/proc/update_synd_icons_added(datum/mind/synd_mind)
	if(!synd_mind)
		return 0
	spawn(0)
		for(var/datum/mind/synd in syndicates)
			if(synd.current)
				if(synd.current.client)
					var/imageloc = synd_mind.current
					if(istype(synd_mind.current.loc,/obj/mecha))
						imageloc = synd_mind.current.loc
					var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "synd", layer = 13)
					synd.current.client.images += I
			if(synd_mind.current)
				if(synd_mind.current.client)
					var/imageloc = synd_mind.current
					if(istype(synd_mind.current.loc,/obj/mecha))
						imageloc = synd_mind.current.loc
					var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "synd", layer = 13)
					synd_mind.current.client.images += I

		update_all_synd_icons()

/datum/game_mode/proc/update_synd_icons_removed(datum/mind/synd_mind)
	spawn(0)
		for(var/datum/mind/synd in syndicates)
			if(synd.current)
				if(synd.current.client)
					for(var/image/I in synd.current.client.images)
						if(I.icon_state == "synd" && ((I.loc == synd_mind.current) || (I.loc == synd_mind.current.loc)))
							//del(I)
							synd.current.client.images -= I

		if(synd_mind.current)
			if(synd_mind.current.client)
				for(var/image/I in synd_mind.current.client.images)
					if(I.icon_state == "synd")
						//del(I)
						synd_mind.current.client.images -= I
		update_all_synd_icons()

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()

	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			del(A)
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1

	for(var/datum/mind/synd_mind in syndicates)
		if(spawnpos > synd_spawn.len)
			spawnpos = 1
		synd_mind.current.loc = synd_spawn[spawnpos]

		forge_syndicate_objectives(synd_mind)
		greet_syndicate(synd_mind)
		equip_syndicate(synd_mind.current)

		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++
		update_synd_icons_added(synd_mind)

	update_all_synd_icons()

	if(uplinklocker)
		var/obj/structure/closet/C = new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)
		spawn(10) //gives time for the contents to spawn properly
			for(var/obj/item/thing in C)
				if(thing.hidden_uplink)
					nuclear_uplink = thing
					break
	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

	return ..()


/datum/game_mode/proc/prepare_syndicate_leader(var/datum/mind/synd_mind, var/nuke_code)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	spawn(1)
		NukeNameAssign(nukelastname(synd_mind.current),syndicates) //allows time for the rest of the syndies to be chosen
	synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
	if (nuke_code)
		synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
		to_chat(synd_mind.current, "The nuclear authorization code is: <B>[nuke_code]</B>")
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		if (ticker.mode.config_tag=="nuclear")
			P.loc = synd_mind.current.loc
		else
			var/mob/living/carbon/human/H = synd_mind.current
			P.loc = H.loc
			H.equip_to_slot_or_del(P, slot_r_store, 0)
			H.update_icons()

	else
		nuke_code = "code will be provided later"
	return


/datum/game_mode/proc/forge_syndicate_objectives(var/datum/mind/syndicate)
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/proc/greet_syndicate(var/datum/mind/syndicate, var/you_are=1)
	if (you_are)
		to_chat(syndicate.current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
	var/obj_count = 1
	for(var/datum/objective/objective in syndicate.objectives)
		to_chat(syndicate.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	to_chat(syndicate.current, sound('sound/voice/syndicate_intro.ogg'))
	return


/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob)
	var/radio_freq = SYND_FREQ
	var/tank_slot = slot_r_hand

	if(synd_mob.overeatduration) //We need to do this here and now, otherwise a lot of gear will fail to spawn
		to_chat(synd_mob, "<span class='notice'>Your intensive physical training to become a Nuclear Operative has paid off and made you fit again!</span>")
		synd_mob.overeatduration = 0 //Fat-B-Gone
		if(synd_mob.nutrition > 400) //We are also overeating nutriment-wise
			synd_mob.nutrition = 400 //Fix that
		//synd_mob.handle_chemicals_in_body() //Update now, don't wait for the next life.dm call
		synd_mob.mutations.Remove(M_FAT)
		synd_mob.update_mutantrace(0)
		synd_mob.update_mutations(0)
		synd_mob.update_inv_w_uniform(0)
		synd_mob.update_inv_wear_suit()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_to_slot_or_del(R, slot_ears)

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), slot_w_uniform)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(synd_mob), slot_shoes)
	if(!istype(synd_mob.species, /datum/species/plasmaman))
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/bulletproof(synd_mob), slot_wear_suit)
	else
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/space/plasmaman/nuclear(synd_mob), slot_wear_suit)
		synd_mob.equip_to_slot_or_del(new /obj/item/weapon/tank/plasma/plasmaman(synd_mob), slot_s_store)
		synd_mob.equip_or_collect(new /obj/item/clothing/mask/breath/(synd_mob), slot_wear_mask)
		synd_mob.internal = synd_mob.get_item_by_slot(slot_s_store)
		if (synd_mob.internals)
			synd_mob.internals.icon_state = "internal1"
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(synd_mob), slot_gloves)
	if(!istype(synd_mob.species, /datum/species/plasmaman))
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(synd_mob), slot_head)
	else
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/plasmaman/nuclear(synd_mob), slot_head)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/prescription(synd_mob), slot_glasses)//changed to prescription sunglasses so near-sighted players aren't screwed if there aren't any admins online
	if(istype(synd_mob.species, /datum/species/vox))
		synd_mob.equip_or_collect(new /obj/item/clothing/mask/breath/vox(synd_mob), slot_wear_mask)
		synd_mob.equip_to_slot_or_del(new/obj/item/weapon/tank/nitrogen(synd_mob), slot_r_hand)
		to_chat(synd_mob, "<span class='notice'>You are now running on nitrogen internals from the [slot_r_hand] in your right hand. Your species finds oxygen toxic, so you must breathe nitrogen (AKA N<sub>2</sub>) only.</span>")
		synd_mob.internal = synd_mob.get_item_by_slot(tank_slot)
		if (synd_mob.internals)
			synd_mob.internals.icon_state = "internal1"
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/card/id/syndicate(synd_mob), slot_wear_id)
	if(synd_mob.backbag == 2) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(synd_mob), slot_back)
	if(synd_mob.backbag == 3 || synd_mob.backbag == 4) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_sec(synd_mob), slot_back)
	//if(synd_mob.backbag == 4) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(synd_mob), slot_back)
	synd_mob.equip_to_slot_or_del(new /obj/item/ammo_storage/magazine/a12mm(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/ammo_storage/magazine/a12mm(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/cyanide(synd_mob), slot_in_backpack) // For those who hate fun
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/creatine(synd_mob), slot_in_backpack) // HOOOOOO HOOHOHOHOHOHO - N3X
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/c20r(synd_mob), slot_belt)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(synd_mob.back), slot_in_backpack)
	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive(synd_mob)
	E.imp_in = synd_mob
	E.implanted = 1
	synd_mob.update_icons()
	return 1


/datum/game_mode/nuclear/check_win()
	if (nukes_left == 0)
		return 1
	return ..()


/datum/game_mode/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in syndicates)
		if (!istype(operative_mind.current,/mob/living/carbon/human))
			if(operative_mind.current)
				if(operative_mind.current.stat!=2)
					return 0
	return 1


/datum/game_mode/nuclear/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(!is_type_in_list(disk_area, centcom_areas))
			disk_rescued = 0
			break
	var/crew_evacuated = (emergency_shuttle.location==2)
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

	if      (!disk_rescued &&  station_was_nuked &&          !syndies_didnt_escape)
		feedback_set_details("round_end_result","win - syndicate nuke")
		completion_text += "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>"
		completion_text += "<BR><B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"

	else if (!disk_rescued &&  station_was_nuked &&           syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		completion_text += "<FONT size = 3><B>Total Annihilation</B></FONT>"
		completion_text += "<BR><B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		completion_text += "<FONT size = 3><B>Crew Minor Victory</B></FONT>"
		completion_text += "<BR><B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station &&  syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		completion_text += "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>"
		completion_text += "<BR><B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if ( disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		completion_text += "<FONT size = 3><B>Crew Major Victory!</B></FONT>"
		completion_text += "<BR><B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>"

	else if ( disk_rescued                                        )
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		completion_text += "<FONT size = 3><B>Crew Major Victory</B></FONT>"
		completion_text += "<BR><B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk not secured")
		completion_text += "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		completion_text += "<BR><B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued                                         &&  crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		completion_text += "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		completion_text += "<BR><B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

	else if (!disk_rescued                                         && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		completion_text += "<FONT size = 3><B>Neutral Victory</B></FONT>"
		completion_text += "<BR><B>Round was mysteriously interrupted!</B>"

	..()
	return


/datum/game_mode/proc/auto_declare_completion_nuclear()
	var/text = ""
	if( syndicates.len || (ticker && istype(ticker.mode,/datum/game_mode/nuclear)) )
		var/icon/logo = icon('icons/mob/mob.dmi', "nuke-logo")
		end_icons += logo
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The syndicate operatives were:</B></FONT> <img src="logo_[tempstate].png">"}

		for(var/datum/mind/syndicate in syndicates)

			if(syndicate.current)
				var/icon/flat = getFlatIcon(syndicate.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[syndicate.key]</b> was <b>[syndicate.name]</b> ("}
				if(syndicate.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(syndicate.current.real_name != syndicate.name)
					text += " as [syndicate.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[syndicate.key]</b> was <b>[syndicate.name]</b> ("}
				text += "body destroyed"
			text += ")"
		var/obj/item/nuclear_uplink = src:nuclear_uplink
		if(nuclear_uplink && nuclear_uplink.hidden_uplink)
			if(nuclear_uplink.hidden_uplink.purchase_log.len)
				text += "<br><span class='sinister'>The tools used by the syndicate operatives were: "
				for(var/entry in nuclear_uplink.hidden_uplink.purchase_log)
					text += "<br>[entry]TC(s)"
				text += "</span>"
			else
				text += "<br><span class='sinister'>The nukeops were smooth operators this round (did not purchase any uplink items)</span>"
		text += "<BR><HR>"
	return text


/proc/nukelastname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(last_names)
	var/newname = copytext(sanitize(input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change",randomname)),1,MAX_NAME_LEN)

	if (!newname)
		newname = randomname

	else
		if (newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			to_chat(M, "That name is reserved.")
			return nukelastname(M)

	return newname

/proc/NukeNameAssign(var/lastname,var/list/syndicates)
	for(var/datum/mind/synd_mind in syndicates)
		switch(synd_mind.current.gender)
			if(MALE)
				synd_mind.name = "[pick(first_names_male)] [lastname]"
			if(FEMALE)
				synd_mind.name = "[pick(first_names_female)] [lastname]"
		synd_mind.current.real_name = synd_mind.name
	return
