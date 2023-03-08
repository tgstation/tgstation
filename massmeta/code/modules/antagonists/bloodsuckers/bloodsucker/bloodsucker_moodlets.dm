/datum/mood_event/drankblood
	description = "<span class='nicegreen'>I have fed greedly from that which nourishes me.</span>\n"
	mood_change = 10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = "<span class='boldwarning'>I drank the blood of a lesser creature. Disgusting.</span>\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = "<span class='boldwarning'>I drank dead blood. I am better than this.</span>\n"
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = "<span class='boldwarning'>I drank synthetic blood. What is wrong with me?</span>\n"
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = "<span class='boldwarning'>I fed off of a dead person. I feel... less human.</span>\n"
	mood_change = -15
	timeout = 10 MINUTES

/datum/mood_event/madevamp
	description = "<span class='boldwarning'>A mortal has reached an apotheosis- undeath- by my own hand.</span>\n"
	mood_change = 15
	timeout = 20 MINUTES

/datum/mood_event/coffinsleep
	description = "<span class='nicegreen'>I slept in a coffin during the day. I feel whole again.</span>\n"
	mood_change = 10
	timeout = 6 MINUTES

/datum/mood_event/daylight_1
	description = "<span class='boldwarning'>I slept poorly in a makeshift coffin during the day.</span>\n"
	mood_change = -3
	timeout = 6 MINUTES

/datum/mood_event/daylight_2
	description = "<span class='boldwarning'>I have been scorched by the unforgiving rays of the sun.</span>\n"
	mood_change = -6
	timeout = 6 MINUTES

///Candelabrum's mood event to non Bloodsucker/Vassals
/datum/mood_event/vampcandle
	description = "<span class='boldwarning'>Something is making your mind feel... loose.</span>\n"
	mood_change = -15
	timeout = 5 MINUTES

