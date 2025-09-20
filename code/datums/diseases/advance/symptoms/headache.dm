/*Headache
 * Slightly reduces stealth
 * Increases resistance tremendously
 * Increases stage speed
 * No change to transmissibility
 * Low level
 * Bonus: Displays an annoying message! Should be used for buffing your disease.
*/
/datum/symptom/headache
	name = "Headache"
	desc = "The virus causes inflammation inside the brain, causing constant headaches."
	illness = "Brain Freeze"
	stealth = -1
	resistance = 4
	stage_speed = 2
	transmittable = 0
	level = 1
	severity = 1
	base_message_chance = 100
	symptom_delay_min = 15
	symptom_delay_max = 30
	threshold_descs = list(
		"Stage Speed 6" = "Headaches will cause severe pain, that weakens the host.",
		"Stage Speed 9" = "Headaches become less frequent but far more intense, preventing any action from the host.",
		"Stealth 4" = "Reduces headache frequency until later stages.",
	)

/datum/symptom/headache/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		base_message_chance = 50
	if(A.totalStageSpeed() >= 6) //severe pain
		power = 2
	if(A.totalStageSpeed() >= 9) //cluster headaches
		symptom_delay_min = 30
		symptom_delay_max = 60
		power = 3

/datum/symptom/headache/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	if(HAS_TRAIT(M, TRAIT_SOOTHED_HEADACHE))
		return
	if(power < 2)
		if(prob(base_message_chance) || A.stage >= 4)
			to_chat(M, span_warning("[pick("Your head hurts.", "Your head pounds.")]"))
	if(power >= 2 && A.stage >= 4)
		to_chat(M, span_warning("[pick("Your head hurts a lot.", "Your head pounds incessantly.")]"))
		M.adjustStaminaLoss(25)
	if(power >= 3 && A.stage >= 5)
		to_chat(M, span_userdanger("[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]"))
		M.Stun(35)
