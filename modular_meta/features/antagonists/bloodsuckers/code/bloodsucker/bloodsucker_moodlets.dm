/datum/mood_event/drankblood
	description = span_nicegreen("I have fed greedly from that which nourishes me.")
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = span_boldwarning("I drank the blood of a lesser creature. Disgusting.")
	mood_change = -8
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = span_boldwarning("I drank blood from the dead. I am better than this.")
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = span_boldwarning("I drank synthetic blood. What is wrong with me?")
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = span_boldwarning("I fed off of someone until their death. I feel... less human.")
	mood_change = -20
	timeout = 15 MINUTES

/datum/mood_event/madevamp
	description = span_boldwarning("A mortal has reached an apotheosis— undeath— by my own hand.")
	mood_change = 15
	timeout = 10 MINUTES

/datum/mood_event/coffinsleep
	description = span_nicegreen("I slept in a coffin during the day. I feel whole again.")
	mood_change = 10
	timeout = 5 MINUTES

/datum/mood_event/daylight_1
	description = span_boldwarning("I slept poorly in a makeshift coffin during the day.")
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/daylight_2
	description = span_boldwarning("I have been scorched by the unforgiving rays of the sun.")
	mood_change = -7
	timeout = 5 MINUTES

///Candelabrum's mood event to non Bloodsucker/Vassals
/datum/mood_event/vampcandle
	description = span_boldwarning("Something is making your mind feel... loose.")
	mood_change = -15
	timeout = 5 MINUTES

//Blood mirror's mood event to non-bloodsuckers/vassals that attempt to use it and get randomly warped.
/datum/mood_event/bloodmirror
	description = span_boldwarning("A PROPHECY OF BLOOD HAS SPREAD ITS SPLATTERED STAINS UPON MY PSYCHE.")
	mood_change = -30
	timeout = 7 MINUTES
