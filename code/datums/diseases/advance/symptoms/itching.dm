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
	///emote cooldowns
	COOLDOWN_DECLARE(itching_cooldown)
	///if FALSE, there is a percentage chance that the mob will emote scratching while itching_cooldown is on cooldown. If TRUE, won't emote again until after the off cooldown scratch occurs.
	var/off_cooldown_scratched = FALSE
/datum/symptom/itching/Start(datum/disease/advance/active_disease)
	. = ..()
	if(!.)
		return
	if(active_disease.totalTransmittable() >= 6) //itch more often
		symptom_delay_min = 1
		symptom_delay_max = 4
	if(active_disease.totalStageSpeed() >= 7) //scratch
		scratch = TRUE

/datum/symptom/itching/Activate(datum/disease/advance/active_disease)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/affected_mob = active_disease.affected_mob
	var/obj/item/bodypart/bodypart = affected_mob.get_bodypart(affected_mob.get_random_valid_zone(even_weights = TRUE))
	if(bodypart && IS_ORGANIC_LIMB(bodypart) && !bodypart.is_pseudopart)  //robotic limbs will mean less scratching overall (why are golems able to damage themselves with self-scratching, but not androids? the world may never know)
		var/can_scratch = scratch && !affected_mob.incapacitated()
		if(can_scratch)
			bodypart.receive_damage(0.5)
		//below handles emotes, limiting the emote of emotes passed to chat
		if(COOLDOWN_FINISHED(src, itching_cooldown) || !COOLDOWN_FINISHED(src, itching_cooldown) && prob(60) && !off_cooldown_scratched)
			affected_mob.visible_message("[can_scratch ? span_warning("[affected_mob] scratches [affected_mob.p_their()] [bodypart.plaintext_zone].") : ""]", span_warning("Your [bodypart.plaintext_zone] itches. [can_scratch ? " You scratch it." : ""]"))
			COOLDOWN_START(src, itching_cooldown, 5 SECONDS)
			if(!off_cooldown_scratched && !COOLDOWN_FINISHED(src, itching_cooldown))
				off_cooldown_scratched = TRUE
			else
				off_cooldown_scratched = FALSE
