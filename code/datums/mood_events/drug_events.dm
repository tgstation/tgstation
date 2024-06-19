/datum/mood_event/high
	mood_change = 6
	description = "Woooow duudeeeeee... I'm tripping baaalls..."

/datum/mood_event/stoned
	mood_change = 6
	description = "I'm sooooo stooooooooooooned..."

/datum/mood_event/maintenance_high
	mood_change = 6
	description = "I'm on top of the world, baby! Tide worldwide!"
	timeout = 2 MINUTES

/datum/mood_event/maintenance_high/add_effects(param)
	var/value = rand(-1, 6) // chance for it to suck
	mood_change = value
	if(value < 0)
		description = "No! Don't! My gloves! Auuuuurgh!"
	else
		description = initial(description)

/datum/mood_event/hang_over
	mood_change = -4
	description = "I have a killer hang over!"
	timeout = 1 MINUTES

/datum/mood_event/smoked
	description = "I have had a smoke recently."
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/wrong_brand
	description = "I hate that brand of cigarettes."
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/overdose
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/overdose/add_effects(drug_name)
	description = "I think I took a bit too much of that [drug_name]!"

/datum/mood_event/withdrawal_light
	mood_change = -2

/datum/mood_event/withdrawal_light/add_effects(drug_name)
	description = "I could use some [drug_name]..."

/datum/mood_event/withdrawal_medium
	mood_change = -5

/datum/mood_event/withdrawal_medium/add_effects(drug_name)
	description = "I really need [drug_name]."

/datum/mood_event/withdrawal_severe
	mood_change = -8

/datum/mood_event/withdrawal_severe/add_effects(drug_name)
	description = "Oh god, I need some of that [drug_name]!"

/datum/mood_event/happiness_drug
	description = "Can't feel a thing..."
	mood_change = 50

/datum/mood_event/happiness_drug_good_od
	description = "YES! YES!! YES!!!"
	mood_change = 100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_good"

/datum/mood_event/happiness_drug_bad_od
	description = "NO! NO!! NO!!!"
	mood_change = -100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_bad"

/datum/mood_event/narcotic_medium
	description = "I feel comfortably numb."
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/narcotic_heavy
	description = "I feel like I'm wrapped up in cotton!"
	mood_change = 9
	timeout = 3 MINUTES

/datum/mood_event/stimulant_medium
	description = "I have so much energy! I feel like I could do anything!"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/stimulant_heavy
	description = "Eh ah AAAAH! HA HA HA HA HAA! Uuuh."
	mood_change = 6
	timeout = 3 MINUTES

#define EIGENTRIP_MOOD_RANGE 10

/datum/mood_event/eigentrip
	description = "I swapped places with an alternate reality version of myself!"
	mood_change = 0
	timeout = 10 MINUTES

/datum/mood_event/eigentrip/add_effects(param)
	var/value = rand(-EIGENTRIP_MOOD_RANGE,EIGENTRIP_MOOD_RANGE)
	mood_change = value
	if(value < 0)
		description = "I swapped places with an alternate reality version of myself! I want to go home!"
	else
		description = "I swapped places with an alternate reality version of myself! Though, this place is much better than my old life."

#undef EIGENTRIP_MOOD_RANGE

/datum/mood_event/nicotine_withdrawal_moderate
	description = "Haven't had a smoke in a while. Feeling a little on edge... "
	mood_change = -5

/datum/mood_event/nicotine_withdrawal_severe
	description = "Head pounding. Cold sweating. Feeling anxious. Need a smoke to calm down!"
	mood_change = -8

/datum/mood_event/hauntium_spirits
	description = "I feel my soul degrading!"
	mood_change = -8
	timeout = 8 MINUTES
