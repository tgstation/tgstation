/datum/round_event_control/meteor_wave/meaty
	name = "Meteor Wave: Meaty"
	typepath = /datum/round_event/meteor_wave/meaty
	weight = 2
	max_occurrences = 1

/datum/round_event/meteor_wave/meaty
	wave_name = "meaty"
	possible_waves = (list(
			"meaty" = 90,
			"meatball" = 10)) // Same chance as a catastrophic meteor wave if wave_name isn't set (10%).

/datum/round_event/meteor_wave/meaty/announce(fake)
	priority_announce("Meaty ores have been detected on collision course with the station.", "Oh crap, get the mop.",'sound/ai/meteors.ogg')

/datum/round_event_control/meteor_wave/meaty/meatball
	name = "Meteor Wave: Extra Meaty"
	typepath = /datum/round_event/meteor_wave/meaty/meatball
	weight = 1

/datum/round_event/meteor_wave/meaty/meatball
	wave_name = "meatball"