/datum/status_effect/neck_slice/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/neck_slice/on_apply()
	. = ..()
	if (!.)
		return
		
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
