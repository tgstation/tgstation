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
	admin_setup = list(/datum/event_admin_setup/set_location/spacevine, /datum/event_admin_setup/multiple_choice/spacevine)

/datum/round_event/spacevine
	fakeable = FALSE
	var/turf/override_turf
	var/list/override_mutations = list()

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas


	if(override_turf)
		turfs += override_turf
	else
		var/obj/structure/spacevine/vine = new()

		for(var/area/station/hallway/area in GLOB.areas)
			for(var/turf/floor as anything in area.get_contained_turfs())
				if(floor.Enter(vine))
					turfs += floor

		qdel(vine)

	if(length(turfs)) //Pick a turf to spawn at if we can
		var/turf/floor = pick(turfs)
		var/list/selected_mutations = list()

		if(override_mutations.len == 0)
			selected_mutations = list(pick(subtypesof(/datum/spacevine_mutation)))
		else
			selected_mutations = override_mutations

		new /datum/spacevine_controller(floor, selected_mutations, rand(50,100), rand(1,4), src) //spawn a controller at turf with randomized stats and a single random mutation

/datum/event_admin_setup/set_location/spacevine
	input_text = "Spawn vines at current location?"

/datum/event_admin_setup/set_location/spacevine/apply_to_event(datum/round_event/spacevine/event)
	event.override_turf = chosen_turf
	
/datum/event_admin_setup/multiple_choice/spacevine
	input_text = "Select starting mutations."

/datum/event_admin_setup/multiple_choice/spacevine/get_options()
	return subtypesof(/datum/spacevine_mutation/)

/datum/event_admin_setup/multiple_choice/spacevine/apply_to_event(datum/round_event/spacevine/event)
	var/list/type_choices = list()
	for(var/choice in choices)
		type_choices += text2path(choice)
	event.override_mutations = type_choices
	
