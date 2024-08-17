// Bioware that affects the heart / circulatory system
/datum/status_effect/bioware/heart
	id = "circulation"

/// Muscled veins - Removes the need to have a heart
/datum/status_effect/bioware/heart/muscled_veins

/datum/status_effect/bioware/heart/muscled_veins/bioware_gained()
	ADD_TRAIT(owner, TRAIT_STABLEHEART, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/bioware/heart/muscled_veins/bioware_lost()
	REMOVE_TRAIT(owner, TRAIT_STABLEHEART, TRAIT_STATUS_EFFECT(id))

/// Threaded veins - Bleed way less
/datum/status_effect/bioware/heart/threaded_veins

/datum/status_effect/bioware/heart/threaded_veins/bioware_gained()
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.bleed_mod *= 0.25

/datum/status_effect/bioware/heart/threaded_veins/bioware_lost()
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.bleed_mod *= 4
