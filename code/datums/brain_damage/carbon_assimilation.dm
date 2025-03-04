/datum/brain_trauma/special/assimilated_carbon
	name = "Malicious Programming"
	desc = "Patient's firmware integrity check is failing, malicious code present. Patient's allegiance may be compromised."
	scan_desc = "malicious programming"
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	var/datum/mind/master_ai
	var/datum/antagonist/assimilated_carbon/antagonist

/datum/brain_trauma/special/assimilated_carbon/proc/link_and_add_antag(datum/mind/ai_to_be_linked)
	antagonist = owner.mind.add_antag_datum(/datum/antagonist/assimilated_carbon)
	master_ai = ai_to_be_linked
	antagonist.set_master(ai_to_be_linked)

/datum/brain_trauma/special/assimilated_carbon/on_lose()
	..()
	antagonist = null
	master_ai = null
	owner.mind.remove_antag_datum(/datum/antagonist/assimilated_carbon)
