/datum/map_template/shuttle/voidcrew
	name = "ships"
	prefix = "_maps/voidcrew"

	///The prefix signifying the ship's faction
	var/faction_prefix = "NEU"
	///Short name of the ship
	var/short_name
	///Amount of ships able to be active at once
	var/limit
	///Cost (in metacoins) of the ship
	var/cost = 1
	///The antag datum to give a player on join
	var/antag_datum

	///List of job slots
	var/list/job_slots = list()

/datum/map_template/shuttle/voidcrew/New()
	. = ..()
	name = "[faction_prefix] [name]"
