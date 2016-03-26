/datum/game_mode/cleanbot
	name = "cleanbot"
	config_tag = "cleanbot"
	required_players = 0

/datum/game_mode/cleanbot/announce()
	world << "<B>The current game mode is - Cleanbot!</B>"
	world << "<B>The station is filty, clean it up! You have fifteen minutes!</B>"

/datum/game_mode/cleanbot/pre_setup()
	for(var/turf/simulated/floor/T in the_station_areas)
		T.MakeDirty()
		T.MakeDirty()
		T.MakeDirty()
		T.MakeDirty()
		T.MakeDirty()
	for(var/obj/machinery/door/airlock/W in machines)
		W.req_access = list()
	return 1

/datum/game_mode/cleanbot/post_setup()

	sleep(9000) //15 minutes of absolute clean
	declare_completion()

/datum/game_mode/cleanbot/declare_completion()
	var/mob/living/simple_animal/bot/cleanbot/the_winner
	for(var/mob/living/simple_animal/bot/cleanbot/cleanbot in player_list)
		if(!the_winner || cleanbot.things_cleaned > the_winner.things_cleaned)
			the_winner = cleanbot
	world << "<span class='redtext'>[the_winner.name] is the cleanesting cleanbot in cleantown with [the_winner.things_cleaned] things cleaned!!!</span><br>"
	for(var/mob/M in player_list) //only one way to really be sure it's clean
		M << 'sound/machines/Alarm.ogg'
	spawn(100)
		ticker.station_explosion_cinematic(1,"fake") //:o)
	ticker.force_ending = 1
	..()

/datum/game_mode/cleanbot/process()
	for(var/mob/living/carbon/not_cleanbot in player_list)
		var/mob/living/simple_animal/bot/cleanbot/cleanbot = new /mob/living/simple_animal/bot/cleanbot(not_cleanbot.loc)
		cleanbot.real_name = "[not_cleanbot] the cleanbot"
		cleanbot.name = cleanbot.real_name
		not_cleanbot.mind.transfer_to(cleanbot)
		cleanbot << "<span class='userdanger'>You are filled with an overwhelming desire... to clean!</span>"
		qdel(not_cleanbot)

