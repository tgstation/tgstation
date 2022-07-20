/**Dizziness
 * Increases stealth
 * Lowers resistance
 * Decreases stage speed considerably
 * Slightly reduces transmissibility
 * Intense Level
 * Bonus: Shakes the affected mob's screen for short periods.
 */

/datum/symptom/dizzy // Not the egg

	name = "Dizziness"
	desc = "The virus causes inflammation of the vestibular system, leading to bouts of dizziness."
	resistance = -2
	stage_speed = -3
	transmittable = -1
	level = 4
	severity = 2
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 30
	threshold_descs = list(
		"Transmission 6" = "Also causes druggy vision.",
		"Stealth 4" = "The symptom remains hidden until active.",
	)

/datum/symptom/dizzy/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalTransmittable() >= 6) //druggy
		power = 2

/datum/symptom/dizzy/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
		else
			to_chat(M, span_userdanger("A wave of dizziness washes over you!"))
			M.adjust_timed_status_effect(1 MINUTES, /datum/status_effect/dizziness, max_duration = 140 SECONDS)
			if(power >= 2)
				M.set_timed_status_effect(80 SECONDS, /datum/status_effect/drugginess)
