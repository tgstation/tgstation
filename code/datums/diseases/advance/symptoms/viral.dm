// Symptoms that only exist for stats
/datum/symptom/stats
	symptom_cure = null
	abstract_type = /datum/symptom/stats

/datum/symptom/stats/OnAdd(datum/disease/advance/our_disease)
	. = ..()
	our_disease.NeuterSymptom(src)

/*Viral adaptation
 * Greatly increases stealth
 * Tremendous buff for resistance
 * Greatly decreases stage speed
 * No effect to transmissibility
 *
 * Bonus: Buffs resistance & stealth. Extremely useful for buffing viruses
*/
/datum/symptom/stats/adaptation
	name = "Viral self-adaptation"
	desc = "The virus mimics the function of normal body cells, becoming harder to spot and to eradicate, but reducing its speed. \
	Does nothing by itself."
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmittable = 0
	level = 4

/*Viral evolution
 * Reduces stealth
 * Greatly reduces resistance
 * Tremendous buff for stage speed
 * Greatly increases transmissibility
 *
 * Bonus: Buffs transmission and speed. Extremely useful for buffing viruse*
*/
/datum/symptom/stats/evolution
	name = "Viral evolutionary acceleration"
	desc = "The virus quickly adapts to spread as fast as possible both outside and inside a host. \
	This, however, makes the virus easier to spot, and less able to fight off a cure. Does nothing by itself."
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmittable = 3
	level = 4

/datum/symptom/stats/antag_loud
	name = "Loud Antag Virus Booster"
	desc = "It makes the antag viruses stronger, and then viros can loot it afterwards"
	stealth = 0
	resistance = 4
	stage_speed = 4
	transmittable = 5

/datum/symptom/stats/antag_stealth
	name = "Stealthy Antag Virus Booster"
	desc = "Evil (and yet copyable) antag virus booster: stealth virus edition."
	stealth = 4
	resistance = 3
	stage_speed = 3
	transmittable = 4
