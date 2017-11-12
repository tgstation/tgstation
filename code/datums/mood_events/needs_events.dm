//nutrition
/datum/mood_event/nutrition/fat
	description = "<span class='warning'><B>I'm so fat..</B></span>\n" //muh fatshaming
	mood_change = -4

/datum/mood_event/nutrition/wellfed
	description = "<span class='green'><span class='green'>My belly feels round and full.</span>\n"
	mood_change = 4

/datum/mood_event/nutrition/fed
	description = "<span class='green'>I have recently had some food.</span>\n"
	mood_change = 2

/datum/mood_event/nutrition/hungry
	description = "<span class='warning'>I'm getting a bit hungry.</span>\n"
	mood_change = -6

/datum/mood_event/nutrition/starving
	description = "<span class='boldwarning'>I'm starving!</span>\n"
	mood_change = -12

//Disgust
/datum/mood_event/disgust/gross
	description = "<span class='warning'>I saw something gross.</span>\n"
	mood_change = -2

/datum/mood_event/disgust/verygross
	description = "<span class='warning'>I think I'm going to puke...</span>\n"
	mood_change = -5

/datum/mood_event/disgust/disgusted
	description = "<span class='boldwarning'>Oh god that's disgusting...</span>\n"
	mood_change = -8

//Generic needs events
/datum/mood_event/favorite_food
	description = "<span class='green'>I really enjoyed eating that.</span>\n"
	mood_change = 3
	timeout = 2400

/datum/mood_event/nice_shower
	description = "<span class='green'>I have recently had a nice shower.</span>\n"
	mood_change = 2
	timeout = 1800
