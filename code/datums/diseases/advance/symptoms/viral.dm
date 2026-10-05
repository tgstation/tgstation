/*Viral adaptation
 * Greatly increases stealth
 * Tremendous buff for resistance
 * Greatly decreases stage speed
 * No effect to transmissibility
 *
 * Bonus: Buffs resistance & stealth. Extremely useful for buffing viruses
*/
/datum/symptom/viraladaptation
	name = "Viral self-adaptation"
	desc = "The virus mimics the function of normal body cells, becoming harder to spot and to eradicate, but reducing its speed. \
	Does nothing by itself."
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmittable = 0
	level = 4
	symptom_cure = null

/datum/symptom/viraladaptation/OnAdd(datum/disease/advance/our_disease)
	. = ..()
	our_disease.NeuterSymptom(src)


/*Viral evolution
 * Reduces stealth
 * Greatly reduces resistance
 * Tremendous buff for stage speed
 * Greatly increases transmissibility
 *
 * Bonus: Buffs transmission and speed. Extremely useful for buffing viruse*
*/
/datum/symptom/viralevolution
	name = "Viral evolutionary acceleration"
	desc = "The virus quickly adapts to spread as fast as possible both outside and inside a host. \
	This, however, makes the virus easier to spot, and less able to fight off a cure. Does nothing by itself."
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmittable = 3
	level = 4
	symptom_cure = null

/datum/symptom/viralevolution/OnAdd(datum/disease/advance/our_disease)
	. = ..()
	our_disease.NeuterSymptom(src)
