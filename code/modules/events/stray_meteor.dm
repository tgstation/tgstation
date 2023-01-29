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
	var/chosen_meteor

/datum/round_event_control/stray_meteor/admin_setup()
	if(!check_rights(R_FUN))
		return ADMIN_CANCEL_EVENT

	if(tgui_alert(usr, "Select a meteor?", "Plasuable Deniability!", list("Yes", "No")) == "Yes")
		var/list/meteor_list = list()
		meteor_list += subtypesof(/obj/effect/meteor)
		chosen_meteor = tgui_input_list(usr, "Too lazy for buildmode?","Throw meteor", meteor_list)

/datum/round_event/stray_meteor
	announce_when = 1
	fakeable = FALSE //Already faked by meteors that miss

/datum/round_event/stray_meteor/start()
	var/datum/round_event_control/stray_meteor/meteor_event = control
	if(meteor_event.chosen_meteor)
		var/chosen_meteor = meteor_event.chosen_meteor
		meteor_event.chosen_meteor = null
		var/list/passed_meteor = list()
		passed_meteor[chosen_meteor] = 1
		spawn_meteor(passed_meteor)
	else
		spawn_meteor(GLOB.meteors_stray)

/datum/round_event/stray_meteor/announce(fake)
	if(GLOB.meteor_list)
		var/obj/effect/meteor/detected_meteor = pick(GLOB.meteor_list) //If we accidentally pick a meteor not spawned by the event, we're still technically not wrong
		var/sensor_name = detected_meteor.signature
		priority_announce("Our [sensor_name] sensors have detected an incoming signature approaching [GLOB.station_name]. Please brace for impact.", "Meteor Alert")
