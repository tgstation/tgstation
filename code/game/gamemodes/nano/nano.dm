/datum/game_mode/nano
	name = "nano"
	config_tag = "nano"
	required_players = 15
	var/startDelay = 1500
	var/maxBots = 25
	var/list/nanobots = list()


/datum/game_mode/nano/announce()
	world << "<B>The current game mode is - Nanopocolypse!</B>"
	world << "<B>A deadly swarm of nanobots has been released into the nearby atmosphere. Survive at all costs!</B>"


/datum/game_mode/nano/post_setup()
	spawn(startDelay)
		spawnBots()

/datum/game_mode/nano/proc/spawnBots()
	for(var/obj/effect/landmark/A in landmarks_list)
		if(nanobots.len < maxBots)
			nanobots += new /mob/living/simple_animal/hostile/nanoswarm(get_turf(A))

/datum/game_mode/nano/process()
	for(var/mob/living/simple_animal/hostile/nanoswarm/NS in nanobots)
		if(NS.health <= 0)
			nanobots -= NS
	if(nanobots.len <= 0)
		spawnBots()


/datum/game_mode/nano/declare_completion()
	var/text
	var/survivors = 0

	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			++survivors
			if(player.onCentcom())
				text += "<br><b><font size=2>[player.real_name] escaped to the safety of Centcom.</font></b>"
			else
				text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"


	if(survivors)
		world << "<span class='boldnotice'>The following survived the Nanopocolypse</span>:[text]"
	else
		world << "<span class='boldnotice'>Nobody survived the Nanopocolypse!</span>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
