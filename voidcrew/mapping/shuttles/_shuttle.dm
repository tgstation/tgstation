/datum/map_template/shuttle/voidcrew
	name = "ships"
	prefix = "_maps/voidcrew/"
	port_id = "ship"

	///The prefix signifying the ship's faction
	var/faction_prefix = NEUTRAL_SHIP
	///Short name of the ship
	var/short_name
	///Cost of the ship
	var/part_cost = 1

	///List of job slots. Ensure the 'captain' is always the first entry
	var/list/job_slots = list()

	/// Ensures we dont try to spawn an abstract subtype
	var/abstract = /datum/map_template/shuttle/voidcrew

/datum/map_template/shuttle/voidcrew/New()
	. = ..()
	name = "[faction_prefix] [name]"

/datum/map_template/shuttle/voidcrew/proc/assemble_job_slots()
	. = list()
	for(var/list/job_definition as anything in job_slots)
		var/initial_slots = job_definition["slots"]
		var/job_outfit = job_definition["outfit"]
		var/datum/job/job_slot = new /datum/job
		job_slot.title = job_definition["name"]
		job_slot.officer = !!job_definition["officer"]
		job_slot.outfit = ispath(job_outfit) ? job_outfit :  text2path(job_outfit)
		if(faction_prefix != NEUTRAL_SHIP)
			job_slot.faction = faction_prefix
		job_slot.job_flags = JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_NEW_PLAYER_JOINABLE|JOB_CREW_MEMBER|JOB_ASSIGN_QUIRKS|JOB_CAN_BE_INTERN
		job_slot.supervisors = "\the [job_slots[1]["name"]]"
		.[job_slot] = initial_slots
