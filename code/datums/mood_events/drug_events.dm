/datum/mood_event/drugs/high
	mood_change = 6

/datum/mood_event/drugs/high/add_effects(name)
	description = "<span class='greentext'>Woooow duudeeeeee...I'm tripping on this [name]</span>\n"

/datum/mood_event/drugs/smoked
	description = "<span class='green'>I have had a smoke recently.</span>\n"
	mood_change = 2

/datum/mood_event/drugs/overdose
	mood_change = -8
	timeout = 3000

/datum/mood_event/drugs/overdose/add_effects(name)
	description = "<span class='warning'>I think I took a bit too much of that [name]</span>\n"

/datum/mood_event/drugs/withdrawal_light
	mood_change = -2

/datum/mood_event/drugs/withdrawal_light/add_effects(name)
	description = "<span class='warning'>I could use some [name]</span>\n"

/datum/mood_event/drugs/withdrawal_medium
	mood_change = -5

/datum/mood_event/drugs/withdrawal_medium/add_effects(name)
	description = "<span class='warning'>I really need [name]</span>\n"

/datum/mood_event/drugs/withdrawal_severe
	mood_change = -7

/datum/mood_event/drugs/withdrawal_severe/add_effects(name)
	description = "<span class='boldwarning'>Oh god I need some [name]</span>\n"

/datum/mood_event/drugs/withdrawal_critical
	mood_change = -15

/datum/mood_event/drugs/withdrawal_critical/New(name)
	description = "<span class='boldwarning'>[name]! [name]! [name]!</span>\n"
