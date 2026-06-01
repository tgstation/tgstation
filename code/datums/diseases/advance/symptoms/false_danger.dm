/datum/symptom/heal/false_danger
	name = "False Danger"
	desc = "The virus behaves in a way that makes it appear more threatening to the immune system than it is."
	severity = 1
	stealth = -4
	resistance = 5
	stage_speed = 5
	transmittable = 5
	level = 4
	base_message_chance = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	symptom_cure = null
	can_be_neutered = FALSE
	power = 2

	threshold_descs = list(
		"Transmission -6" = "The virus is able to able to heal the host, with the healing speed additionaly being increased by harmful symptoms.",
	)

	var/severityHealBonus = 0.25

/datum/symptom/heal/CanHeal(datum/disease/advance/our_disease)
	if(our_disease.totalTransmittable <= -6)
		return power + our_disease.totalSeverity()*severityHealBonus
	return 0

/datum/symptom/heal/Heal(mob/living/carbon/carbon_host, datum/disease/advance/our_disease, actual_power)
	var/heal_amt = actual_power

	var/needs_update = FALSE
	needs_update += carbon_host.heal_overall_damage(heal_amt, heal_amt, required_bodytype = healable_bodytypes, updating_health = FALSE)
	if(needs_update)
		carbon_host.updatehealth()
	return TRUE
