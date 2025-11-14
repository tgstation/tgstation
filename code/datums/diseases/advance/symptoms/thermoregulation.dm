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
	if(A.stage < 3)
		return
	if(!(affected_mob.dna.species.bodytemp_cold_damage_limit < affected_mob.bodytemperature < affected_mob.dna.species.bodytemp_heat_damage_limit))
		to_chat(affected_mob, span_notice("You feel a [difference >= 0 ? "warmth" : "chill"] spread through your body."))
	var/difference = affected_mob.bodytemperature - affected_mob.bodytemp_normal
	var/stage_power = (A.stage == 3) ? power/2 : power // Half as strong at stage 3
	affected_mob.adjust_bodytemperature(clamp(difference, -stage_power * 10, stage_power * 10))
