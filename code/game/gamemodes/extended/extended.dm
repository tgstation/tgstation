/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

// Enable this and the below to have command reports in extended
//	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
//	var/const/waittime_h = 1800

/datum/game_mode/announce()
	world << "<B>The current game mode is - Extended Role-Playing!</B>"
	world << "<B>Just have fun and role-play!</B>"

/datum/game_mode/extended/pre_setup()
//	setup_sectors()
//	spawn_exporation_packs()
	return 1

// Enable this and the above to have command reports in extended
///datum/game_mode/extended/post_setup()
//		send_intercept()
//
//	..()