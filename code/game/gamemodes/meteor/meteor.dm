/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/meteordelay = 2000
	var/nometeors = 0
	var/rampupdelta = 5
	required_players = 0

	announce_span = "danger"
	announce_text = "A major meteor shower is bombarding the station! The crew needs to evacuate or survive the onslaught."


/datum/game_mode/meteor/process()
	if(nometeors || meteordelay > world.time - round_start_time)
		return

	var/list/wavetype = meteors_normal
	var/meteorminutes = (world.time - round_start_time - meteordelay) / 10 / 60


	if (prob(meteorminutes))
		wavetype = meteors_threatening

	if (prob(meteorminutes/2))
		wavetype = meteors_catastrophic

	var/ramp_up_final = Clamp(round(meteorminutes/rampupdelta), 1, 10)

	spawn_meteors(ramp_up_final, wavetype)


/datum/game_mode/meteor/declare_completion()
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
		to_chat(world, "<span class='boldnotice'>The following survived the meteor storm</span>:[text]")
	else
		to_chat(world, "<span class='boldnotice'>Nobody survived the meteor storm!</span>")

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
