/datum/game_mode/traitor/changeling/everyone
	name = "everyone is the traitor and also the changeling"
	config_tag = "everytraitorling"
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 0
	protected_jobs = list()
	num_modifier = 6000000000 // Six billion additional traitors

/datum/game_mode/traitor/changeling/everyone/announce()
	world << "<B>The current game mode is - Everyone is the traitor and also the changeling!</B>"
	world << "<B>Once upon a time there was a station where every crew member was both a traitor and a changeling, this is the story of their deaths.</B>"

/datum/game_mode/traitor/changeling/everyone/pre_setup()
	config.traitor_scaling_coeff = CLUMSY * CLUMSY * CLUMSY * CLUMSY * CLUMSY
	config.changeling_scaling_coeff = config.traitor_scaling_coeff * R_MAXPERMISSION
	..()