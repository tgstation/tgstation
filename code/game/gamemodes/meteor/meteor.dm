/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/const/meteordelay = 2000
	var/nometeors = 1
	required_players = 0


/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"


/datum/game_mode/meteor/post_setup()
	defer_powernet_rebuild = 2//Might help with the lag
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	spawn(meteordelay)
		nometeors = 0


/datum/game_mode/meteor/process()
	if(nometeors) return
	if(prob(80))
		spawn()
			dust_swarm("norm")
	else
		spawn()
			dust_swarm("strong")
	if(prob(10)) meteor_wave()
	else spawn_meteors()


/datum/game_mode/meteor/declare_completion()
	var/list/survivors = list()
	var/area/escape_zone = locate(/area/shuttle/escape/centcom)

	for(var/mob/living/player in world)
		if (player.client)
			if (player.stat != 2)
				var/turf/location = get_turf(player.loc)
				if (location in escape_zone)
					survivors[player.real_name] = "shuttle"
				else
					survivors[player.real_name] = "alive"

	if (survivors.len)
		world << "\blue <B>The following survived the meteor attack!</B>"
		for(var/survivor in survivors)
			var/condition = survivors[survivor]
			switch(condition)
				if("shuttle")
					world << "\t <B><FONT size = 2>[survivor] escaped on the shuttle!</FONT></B>"
				if("pod")
					world << "\t <FONT size = 2>[survivor] escaped on an escape pod!</FONT>"
				if("alive")
					world << "\t <FONT size = 1>[survivor] stayed alive. Whereabouts unknown.</FONT>"
	else
		world << "\blue <B>No one survived the meteor attack!</B>"

	..()
	return 1
