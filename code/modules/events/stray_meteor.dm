/datum/round_event_control/stray_meteor
	name = "Stray Meteor"
	typepath = /datum/round_event/stray_meteor
	weight = 9 //Number subject to change based on how often meteors actually collide with the station
	min_players = 15
	max_occurrences = 3
	earliest_start = 20 MINUTES
	category = EVENT_CATEGORY_SPACE
	description = "Throw a random meteor somewhere near the station."

/datum/round_event/stray_meteor
	announceWhen = 1
	fakeable = FALSE //Already faked by meteors that miss
	var/sensor_name = "runtime"

/datum/round_event/stray_meteor/start()
	spawn_meteor(GLOB.meteorsD)

/datum/round_event/stray_meteor/announce(fake)
	if(GLOB.meteor_list)
		var/obj/effect/meteor/new_meteor = pick(GLOB.meteor_list) //If we accidentally pick a meteor not spawned by the event, we're still technically not wrong
		sensor_name = new_meteor.signature
		priority_announce("Our [sensor_name] sensors have detected an incoming signature approaching [GLOB.station_name]. Please brace for impact.", "Meteor Alert")
