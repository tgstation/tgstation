// Bioware that affects the CNS
/datum/status_effect/bioware/nerves
	id = "nerves"

// Grounded Nerves - Immunity to being zapped
/datum/status_effect/bioware/nerves/grounded

/datum/status_effect/bioware/nerves/grounded/bioware_gained()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/bioware/nerves/grounded/bioware_lost()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, TRAIT_STATUS_EFFECT(id))

// Spliced Nerves - Reduced stun time and stamina damage taken
/datum/status_effect/bioware/nerves/spliced

/datum/status_effect/bioware/nerves/spliced/bioware_gained()
	MODIFY_PHYSIOLOGY(owner, PHYS_COEFF_STUN, 0.5)
	MODIFY_PHYSIOLOGY(owner, PHYS_COEFF_STAMINA, 0.8)

/datum/status_effect/bioware/nerves/spliced/bioware_lost()
	MODIFY_PHYSIOLOGY(owner, PHYS_COEFF_STUN, 2)
	MODIFY_PHYSIOLOGY(owner, PHYS_COEFF_STAMINA, 1.25)
