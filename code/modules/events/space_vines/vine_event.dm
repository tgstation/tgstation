/datum/round_event_control/spacevine
	name = "Space Vines"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3
	min_players = 10
	category = EVENT_CATEGORY_ENTITIES
	description = "Kudzu begins to overtake the station. Might spawn man-traps."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event/spacevine
	fakeable = FALSE

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/spacevine/vine = new()

	for(var/area/station/hallway/area in GLOB.areas)
		for(var/turf/floor as anything in area.get_contained_turfs())
			if(floor.Enter(vine))
				turfs += floor

	qdel(vine)

	if(length(turfs)) //Pick a turf to spawn at if we can
		var/turf/floor = pick(turfs)
		new /datum/spacevine_controller(floor, list(pick(subtypesof(/datum/spacevine_mutation))), rand(50,100), rand(1,4), src) //spawn a controller at turf with randomized stats and a single random mutation
