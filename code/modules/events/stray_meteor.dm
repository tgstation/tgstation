/datum/round_event_control/stray_meteor
	name = "Stray Meteor"
	typepath = /datum/round_event/stray_meteor
	weight = 15 //Number subject to change based on how often meteors actually collide with the station
	min_players = 15
	max_occurrences = 3
	earliest_start = 20 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "Throw a random meteor somewhere near the station."
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 7
	admin_setup = /datum/event_admin_setup/listed_options/stray_meteor
	map_flags = EVENT_SPACE_ONLY

/datum/round_event/stray_meteor
	announce_when = 1
	fakeable = FALSE //Already faked by meteors that miss
	///The selected meteor type if chosen through admin setup.
	var/chosen_meteor

/datum/round_event/stray_meteor/start()
	if(chosen_meteor)
		spawn_meteor(list(chosen_meteor = 1))
	else
		spawn_meteor(GLOB.meteors_stray)

/datum/round_event/stray_meteor/announce(fake)
	if(GLOB.meteor_list)
		var/obj/effect/meteor/detected_meteor = pick(GLOB.meteor_list) //If we accidentally pick a meteor not spawned by the event, we're still technically not wrong
		var/sensor_name = detected_meteor.signature
		priority_announce("Our [sensor_name] sensors have detected an incoming signature approaching [GLOB.station_name]. Please brace for impact.", "Meteor Alert")

/datum/event_admin_setup/listed_options/stray_meteor
	input_text = "Select a meteor type?"
	normal_run_option = "Random Meteor"

/datum/event_admin_setup/listed_options/stray_meteor/get_list()
	return subtypesof(/obj/effect/meteor)

/datum/event_admin_setup/listed_options/stray_meteor/apply_to_event(datum/round_event/stray_meteor/event)
	event.chosen_meteor = chosen
