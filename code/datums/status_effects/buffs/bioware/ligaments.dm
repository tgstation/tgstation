// Bioware that affects the player's limbs
/datum/status_effect/bioware/ligaments
	id = "ligaments"

// Hooked ligaments - Easier to dismember, but easier to reattach
/datum/status_effect/bioware/ligaments/hooked

/datum/status_effect/bioware/ligaments/hooked/bioware_gained()
	owner.add_traits(list(TRAIT_LIMBATTACHMENT, TRAIT_EASYDISMEMBER), TRAIT_STATUS_EFFECT(id))

/datum/status_effect/bioware/ligaments/hooked/bioware_lost()
	owner.remove_traits(list(TRAIT_LIMBATTACHMENT, TRAIT_EASYDISMEMBER), TRAIT_STATUS_EFFECT(id))

// Reinforced ligaments - Easier to break, but cannot be dismembered
/datum/status_effect/bioware/ligaments/reinforced

/datum/status_effect/bioware/ligaments/reinforced/bioware_gained()
	owner.add_traits(list(TRAIT_NODISMEMBER, TRAIT_EASILY_WOUNDED), TRAIT_STATUS_EFFECT(id))

/datum/status_effect/bioware/ligaments/reinforced/bioware_lost()
	owner.remove_traits(list(TRAIT_NODISMEMBER, TRAIT_EASILY_WOUNDED), TRAIT_STATUS_EFFECT(id))
