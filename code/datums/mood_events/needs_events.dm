//nutrition
/datum/mood_event/fat
	description = "<span class='warning'><B>I'm so fat...</B></span>\n" //muh fatshaming
	mood_change = -4

/datum/mood_event/wellfed
	description = "<span class='nicegreen'>My belly feels round and full.</span>\n"
	mood_change = 6

/datum/mood_event/fed
	description = "<span class='nicegreen'>I have recently had some food.</span>\n"
	mood_change = 3

/datum/mood_event/hungry
	description = "<span class='warning'>I'm getting a bit hungry.</span>\n"
	mood_change = -8

/datum/mood_event/starving
	description = "<span class='boldwarning'>I'm starving!</span>\n"
	mood_change = -15

//Disgust
/datum/mood_event/gross
	description = "<span class='warning'>I saw something gross.</span>\n"
	mood_change = -2

/datum/mood_event/verygross
	description = "<span class='warning'>I think I'm going to puke...</span>\n"
	mood_change = -5

/datum/mood_event/disgusted
	description = "<span class='boldwarning'>Oh god that's disgusting...</span>\n"
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "<span class='warning'>You smell something horribly decayed inside this room.</span>\n"
	mood_change = -3

/datum/mood_event/disgust/nauseating_stench
	description = "<span class='warning'>The stench of rotting carcasses is unbearable!</span>\n"
	mood_change = -7

//Generic needs events
/datum/mood_event/favorite_food
	description = "<span class='nicegreen'>I really enjoyed eating that.</span>\n"
	mood_change = 3
	timeout = 2400

/datum/mood_event/gross_food
	description = "<span class='warning'>I really didn't like that food.</span>\n"
	mood_change = -2
	timeout = 2400

/datum/mood_event/disgusting_food
	description = "<span class='warning'>That food was disgusting!</span>\n"
	mood_change = -4
	timeout = 2400

/datum/mood_event/nice_shower
	description = "<span class='nicegreen'>I have recently had a nice shower.</span>\n"
	mood_change = 2
	timeout = 1800
