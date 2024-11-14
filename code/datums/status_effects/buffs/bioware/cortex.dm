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
	tick_interval = 2 SECONDS

/datum/status_effect/bioware/cortex/imprinted/tick(seconds_between_ticks)
	var/mob/living/carbon/human/human_owner = owner
	human_owner.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
