/datum/game_mode/changeling/everyone
	name = "everyone is the changeling"
	config_tag = "everychangeling"
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 0
	restricted_jobs = list()
	protected_jobs = list()

/datum/game_mode/changeling/everyone/announce()
	world << "<B>The current game mode is - Everyone is the Changeling!</B>"
	world << "<B>Due to a clerical error, literally every \"staff\" member on this station is actually a changeling. Life might be unexpectedly difficult!</B>"

/datum/game_mode/changeling/everyone/pre_setup()
	config.changeling_scaling_coeff = INFINITY + INFINITY
	..()