/datum/game_mode
	var/list/datum/mind/syndicates = list()
<<<<<<< HEAD
	var/nukeops_lastname = ""
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
<<<<<<< HEAD
	required_players = 30 // 30 players - 3 players to be the nuke ops = 27 players remaining
	required_enemies = 2
	recommended_enemies = 5
	antag_flag = ROLE_OPERATIVE
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "Syndicate forces are approaching the station in an attempt to destroy it!\n\
	<span class='danger'>Operatives</span>: Secure the nuclear authentication disk and use your nuke to destroy the station.\n\
	<span class='notice'>Crew</span>: Defend the nuclear authentication disk and ensure that it leaves with you on the emergency shuttle."

	var/const/agents_possible = 5 //If we ever need more syndicate agents.
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level

<<<<<<< HEAD
/datum/game_mode/nuclear/pre_setup()
	var/n_players = num_players()
	var/n_agents = min(round(n_players / 10, 1), agents_possible)

	if(antag_candidates.len < n_agents) //In the case of having less candidates than the selected number of agents
		n_agents = antag_candidates.len

	while(n_agents > 0)
		var/datum/mind/new_syndicate = pick(antag_candidates)
		syndicates += new_syndicate
		antag_candidates -= new_syndicate //So it doesn't pick the same guy each time.
		n_agents--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "Syndicate"
		synd_mind.special_role = "Syndicate"//So they actually have a special role/N
		log_game("[synd_mind.key] (ckey) has been selected as a nuclear operative")

=======

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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
<<<<<<< HEAD
/datum/game_mode/proc/update_synd_icons_added(datum/mind/synd_mind)
	var/datum/atom_hud/antag/opshud = huds[ANTAG_HUD_OPS]
	opshud.join_hud(synd_mind.current)
	set_antag_hud(synd_mind.current, "synd")

/datum/game_mode/proc/update_synd_icons_removed(datum/mind/synd_mind)
	var/datum/atom_hud/antag/opshud = huds[ANTAG_HUD_OPS]
	opshud.leave_hud(synd_mind.current)
	set_antag_hud(synd_mind.current, null)
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()

	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
<<<<<<< HEAD
			continue

	var/nuke_code = random_nukecode()
=======
			qdel(A)
			A = null
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1

	for(var/datum/mind/synd_mind in syndicates)
		if(spawnpos > synd_spawn.len)
<<<<<<< HEAD
			spawnpos = 2
=======
			spawnpos = 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		synd_mind.current.loc = synd_spawn[spawnpos]

		forge_syndicate_objectives(synd_mind)
		greet_syndicate(synd_mind)
		equip_syndicate(synd_mind.current)

<<<<<<< HEAD
		if(nuke_code)
			synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
			synd_mind.current << "The nuclear authorization code is: <B>[nuke_code]</B>"

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++
		update_synd_icons_added(synd_mind)
<<<<<<< HEAD
	var/obj/machinery/nuclearbomb/nuke = locate("syndienuke") in nuke_list
	if(nuke)
		nuke.r_code = nuke_code
	return ..()


/datum/game_mode/proc/prepare_syndicate_leader(datum/mind/synd_mind, nuke_code)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	spawn(1)
		nukeops_lastname = nukelastname(synd_mind.current)
		NukeNameAssign(nukeops_lastname,syndicates) //allows time for the rest of the syndies to be chosen
	synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
	synd_mind.current << "<B>You are the Syndicate [leader_title] for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</B>"
	synd_mind.current << "<B>If you feel you are not up to this task, give your ID to another operative.</B>"
	synd_mind.current << "<B>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</B>"

	var/obj/item/device/nuclear_challenge/challenge = new /obj/item/device/nuclear_challenge
	synd_mind.current.equip_to_slot_or_del(challenge, slot_r_hand)

	var/list/foundIDs = synd_mind.current.search_contents_for(/obj/item/weapon/card/id)
	if(foundIDs.len)
		for(var/obj/item/weapon/card/id/ID in foundIDs)
			ID.name = "lead agent card"
			ID.access += access_syndicate_leader
	else
		message_admins("Warning: Nuke Ops spawned without access to leave their spawn area!")

	var/obj/item/device/radio/headset/syndicate/alt/A = locate() in synd_mind.current
	if(A)
		A.command = TRUE

	if(nuke_code)
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		var/mob/living/carbon/human/H = synd_mind.current
		P.loc = H.loc
		H.equip_to_slot_or_del(P, slot_r_hand, 0)
		H.update_icons()
=======

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
		if(!mixed) send_intercept()

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

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	else
		nuke_code = "code will be provided later"
	return


<<<<<<< HEAD

/datum/game_mode/proc/forge_syndicate_objectives(datum/mind/syndicate)
=======
/datum/game_mode/proc/forge_syndicate_objectives(var/datum/mind/syndicate)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


<<<<<<< HEAD
/datum/game_mode/proc/greet_syndicate(datum/mind/syndicate, you_are=1)
	if(you_are)
		syndicate.current << "<span class='notice'>You are a [syndicate_name()] agent!</span>"
	syndicate.announce_objectives()

/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob, telecrystals = TRUE)
	synd_mob.set_species(/datum/species/human) //Plasamen burn up otherwise, and lizards are vulnerable to asimov AIs

	if(telecrystals)
		synd_mob.equipOutfit(/datum/outfit/syndicate)
	else
		synd_mob.equipOutfit(/datum/outfit/syndicate/no_crystals)
=======
/datum/game_mode/proc/greet_syndicate(var/datum/mind/syndicate, var/you_are=1)
	if (you_are)
		to_chat(syndicate.current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
	var/obj_count = 1
	for(var/datum/objective/objective in syndicate.objectives)
		to_chat(syndicate.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	syndicate.current << sound('sound/voice/syndicate_intro.ogg')
	return


/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob)
	var/radio_freq = SYND_FREQ

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
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/tactical/swat(synd_mob), slot_head)
	else
		synd_mob.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/plasmaman/nuclear(synd_mob), slot_head)
	synd_mob.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/prescription(synd_mob), slot_glasses)//changed to prescription sunglasses so near-sighted players aren't screwed if there aren't any admins online
	if(istype(synd_mob.species, /datum/species/vox))
		synd_mob.equip_or_collect(new /obj/item/clothing/mask/breath/vox(synd_mob), slot_wear_mask)

		var/obj/item/weapon/tank/nitrogen/TN = new(synd_mob)
		synd_mob.put_in_hands(TN)
		to_chat(synd_mob, "<span class='notice'>You are now running on nitrogen internals from the [TN] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen (AKA N<sub>2</sub>) only.</span>")
		synd_mob.internal = TN

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
	synd_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival/engineer(synd_mob.back), slot_in_backpack)
	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive/nuclear(synd_mob)
	E.imp_in = synd_mob
	E.implanted = 1
	synd_mob.update_icons()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return 1


/datum/game_mode/nuclear/check_win()
	if (nukes_left == 0)
		return 1
	return ..()

<<<<<<< HEAD
/datum/game_mode/proc/are_operatives_dead()
	for(var/datum/mind/operative_mind in syndicates)
		if (istype(operative_mind.current,/mob/living/carbon/human) && (operative_mind.current.stat!=2))
			return 0
	return 1

/datum/game_mode/nuclear/check_finished() //to be called by ticker
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if((SSshuttle.emergency.mode == SHUTTLE_ENDGAME) || station_was_nuked)
		return 1
	if(are_operatives_dead())
		if(bomb_set) //snaaaaaaaaaake! It's not over yet!
			return 0
	..()

/datum/game_mode/nuclear/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in poi_list)
		if(!D.onCentcom())
			disk_rescued = 0
			break
	var/crew_evacuated = (SSshuttle.emergency.mode == SHUTTLE_ENDGAME)
=======

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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

<<<<<<< HEAD
	if      (!disk_rescued &&  station_was_nuked && !syndies_didnt_escape)
		feedback_set_details("round_end_result","win - syndicate nuke")
		world << "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"

	else if (!disk_rescued &&  station_was_nuked && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		world << "<FONT size = 3><B>Total Annihilation</B></FONT>"
		world << "<B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked && nuke_off_station && !syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		world << "<FONT size = 3><B>Crew Minor Victory</B></FONT>"
		world << "<B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked && nuke_off_station && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		world << "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>"
		world << "<B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if ((disk_rescued || SSshuttle.emergency.mode != SHUTTLE_ENDGAME) && are_operatives_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		world << "<FONT size = 3><B>Crew Major Victory!</B></FONT>"
		world << "<B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>"

	else if (disk_rescued)
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		world << "<FONT size = 3><B>Crew Major Victory</B></FONT>"
		world << "<B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued && are_operatives_dead())
		feedback_set_details("round_end_result","halfwin - evacuation - disk not secured")
		world << "<FONT size = 3><B>Neutral Victory!</B></FONT>"
		world << "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued &&  crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		world << "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Round was mysteriously interrupted!</B>"
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	..()
	return


/datum/game_mode/proc/auto_declare_completion_nuclear()
<<<<<<< HEAD
	if( syndicates.len || (ticker && istype(ticker.mode,/datum/game_mode/nuclear)) )
		var/text = "<br><FONT size=3><B>The syndicate operatives were:</B></FONT>"
		var/purchases = ""
		var/TC_uses = 0
		for(var/datum/mind/syndicate in syndicates)
			text += printplayer(syndicate)
			for(var/obj/item/device/uplink/H in uplinks)
				if(H && H.owner && H.owner == syndicate.key)
					TC_uses += H.spent_telecrystals
					purchases += H.purchase_log
		text += "<br>"
		text += "(Syndicates used [TC_uses] TC) [purchases]"
		if(TC_uses == 0 && station_was_nuked && !are_operatives_dead())
			text += "<BIG><IMG CLASS=icon SRC=\ref['icons/BadAss.dmi'] ICONSTATE='badass'></BIG>"
		world << text
	return 1


/proc/nukelastname(mob/M) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/randomname = pick(last_names)
	var/newname = copytext(sanitize(input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change",randomname)),1,MAX_NAME_LEN)

	if (!newname)
		newname = randomname

	else
		if (newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "rwall" || newname == "_")
<<<<<<< HEAD
			M << "That name is reserved."
			return nukelastname(M)

	return capitalize(newname)

/proc/NukeNameAssign(lastname,list/syndicates)
	for(var/datum/mind/synd_mind in syndicates)
		var/mob/living/carbon/human/H = synd_mind.current
		synd_mind.name = H.dna.species.random_name(H.gender,0,lastname)
		synd_mind.current.real_name = synd_mind.name
	return

/datum/outfit/syndicate
	name = "Syndicate Operative - Basic"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/weapon/storage/backpack
	ears = /obj/item/device/radio/headset/syndicate/alt
	l_pocket = /obj/item/weapon/pinpointer/syndicate
	id = /obj/item/weapon/card/id/syndicate
	belt = /obj/item/weapon/gun/projectile/automatic/pistol
	backpack_contents = list(/obj/item/weapon/storage/box/syndie=1)

	var/tc = 25

/datum/outfit/syndicate/no_crystals
	tc = 0


/datum/outfit/syndicate/post_equip(mob/living/carbon/human/H)
	var/obj/item/device/radio/R = H.ears
	R.set_frequency(SYND_FREQ)
	R.freqlock = 1

	if(tc)
		var/obj/item/device/radio/uplink/nuclear/U = new(H)
		U.hidden_uplink.owner = "[H.key]"
		U.hidden_uplink.telecrystals = tc
		H.equip_to_slot_or_del(U, slot_in_backpack)

	var/obj/item/weapon/implant/weapons_auth/W = new/obj/item/weapon/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/weapon/implant/explosive/E = new/obj/item/weapon/implant/explosive(H)
	E.implant(H)
	H.faction |= "syndicate"
	H.update_icons()

/datum/outfit/syndicate/full
	name = "Syndicate Operative - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	r_pocket = /obj/item/weapon/tank/internals/emergency_oxygen/engi
	belt = /obj/item/weapon/storage/belt/military
	r_hand = /obj/item/weapon/gun/projectile/automatic/shotgun/bulldog
	backpack_contents = list(/obj/item/weapon/storage/box/syndie=1,\
		/obj/item/weapon/tank/jetpack/oxygen/harness=1,\
		/obj/item/weapon/gun/projectile/automatic/pistol=1)

/datum/outfit/syndicate/full/post_equip(mob/living/carbon/human/H)
	..()


	var/obj/item/clothing/suit/space/hardsuit/syndi/suit = H.wear_suit
	suit.ToggleHelmet()

	H.internal = H.r_store
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
