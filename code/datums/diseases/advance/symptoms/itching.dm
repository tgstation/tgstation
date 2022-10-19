/*Itching
 * No effect to stealth
 * Greatly increases resistance
 * Greatly increases stage speed
 * Slightly increases transmissibility
 * Low level
 * Bonus: Displays an annoying message! Should be used for buffing your disease.
*/
/datum/symptom/itching
	name = "Itching"
	desc = "The virus irritates the skin, causing itching."
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 1
	level = 1
	severity = 1
	symptom_delay_min = 5
	symptom_delay_max = 25
	var/scratch = FALSE
	threshold_descs = list(
		"Transmission 6" = "Increases frequency of itching.",
		"Stage Speed 7" = "The host will scrath itself when itching, causing superficial damage.",
	)

/datum/symptom/itching/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalTransmittable() >= 6) //itch more often
		symptom_delay_min = 1
		symptom_delay_max = 4
	if(A.totalStageSpeed() >= 7) //scratch
		scratch = TRUE

/datum/symptom/itching/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	var/obj/item/bodypart/bodypart = M.get_bodypart(M.get_random_valid_zone(even_weights = TRUE))
	if(bodypart && IS_ORGANIC_LIMB(bodypart) && !bodypart.is_pseudopart)  //robotic limbs will mean less scratching overall (why are golems able to damage themselves with self-scratching, but not androids? the world may never know)
		var/can_scratch = scratch && !M.incapacitated()
		M.visible_message("[can_scratch ? span_warning("[M] scratches [M.p_their()] [bodypart.plaintext_zone].") : ""]", span_warning("Your [bodypart.plaintext_zone] itches. [can_scratch ? " You scratch it." : ""]"))
		if(can_scratch)
			bodypart.receive_damage(0.5)
