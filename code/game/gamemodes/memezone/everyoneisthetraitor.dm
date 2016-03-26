/datum/game_mode/traitor/everyone
	name = "everyone is the traitor"
	config_tag = "everytraitor"
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 0
	restricted_jobs = list()
	protected_jobs = list()
	traitors_possible = SPEED_OF_LIGHT_SQ
	num_modifier = 6000000000 // Six billion additional traitors

/datum/game_mode/traitor/everyone/announce()
	world << "<B>The current game mode is - Everyone is the Traitor!</B>"
	world << "<B>Due to a clerical error, literally every \"staff\" member on this station is actually a member of the syndicate. Oh well!</B>"

/datum/game_mode/traitor/everyone/pre_setup()
	config.traitor_scaling_coeff = SPEED_OF_LIGHT
	..()