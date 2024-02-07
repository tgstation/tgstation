/datum/status_effect/hippocratic_oath/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_PERFECT_SURGEON, HIPPOCRATIC_OATH_TRAIT)

/datum/status_effect/hippocratic_oath/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_PERFECT_SURGEON, HIPPOCRATIC_OATH_TRAIT)
