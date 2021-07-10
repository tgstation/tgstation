/datum/mood_event/high
	mood_change = 6
	description = "<span class='nicegreen'>Woooow duudeeeeee... I'm tripping baaalls...</span>\n"

/datum/mood_event/stoned
	mood_change = 6
	description = "<span class='nicegreen'>I'm sooooo stooooooooooooned...</span>\n"

/datum/mood_event/smoked
	description = "<span class='nicegreen'>I have had a smoke recently.</span>\n"
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/wrong_brand
	description = "<span class='warning'>I hate that brand of cigarettes.</span>\n"
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/overdose
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/overdose/add_effects(drug_name)
	description = "<span class='warning'>I think I took a bit too much of that [drug_name]!</span>\n"

/datum/mood_event/withdrawal_light
	mood_change = -2

/datum/mood_event/withdrawal_light/add_effects(drug_name)
	description = "<span class='warning'>I could use some [drug_name]...</span>\n"

/datum/mood_event/withdrawal_medium
	mood_change = -5

/datum/mood_event/withdrawal_medium/add_effects(drug_name)
	description = "<span class='warning'>I really need [drug_name].</span>\n"

/datum/mood_event/withdrawal_severe
	mood_change = -8

/datum/mood_event/withdrawal_severe/add_effects(drug_name)
	description = "<span class='boldwarning'>Oh god, I need some of that [drug_name]!</span>\n"

/datum/mood_event/withdrawal_critical
	mood_change = -10

/datum/mood_event/withdrawal_critical/add_effects(drug_name)
	description = "<span class='boldwarning'>[drug_name]! [drug_name]! [drug_name]!</span>\n"

/datum/mood_event/happiness_drug
	description = "<span class='nicegreen'>Can't feel a thing...</span>\n"
	mood_change = 50

/datum/mood_event/happiness_drug_good_od
	description = "<span class='nicegreen'>YES! YES!! YES!!!</span>\n"
	mood_change = 100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_good"

/datum/mood_event/happiness_drug_bad_od
	description = "<span class='boldwarning'>NO! NO!! NO!!!</span>\n"
	mood_change = -100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_bad"

/datum/mood_event/narcotic_medium
	description = "<span class='nicegreen'>I feel comfortably numb.</span>\n"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/narcotic_heavy
	description = "<span class='nicegreen'>I feel like I'm wrapped up in cotton!</span>\n"
	mood_change = 9
	timeout = 3 MINUTES

/datum/mood_event/stimulant_medium
	description = "<span class='nicegreen'>I have so much energy! I feel like I could do anything!</span>\n"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/stimulant_heavy
	description = "<span class='nicegreen'>Eh ah AAAAH! HA HA HA HA HAA! Uuuh.</span>\n"
	mood_change = 6
	timeout = 3 MINUTES

#define EIGENTRIP_MOOD_RANGE 10

/datum/mood_event/eigentrip
	description = "<span class='nicegreen'>I swapped places with an alternate reality version of myself!</span>\n"
	mood_change = 0
	timeout = 10 MINUTES

/datum/mood_event/eigentrip/add_effects(param)
	var/value = rand(-EIGENTRIP_MOOD_RANGE,EIGENTRIP_MOOD_RANGE)
	mood_change = value
	if(value < 0)
		description = "<span class='warning'>I swapped places with an alternate reality version of myself! I want to go home!</span>\n"
	else
		description = "<span class='nicegreen'>I swapped places with an alternate reality version of myself! Though, this place is much better than my old life.</span>\n"

#undef EIGENTRIP_MOOD_RANGE

/datum/mood_event/nicotine_withdrawal_moderate
	description = "<span class='warning'>Haven't had a smoke in a while. Feeling a little on edge... </span>\n"
	mood_change = -5

/datum/mood_event/nicotine_withdrawal_severe
	description = "<span class='boldwarning'>Head pounding. Cold sweating. Feeling anxious. Need a smoke to calm down!</span>\n"
	mood_change = -8
