/datum/game_mode/rodmadness
	name = "rod madness"
	config_tag = "rodmadness"
	var/roddelay = 2000
	var/norods = 0
	var/num_rods_wave = 2
	var/rampupdelta = 1
	required_players = 0

/datum/game_mode/rodmadness/announce()
	world << "<B>The current game mode is - Rod Madness!</B>"
	world << "<B>The space station has been stuck in a major rod shower. You must escape from the station or at least live.</B>"


/datum/game_mode/rodmadness/process()
	if(norods || roddelay > world.time - round_start_time)
		return

	spawn_rods(num_rods_wave * rampupdelta)


/datum/game_mode/rodmadness/declare_completion()
	var/text
	var/survivors = 0

	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			++survivors

			if(player.onCentcom())
				text += "<br><b><font size=2>[player.real_name] escaped to the safety of Centcom.</font></b>"
			else if(player.onSyndieBase())
				text += "<br><b><font size=2>[player.real_name] escaped to the (relative) safety of Syndicate Space.</font></b>"
			else
				text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"


	if(survivors)
		world << "<span class='boldnotice'>The following survived the rod storm</span>:[text]"
	else
		world << "<span class='boldnotice'>Nobody survived the rod storm!</span>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1


/proc/spawn_rods(number = 2)
	for(var/i, i < number, i++)
		spawn_rod()

/proc/spawn_rod()
	var/startside = pick(cardinal)
	var/turf/startT = spaceDebrisStartLoc(startside, 1)
	var/turf/endT = spaceDebrisFinishLoc(startside, 1)
	new /obj/effect/immovablerod(startT, endT, FALSE)