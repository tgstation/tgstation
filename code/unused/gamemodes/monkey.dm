/datum/game_mode/monkey
	name = "monkey"
	config_tag = "monkey"

/datum/game_mode/monkey/announce()
	world << "<B>The current game mode is - Monkey!</B>"
	world << "<B>Some of your crew members have been infected by a mutageous virus!</B>"
	world << "<B>Escape on the shuttle but the humans have precedence!</B>"

/datum/game_mode/monkey/post_setup()
	spawn (50)
		var/list/players = list()
		for (var/mob/living/carbon/human/player in world)
			if (player.client)
				players += player

		if (players.len >= 3)
			var/amount = round((players.len - 1) / 3) + 1
			amount = min(4, amount)

			while (amount > 0)
				var/mob/living/carbon/human/player = pick(players)
				player.monkeyize()

				players -= player
				amount--

		for (var/mob/living/carbon/monkey/rabid_monkey in world)
			rabid_monkey.contract_disease(new /datum/disease/jungle_fever,0,0)

/datum/game_mode/monkey/check_finished()
	if(emergency_shuttle.location==2)
		return 1

	return 0

/datum/game_mode/monkey/declare_completion()
	var/area/escape_zone = locate(/area/shuttle/escape/centcom)

	var/monkeywin = 0
	for(var/mob/living/carbon/monkey/monkey_player in world)
		if (monkey_player.stat != 2)
			var/turf/location = get_turf(monkey_player.loc)
			if (location in escape_zone)
				monkeywin = 1
				break

	if(monkeywin)
		for(var/mob/living/carbon/human/human_player in world)
			if (human_player.stat != 2)
				var/turf/location = get_turf(human_player.loc)
				if (istype(human_player.loc, /turf))
					if (location in escape_zone)
						monkeywin = 0
						break

	if (monkeywin)
		world << "<FONT size = 3><B>The monkies have won!</B></FONT>"
		for(var/mob/living/carbon/monkey/monkey_player in world)
			if (monkey_player.client)
				world << "<B>[monkey_player.key] was a monkey.</B>"

	else
		world << "<FONT size = 3><B>The Research Staff has stopped the monkey invasion!</B></FONT>"
		for(var/mob/living/carbon/monkey/monkey_player in world)
			if (monkey_player.client)
				world << "<B>[monkey_player.key] was a monkey.</B>"

	return 1