/datum/round_event_control/stray_meteor
	name = "Stray Meteor"
	typepath = /datum/round_event/stray_meteor
	weight = 15 //Number subject to change based on how often meteors actually collide with the station
	min_players = 15
	max_occurrences = 3
	earliest_start = 20 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "Throw a random meteor somewhere near the station."
	///The selected meteor type if chosen through admin setup.
	var/obj/effect/meteor/chosen_meteor

/datum/round_event_control/stray_meteor/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/list/meteor_list = list()

	for(var/obj/effect/meteor/meteor_type in GLOB.meteors_normal)
		meteor_list += meteor_type

	chosen_meteor = tgui_input_list(usr, "Too lazy for buildmode?","Throw meteor", sort_names(meteor_list))

/datum/round_event/stray_meteor
	announceWhen = 1
	fakeable = FALSE //Already faked by meteors that miss

/datum/round_event/stray_meteor/start()
	var/datum/round_event_control/stray_meteor/meteor_event = control
	if(meteor_event.chosen_meteor)
		var/list/selection = list(meteor_event.chosen_meteor) //single-element list, because spawn_meteor needs to be passed a list
		priority_announce("[selection] selection list", "Meteor Alert")
		spawn_meteor(pick(selection))
		priority_announce("[pick(selection)] thrown with customization. [meteor_event.chosen_meteor] Please brace for impact.", "Meteor Alert")
	else
		spawn_meteor(GLOB.meteorsD)
		priority_announce("meteor thrown without customization. Please brace for impact.", "Meteor Alert")

/datum/round_event/stray_meteor/announce(fake)
	if(GLOB.meteor_list)
		var/obj/effect/meteor/detected_meteor = pick(GLOB.meteor_list) //If we accidentally pick a meteor not spawned by the event, we're still technically not wrong
		var/sensor_name = detected_meteor.signature
		priority_announce("Our [sensor_name] sensors have detected an incoming signature approaching [GLOB.station_name]. Please brace for impact.", "Meteor Alert")
