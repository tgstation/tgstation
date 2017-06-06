/datum/game_mode/extended
	name = "secret extended"
	config_tag = "secret extended"
	required_players = 0

	announce_span = "notice"
	announce_text = "Just have fun and enjoy the game!"

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	..()

/datum/game_mode/extended/announced
	name = "extended"
	config_tag = "extended"

/datum/game_mode/extended/announced/generate_station_goals()
	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = new T
		station_goals += G
		G.on_report()

/datum/game_mode/extended/announced/send_intercept(report = 0)
	var/intercepttext = "<b><i>Central Command Status Summary</i></b><hr>"
	intercepttext += "<b>Central Command has had no reports of hostile activity in your sector, and as such recommends that you find ways to keep the crew engaged. Please see your Special Orders below for one such idea.</b>"

	if(station_goals.len)
		intercepttext += "<hr><b>Special Orders for [station_name()]:</b>"
		for(var/datum/station_goal/G in station_goals)
			G.on_report()
			intercepttext += G.get_report()

	print_command_report(intercepttext, "Central Command Status Summary")
	priority_announce("A summary has been copied and printed to all communications consoles.", "Enemy communication intercepted. Security level elevated.", 'sound/AI/intercept.ogg')
	if(security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE) //Although theres no threat to the station, we want to avoid metagaming. Can always justify as Constant Vigilance etc.
