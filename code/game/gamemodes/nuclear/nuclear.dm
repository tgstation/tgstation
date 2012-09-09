/datum/game_mode
	var/list/datum/mind/syndicates = list()


/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	required_players = 20 // 20 players - 5 players to be the nuke ops = 15 players remaining
	required_enemies = 5
	recommended_enemies = 5

	uplink_welcome = "Corporate Backed Uplink Console:"
	uplink_uses = 40

	var/const/agents_possible = 5 //If we ever need more syndicate agents.
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/herp = 0 //Used for tracking if the syndies got the shuttle off of the z-level
	//It is so hillarious so I wont rename those two variables --rastaf0


/datum/game_mode/nuclear/announce()
	world << "<B>The current game mode is - Nuclear Emergency!</B>"
	world << "<B>A [syndicate_name()] Strike Force is approaching [station_name()]!</B>"
	world << "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!"

/datum/game_mode/nuclear/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0

	var/list/possible_syndicates = get_players_for_role(BE_OPERATIVE)
	var/agent_number = 0

	syndicate_begin()

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
							del(I)

		for(var/datum/mind/synd_mind in syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

/datum/game_mode/proc/update_synd_icons_added(datum/mind/synd_mind)
	spawn(0)
		if(synd_mind.current)
			if(synd_mind.current.client)
				var/I = image('icons/mob/mob.dmi', loc = synd_mind.current, icon_state = "synd")
				synd_mind.current.client.images += I

/datum/game_mode/proc/update_synd_icons_removed(datum/mind/synd_mind)
	spawn(0)
		for(var/datum/mind/synd in syndicates)
			if(synd.current)
				if(synd.current.client)
					for(var/image/I in synd.current.client.images)
						if(I.icon_state == "synd" && I.loc == synd_mind.current)
							del(I)

		if(synd_mind.current)
			if(synd_mind.current.client)
				for(var/image/I in synd_mind.current.client.images)
					if(I.icon_state == "synd")
						del(I)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()

	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if (A.name == "Syndicate-Gear-Closet")
			new /obj/structure/closet/syndicate/personal(A.loc)
			del(A)
			continue

		if (A.name == "Syndicate-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(A.loc)
			del(A)
			continue

		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			del(A)
			continue

	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
	var/obj/effect/landmark/closet_spawn = locate("landmark*Nuclear-Closet")

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

	if(nuke_spawn && synd_spawn.len > 0)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	if(closet_spawn)
		new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

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
		synd_mind.current << "The nuclear authorization code is: <B>[nuke_code]</B>"
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
	synd_mind.current << "Nuclear Explosives 101:\n\tHello and thank you for choosing the Syndicate for your nuclear information needs.\nToday's crash course will deal with the operation of a Fusion Class Nanotrasen made Nuclear Device.\nFirst and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.\nPressing any button on the compacted bomb will cause it to extend and bolt itself into place.\nIf this is done to unbolt it one must compeltely log in which at this time may not be possible.\nTo make the device functional:\n1. Place bomb in designated detonation zone\n2. Extend and anchor bomb (attack with hand).\n3. Insert Nuclear Auth. Disk into slot.\n4. Type numeric code into keypad ([nuke_code]).\n\tNote: If you make a mistake press R to reset the device.\n5. Press the E button to log onto the device\nYou now have activated the device. To deactivate the buttons at anytime for example when\nyou've already prepped the bomb for detonation remove the auth disk OR press the R ont he keypad.\nNow the bomb CAN ONLY be detonated using the timer. A manual det. is not an option.\n\tNote: Nanotrasen is a pain in the neck.\nToggle off the SAFETY.\n\tNote: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step\nSo use the - - and + + to set a det time between 5 seconds and 10 minutes.\nThen press the timer toggle button to start the countdown.\nNow remove the auth. disk so that the buttons deactivate.\n\tNote: THE BOMB IS STILL SET AND WILL DETONATE\nNow before you remove the disk if you need to move the bomb you can:\nToggle off the anchor, move it, and re-anchor.\n\nGood luck. Remember the order:\nDisk, Code, Safety, Timer, Disk, RUN!\nIntelligence Analysts believe that they are hiding the disk in the bridge. Your space ship will not leave until the bomb is armed and timing.\nGood luck!"
	return


/datum/game_mode/proc/forge_syndicate_objectives(var/datum/mind/syndicate)
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/proc/greet_syndicate(var/datum/mind/syndicate, var/you_are=1)
	if (you_are)
		syndicate.current << "\blue You are a [syndicate_name()] agent!"
	var/obj_count = 1
	for(var/datum/objective/objective in syndicate.objectives)
		syndicate.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob)
	var/radio_freq = SYND_FREQ

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_to_slot_or_del(R, slot_ears)

	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(synd_mob), slot_w_uniform)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(synd_mob), slot_shoes)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(synd_mob), slot_wear_suit)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(synd_mob), slot_gloves)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(synd_mob), slot_head)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/card/id/syndicate(synd_mob), slot_wear_id)
	if(synd_mob.backbag == 2) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(synd_mob), slot_back)
	if(synd_mob.backbag == 3) synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(synd_mob), slot_back)
	synd_mob.equip_to_slot_or_del(new /obj/item/ammo_magazine/a50(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/ammo_magazine/a50(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/pill/cyanide(synd_mob), slot_in_backpack)
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/deagle(synd_mob), slot_belt)
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
	//derp //Used for tracking if the syndies actually haul the nuke to the station
	//herp //Used for tracking if the syndies got the shuttle off of the z-level

	if      (!disk_rescued &&  station_was_nuked &&          !herp)
		feedback_set_details("round_end_result","win - syndicate nuke")
		world << "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"

	else if (!disk_rescued &&  station_was_nuked &&           herp)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		world << "<FONT size = 3><B>Total Annihilation</B></FONT>"
		world << "<B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !herp)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		world << "<FONT size = 3><B>Crew Minor Victory</B></FONT>"
		world << "<B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station &&  herp)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		world << "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>"
		world << "<B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if ( disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		world << "<FONT size = 3><B>Crew Major Victory!</B></FONT>"
		world << "<B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>"

	else if ( disk_rescued                                        )
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		world << "<FONT size = 3><B>Crew Major Victory</B></FONT>"
		world << "<B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk not secured")
		world << "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		world << "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued                                         &&  crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		world << "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

	else if (!disk_rescued                                         && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Round was mysteriously interrupted!</B>"

	..()
	return


/datum/game_mode/proc/auto_declare_completion_nuclear()
	if( syndicates.len || (ticker && istype(ticker.mode,/datum/game_mode/nuclear)) )
		var/text = "<FONT size = 2><B>The syndicate operatives were:</B></FONT>"

		for(var/datum/mind/syndicate in syndicates)

			text += "<br>[syndicate.key] was [syndicate.name] ("
			if(syndicate.current)
				if(syndicate.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(syndicate.current.real_name != syndicate.name)
					text += " as [syndicate.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		world << text
	return 1


/proc/nukelastname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(last_names)
	var/newname = copytext(sanitize(input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change",randomname)),1,MAX_NAME_LEN)

	if (!newname)
		newname = randomname

	else
		if (newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
			M << "That name is reserved."
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