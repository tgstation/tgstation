/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/const/meteordelay = 2000
	var/nometeors = 1

/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"

/datum/game_mode/meteor/post_setup()
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	spawn(meteordelay)
		nometeors = 0

/datum/game_mode/meteor/process()
	if (nometeors) return
	if (prob(10)) meteor_wave()
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
					if (istype(player.loc, /obj/machinery/vehicle/pod))
						survivors[player.real_name] = "pod"
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

/datum/game_mode/meteor/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(ticker.minds))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')