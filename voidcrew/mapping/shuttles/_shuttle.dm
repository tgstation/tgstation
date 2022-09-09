/datum/map_template/shuttle/voidcrew
	name = "ships"
	prefix = "_maps/voidcrew/"
	port_id = "ship"

	///The prefix signifying the ship's faction
	var/faction_prefix = NEUTRAL_SHIP
	///Short name of the ship
	var/short_name
	///Cost of the ship
	var/cost = 1

	///List of job slots
	var/list/job_slots = list()

/datum/map_template/shuttle/voidcrew/New()
	. = ..()
	name = "[faction_prefix] [name]"
