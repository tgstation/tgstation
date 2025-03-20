// Bioware that affects the brain
/datum/status_effect/bioware/cortex
	id = "cortex"

// Folded brain - Grants a bonus chance to getting special traumas via lobotomy
/datum/status_effect/bioware/cortex/folded

/datum/status_effect/bioware/cortex/folded/bioware_gained()
	ADD_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/bioware/cortex/folded/bioware_lost()
	REMOVE_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST, TRAIT_STATUS_EFFECT(id))

// Imprinted brain - Cures basic traumas continuously
/datum/status_effect/bioware/cortex/imprinted

/datum/status_effect/bioware/cortex/imprinted/bioware_gained()
	var/mob/living/carbon/human/human_owner = owner
	human_owner.cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC)
	RegisterSignal(human_owner, COMSIG_CARBON_GAIN_TRAUMA, PROC_REF(on_gain_trauma))

/datum/status_effect/bioware/cortex/imprinted/bioware_lost()
	UnregisterSignal(owner, COMSIG_CARBON_GAIN_TRAUMA)

/datum/status_effect/bioware/cortex/imprinted/proc/on_gain_trauma(datum/source, datum/brain_trauma/trauma, resilience)
	SIGNAL_HANDLER
	if(isnull(resilience))
		resilience = trauma.resilience
	if(resilience <= TRAUMA_RESILIENCE_BASIC) // there SHOULD be nothing lower than TRAUMA_RESILIENCE_BASIC, but I'd prefer to not make assumptions in case this ever gets some sort of refactor
		return COMSIG_CARBON_BLOCK_TRAUMA
