/datum/game_mode/nuclear
	name = "arching operation"
	config_tag = "nuclear"
	false_report_weight = 10
	required_players = 30 // 30 players - 3 players to be the nuke ops = 27 players remaining
	required_enemies = 2
	recommended_enemies = 10
	antag_flag = ROLE_OPERATIVE
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "The henchmen are here!\n\
	<span class='danger'>Henchmen</span>: Secure the nuclear authentication disk and use your nuke to destroy the station.\n\
	<span class='notice'>Crew</span>: Defend the nuclear authentication disk and ensure that it leaves with you on the emergency shuttle."

	var/const/agents_possible = 10 //If we ever need more syndicate agents.
	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/list/pre_nukeops = list()

	var/datum/team/nuclear/nuke_team

	var/operative_antag_datum_type = /datum/antagonist/nukeop
	var/leader_antag_datum_type = /datum/antagonist/nukeop/leader

/datum/game_mode/nuclear/pre_setup()
	var/n_agents = min(round(num_players() / 10), antag_candidates.len, agents_possible)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_nukeops += new_op
			new_op.assigned_role = "Henchmen"
			new_op.special_role = "Henchmen"
			log_game("[new_op.key] (ckey) has been selected as a henchmen")
		return TRUE
	else
		return FALSE
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()
	//Assign leader
	var/datum/mind/leader_mind = pre_nukeops[1]
	var/datum/antagonist/nukeop/L = leader_mind.add_antag_datum(leader_antag_datum_type)
	nuke_team = L.nuke_team
	//Assign the remaining operatives
	for(var/i = 2 to pre_nukeops.len)
		var/datum/mind/nuke_mind = pre_nukeops[i]
		nuke_mind.add_antag_datum(operative_antag_datum_type)
	return ..()

/datum/game_mode/nuclear/OnNukeExplosion(off_station)
	..()
	nukes_left--

/datum/game_mode/nuclear/check_win()
	if (nukes_left == 0)
		return TRUE
	return ..()

/datum/game_mode/proc/are_operatives_dead()
	for(var/datum/mind/operative_mind in get_antag_minds(/datum/antagonist/nukeop))
		if(ishuman(operative_mind.current) && (operative_mind.current.stat != DEAD))
			return FALSE
	return TRUE

/datum/game_mode/nuclear/check_finished() //to be called by SSticker
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if((SSshuttle.emergency.mode == SHUTTLE_ENDGAME) || station_was_nuked)
		return TRUE
	if(nuke_team.operatives_dead())
		var/obj/machinery/nuclearbomb/N
		pass(N)	//suppress unused warning
		if(N.bomb_set) //snaaaaaaaaaake! It's not over yet!
			return FALSE	//its a static var btw
	..()

/datum/game_mode/nuclear/set_round_result()
	..()
	var result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - monarch nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - monarch nuke"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - monarch nuke - did not evacuate in time"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/game_mode/nuclear/generate_report()
	return "One of Central Command's trading routes was recently disrupted by a raid carried out by the Monarch's henchmen. They seemed to only be after one ship - a highly-sensitive \
			transport containing a nuclear fission explosive, although it is useless without the proper code and authorization disk. While the code was likely found in minutes, the only disk that \
			can activate this explosive is on your station. Ensure that it is protected at all times, and remain alert for possible intruders."

/proc/is_nuclear_operative(mob/M)
	return M && istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/nukeop)

/datum/outfit/syndicate
	name = "Henchmen"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/galoshes
	gloves = /obj/item/clothing/gloves/color/yellow
	back = /obj/item/storage/backpack/henchmen
	ears = /obj/item/device/radio/headset/syndicate/alt
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	id = /obj/item/card/id/syndicate
	belt = /obj/item/gun/chem/henchmen
	backpack_contents = list(/obj/item/storage/box/syndie=1)

	var/tc = 25
	var/command_radio = FALSE
	var/uplink_type = /obj/item/device/radio/uplink/nuclear


/datum/outfit/syndicate/leader
	name = "Henchmen Leader"
	uniform = /obj/item/clothing/under/syndicate/henchmen_leader
	id = /obj/item/card/id/syndicate/nuke_leader
	r_hand = /obj/item/device/nuclear_challenge
	command_radio = TRUE

/datum/outfit/syndicate/no_crystals
	tc = 0

/datum/outfit/syndicate/post_equip(mob/living/carbon/human/H)
	var/obj/item/device/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE
	if(command_radio)
		R.command = TRUE

	if(tc)
		var/obj/item/device/radio/uplink/U = new uplink_type(H, H.key, tc)
		H.equip_to_slot_or_del(U, slot_in_backpack)

	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	H.faction |= ROLE_SYNDICATE
	H.update_icons()

/datum/outfit/syndicate/full
	name = "Syndicate Operative - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = slot_r_store
	belt = /obj/item/storage/belt/military
	r_hand = /obj/item/gun/ballistic/automatic/shotgun/bulldog
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/tank/jetpack/oxygen/harness=1,\
		/obj/item/gun/ballistic/automatic/pistol=1,\
		/obj/item/kitchen/knife/combat/survival)
