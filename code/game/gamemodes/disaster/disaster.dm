/datum/game_mode/disaster
	name = "disaster"
	config_tag = "disaster"
	report_type = "disaster"
	false_report_weight = 0
	required_players = 0

	announce_span = "danger"
	announce_text = "Catastrophic disasters in-bound!"

var/finished = 0

/datum/game_mode/disaster/pre_setup()
	SSevents.scheduled = world.time + 5 MINUTES
	return 1

/datum/game_mode/disaster/generate_report()
	return "Several disasters are incoming. Evacuate to Lavaland and see to it that work continues. We can't lose money over a little space-weather! While you're at it, if you could kill of the most dangerous wildlife down there, we could arrange for your extraction. Just something to think about."

/datum/game_mode/disaster/announced/send_intercept(report = 0)
	priority_announce("Due to inclement space weather, all staff are to relocate their work to Lavaland. Hurry up!")

/datum/gamemode/disaster/check_win()
	if(check_tamed())
		finished = 1
	else if(check_massacre())
		finished = 2

/datum/gamemode/disaster/proc/check_tamed()
	if(locate(/mob/living/simple_animal/hostile/megafauna) in GLOB.alive_mob_list)
		return FALSE
	return TRUE

/datum/gamemode/disaster/proc/check_massacre()
	var/list/living_crew = list()

	for(var/mob/Player in GLOB.mob_list)
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) && !isbrain(Player) && Player.client)
			living_crew += Player
//	var/surivivingcrew = 25
	if(living_crew.len / GLOB.joined_player_list.len <= 25) //If a lot of the player base died, it's game over
		return TRUE

/datum/game_mode/disaster/set_round_result()
	..()
	if(finished == 1)
		SSticker.mode_result = "win - Lavaland tamed"
		SSticker.news_report = DISASTER_WIN
	else if(finished == 2)
		SSticker.mode_result = "loss - Massacred by Nature"
		SSticker.news_report = DISASTER_LOSE

/datum/game_mode/disaster/special_report()
	if(finished == 1)
		return "<span class='redtext big'>All of the megafauna have died! The crew wins!</span>"
	else if(finished == 2)
		return "<span class='redtext big'>Nature's fury has wiped out the crew.</span>"

