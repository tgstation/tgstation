/**
 * CYBERSUN SIM
 */
/datum/lazy_template/deathmatch/cybersun_sim
	map_dir = "_maps/doppler/deathmatch"
	name = "Cybersun Training Simulator"
	max_players = 4
	allowed_loadouts = list(/datum/outfit/deathmatch_loadout/cybersun_sim)
	map_name = "cybersun_sim"
	key = "cybersun_sim"

// Cypberpunk 2577
/datum/lazy_template/deathmatch/mars
	map_dir = "_maps/doppler/deathmatch"
	name = "Marsian Railway Stop"
	desc = "A respectable small railway stop in the heart of a marsian city. Lots of implants and mods \
		about, so whatever you do, don't tell them Mister Moruga is in town."
	max_players = 12
	allowed_loadouts = list(
		/datum/outfit/deathmatch_loadout/cyberpunk/silverhands,
		/datum/outfit/deathmatch_loadout/cyberpunk/gorilla,
		/datum/outfit/deathmatch_loadout/cyberpunk/sandevistan,
		/datum/outfit/deathmatch_loadout/cyberpunk/psycho_hunter,
		/datum/outfit/deathmatch_loadout/cyberpunk/just_ken,
	)
	map_name = "mars"
	key = "mars"
