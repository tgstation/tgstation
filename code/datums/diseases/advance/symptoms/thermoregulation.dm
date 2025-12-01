/** Thermoregulation
 * No change to stealth.
 * Increases resistance.
 * Reduces stage speed.
 * Reduces transmissibility
 * Bonus: Regulates body temperature.
 */

/datum/symptom/thermoregulation
	name = "Thermoregulation"
	desc = "The virus reacts to extreme conditions and assists the body in regulating its temperature."
	stealth = 0
	resistance = 1
	stage_speed = -2
	transmittable = -1
	level = 5
	severity = 0
	threshold_descs = list(
		"Resistance 8" = "Increases thermal regulation speed."
	)

/datum/symptom/thermoregulation/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 8)
		power = 1.75

/datum/symptom/thermoregulation/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.stage >= 3)
		var/mob/living/carbon/carbon_host = A.affected_mob
		var/difference = carbon_host.dna.species.bodytemp_normal - carbon_host.bodytemperature
		if(!(carbon_host.dna.species.bodytemp_cold_damage_limit < carbon_host.bodytemperature < carbon_host.dna.species.bodytemp_heat_damage_limit)) // No need to spam chat
			to_chat(carbon_host, span_notice("You feel a [difference < 0 ? "warmth" : "chill"] spread through your body."))
		var/stage_power = (A.stage == 3) ? power * 5 : power * 10 // Half as strong at stage 3
		carbon_host.adjust_bodytemperature(clamp(difference, -stage_power, stage_power))
