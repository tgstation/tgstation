/datum/mood_event/nanite_happiness
	description = "<span class='nicegreen robot'>+++++++HAPPINESS ENHANCEMENT+++++++</span>"
	mood_change = 7

/datum/mood_event/nanite_happiness/add_effects(message)
	description = "<span class='nicegreen robot'>+++++++[message]+++++++</span>"

/datum/mood_event/nanite_sadness
	description = "+++++++HAPPINESS SUPPRESSION+++++++</span>"
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = "<span class='warning robot'>+++++++[message]+++++++</span>"
