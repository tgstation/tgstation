/*Vomiting
 * Reduces stealth
 * Slight resistance reduction
 * Slight stage speed reduction
 * Increases transmissibility
 * Bonus : Forces the affected mob to vomit! Makes the affected mob lose nutrition and heal toxin damage
and your disease can spread via people walking on vomit.
*/

/datum/symptom/vomit
	name = "Vomiting"
	desc = "The virus causes nausea and irritates the stomach, causing occasional vomit."
	illness = "Cyclonic Irritation"
	stealth = -2
	resistance = -1
	stage_speed = -1
	transmittable = 2
	level = 3
	severity = 3
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 80
	required_organ = ORGAN_SLOT_STOMACH
	threshold_descs = list(
		"Resistance 7" = "Host will vomit blood, causing internal damage.",
		"Transmission 7" = "Host will projectile vomit, increasing vomiting range.",
		"Stealth 4" = "The symptom remains hidden until active."
	)
	var/vomit_nebula = FALSE
	var/vomit_blood = FALSE
	var/proj_vomit = 0

/datum/symptom/vomit/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalResistance() >= 7) //blood vomit
		vomit_blood = TRUE
	if(A.totalTransmittable() >= 7) //projectile vomit
		proj_vomit = 5

/datum/symptom/vomit/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("You feel nauseated.", "You feel like you're going to throw up!")]"))
		else
			vomit(M)

/datum/symptom/vomit/proc/vomit(mob/living/carbon/vomiter)
	var/deductable_nutrition = 0
	var/constructed_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM)
	var/type_of_vomit = /obj/effect/decal/cleanable/vomit/toxic
	if(vomit_nebula)
		type_of_vomit = /obj/effect/decal/cleanable/vomit/nebula
		deductable_nutrition = 10
	else
		constructed_flags |= MOB_VOMIT_STUN
		deductable_nutrition = 20

	if(vomit_blood)
		constructed_flags |= MOB_VOMIT_BLOOD

	vomiter.vomit(vomit_flags = constructed_flags, vomit_type = type_of_vomit, lost_nutrition = deductable_nutrition, distance = proj_vomit)

/datum/symptom/vomit/nebula
	name = "Nebula Vomiting"
	desc = "The condition irritates the stomach, causing occasional vomit with stars that does not stun."
	illness = "Nebula Nausea"
	vomit_nebula = TRUE
	naturally_occuring = FALSE
