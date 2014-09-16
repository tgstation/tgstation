/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/meteordelay = 2000
	var/nometeors = 1
	required_players = 0


/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"


/datum/game_mode/meteor/post_setup()
//	defer_powernet_rebuild = 2//Might help with the lag
	spawn(meteordelay)
		nometeors = 0
	..()


/datum/game_mode/meteor/process()
	if(nometeors) return
	/*if(prob(80))
		spawn()
			dust_swarm("norm")
	else
		spawn()
			dust_swarm("strong")*/
	spawn() spawn_meteors(6)


/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if( /area/shuttle/escape/centcom )
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
				if( /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod4/centcom )
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
				else
					text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"
			survivors++

	if(survivors)
		world << "<span class='boldnotice'>The following survived the meteor storm</span>:[text]"
	else
		world << "<span class='boldnotice'>Nobody survived the meteor storm!</span>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
