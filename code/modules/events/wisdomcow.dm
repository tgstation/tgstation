/datum/round_event_control/wisdomcow
	name = "Wisdom Cow"
	typepath = /datum/round_event/wisdomcow
	max_occurrences = 1
	weight = 20
	category = EVENT_CATEGORY_FRIENDLY
	description = "A cow appears to tell you wise words."
	admin_setup = list(
		/datum/event_admin_setup/set_location/wisdom_cow,
		/datum/event_admin_setup/listed_options/wisdom_cow,
		/datum/event_admin_setup/input_number/wisdom_cow,
	)

/datum/round_event/wisdomcow
	///Admin set overide location for the cow.
	var/turf/admin_spawn_location
	///Admin set override for the wisdom the cow will grant.
	var/admin_selected_wisdom
	///Admin set override for the amount of experience the wisdom cow will grant or remove
	var/admin_selected_experience

/datum/round_event/wisdomcow/announce(fake)
	priority_announce("A wise cow has been spotted in the area. Be sure to ask for her advice.", "Nanotrasen Cow Ranching Agency")

/datum/round_event/wisdomcow/start()
	var/turf/targetloc
	if(admin_spawn_location)
		targetloc = admin_spawn_location
	else
		targetloc = get_safe_random_station_turf()
	var/mob/living/basic/cow/wisdom/wise = new(targetloc, admin_selected_wisdom, admin_selected_experience)
	do_smoke(1, holder = wise, location = targetloc)
	announce_to_ghosts(wise)

/datum/event_admin_setup/set_location/wisdom_cow
	input_text = "Spawn on current turf?"

/datum/event_admin_setup/set_location/wisdom_cow/apply_to_event(datum/round_event/wisdomcow/event)
	event.admin_spawn_location = chosen_turf

/datum/event_admin_setup/listed_options/wisdom_cow
	input_text = "Select a specific wisdom type?"
	normal_run_option = "Random Wisdom"

/datum/event_admin_setup/listed_options/wisdom_cow/get_list()
	return subtypesof(/datum/skill)

/datum/event_admin_setup/listed_options/wisdom_cow/apply_to_event(datum/round_event/wisdomcow/event)
	event.admin_selected_wisdom = chosen

/datum/event_admin_setup/input_number/wisdom_cow
	input_text = "How much experience should this cow grant."
	default_value = 500
	max_value = 2500
	min_value = -2500

/datum/event_admin_setup/input_number/wisdom_cow/apply_to_event(datum/round_event/wisdomcow/event)
	event.admin_selected_experience = chosen_value
	
	
