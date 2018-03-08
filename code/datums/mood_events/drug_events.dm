/datum/mood_event/drugs/high
	mood_change = 6
	description = "<span class='nicegreen'>Woooow duudeeeeee...I'm tripping baaalls...</span>\n"

/datum/mood_event/drugs/smoked
	description = "<span class='nicegreen'>I have had a smoke recently.</span>\n"
	mood_change = 2
	timeout = 3600

/datum/mood_event/drugs/overdose
	mood_change = -8
	timeout = 3000

/datum/mood_event/drugs/overdose/add_effects(drug_name)
	description = "<span class='warning'>I think I took a bit too much of that [drug_name]</span>\n"

/datum/mood_event/drugs/withdrawal_light
	mood_change = -2

/datum/mood_event/drugs/withdrawal_light/add_effects(drug_name)
	description = "<span class='warning'>I could use some [drug_name]</span>\n"

/datum/mood_event/drugs/withdrawal_medium
	mood_change = -5

/datum/mood_event/drugs/withdrawal_medium/add_effects(drug_name)
	description = "<span class='warning'>I really need [drug_name]</span>\n"

/datum/mood_event/drugs/withdrawal_severe
	mood_change = -8

/datum/mood_event/drugs/withdrawal_severe/add_effects(drug_name)
	description = "<span class='boldwarning'>Oh god I need some [drug_name]</span>\n"

/datum/mood_event/drugs/withdrawal_critical
	mood_change = -10

/datum/mood_event/drugs/withdrawal_critical/add_effects(drug_name)
	description = "<span class='boldwarning'>[drug_name]! [drug_name]! [drug_name]!</span>\n"
