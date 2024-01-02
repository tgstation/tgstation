/datum/map_template/shuttle/voidcrew
	name = "ships"
	prefix = "_maps/voidcrew/ships/"
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
	var/list/job_list = list()
	for(var/list/job_definition as anything in job_slots)
		var/initial_slots = job_definition["slots"]

		var/datum/outfit/job/job_outfit = job_definition["outfit"]
		var/job_path = initial(job_outfit.jobtype)
		var/datum/job/job_slot = new job_path

		job_slot.title = job_definition["name"]
		job_slot.officer = !!job_definition["officer"]
		job_slot.outfit = job_outfit
		job_slot.job_flags = JOB_CREW_MANIFEST|JOB_EQUIP_RANK|JOB_NEW_PLAYER_JOINABLE|JOB_CREW_MEMBER|JOB_ASSIGN_QUIRKS|JOB_CAN_BE_INTERN
		job_slot.supervisors = "\the [job_slots[1]["name"]]"
		if(faction_prefix != NEUTRAL_SHIP)
			job_slot.faction = faction_prefix

		job_list[job_slot] = initial_slots

	return job_list
