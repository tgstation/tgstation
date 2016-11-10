/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0

	announce_span = "notice"
	announce_text = "Just have fun and enjoy the game!"

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	..()

/datum/game_mode/extended/send_intercept(report = 0)
	priority_announce("Thanks to the tireless efforts of our security and intelligence divisions, there are currently no credible threats to [station_name()]. Have a secure shift!", "Central Command Update", 'sound/AI/commandreport.ogg')