/datum/game_mode/nano
	name = "nano"
	config_tag = "nano"
	antag_flag = BE_NANO
	required_players = 15 //15
	required_enemies = 5 // 5
	var/delay = 30
	var/maxBots = 15
	var/list/nanobots = list()
	var/list/possibleNanos = list()
	var/spawned = FALSE


/datum/game_mode/nano/announce()
	world << "<B>The current game mode is - Nanopocolypse!</B>"
	world << "<B>A deadly swarm of nanobots has been released into the nearby atmosphere. Survive at all costs!</B>"


/datum/game_mode/nano/pre_setup()
	var/hivesToSpawn = 0
	if(num_players() <= required_players || required_players <= 0)
		hivesToSpawn = 1
	else
		hivesToSpawn = max(round(num_players()/required_players, 1), 1)

	for(var/j = 0, j < hivesToSpawn, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/nano = pick(antag_candidates)
		nano.special_role = "Nano"
		log_game("[nano.key] (ckey) has been selected as a Nano Overlord")
		possibleNanos += nano
		antag_candidates -= nano

	if(!hivesToSpawn)
		return 0

	return 1

/datum/game_mode/nano/post_setup()
	spawn(delay)
		spawnBots()
	..()

/datum/game_mode/nano/proc/createNano(var/datum/mind/nanom, var/turf/where)
	var/client/nano_client = null
	var/turf/location = where

	if(directory[ckey(nanom.key)])
		nano_client = directory[ckey(nanom.key)]
		if(nano_client && location)
			var/obj/structure/nanohive/nanohiveP/hive = new(location)
			nanobots += hive
			hive.create_hive(nano_client)
			possibleNanos -= nanom
			possibleNanos += hive.myCamera.mind

/datum/game_mode/nano/proc/spawnBots()
	var/list/LM = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "carpspawn" || L.name == "xeno_spawn" || L.name == "blobstart")
			LM += L

	for(var/datum/mind/N in possibleNanos)
		var/obj/effect/landmark/pos = pick(LM)
		LM -= pos
		createNano(N,get_turf(pos))
	for(var/obj/effect/landmark/L in LM)
		if(prob(35))
			if(nanobots.len < maxBots)
				nanobots += new /obj/structure/nanohive(get_turf(L))
	spawn(10)
		spawned = TRUE

/datum/game_mode/nano/process()
	..()
	if(spawned)
		for(var/obj/structure/nanohive/NS in nanobots)
			if(NS.health <= 0)
				nanobots -= NS
		if(nanobots.len <= 0)
			world << "<font size=6 color='red'><b>All hives have been destroyed, victory!</b></font>"
			ticker.force_ending = 1

/datum/game_mode/nano/declare_completion()
	var/text
	var/survivors = 0

	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			++survivors
			if(player.onCentcom())
				text += "<br><b><font size=2>[player.real_name] escaped to the safety of Centcom.</font></b>"
			else
				text += "<br><font size=1>[player.real_name] survived but is stranded in a hellish nano-topia.</font>"


	if(survivors)
		world << "<span class='boldnotice'>The following survived the Nanopocolypse</span>:[text]"
	else
		world << "<span class='boldnotice'>Nobody survived the Nanopocolypse!</span>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
