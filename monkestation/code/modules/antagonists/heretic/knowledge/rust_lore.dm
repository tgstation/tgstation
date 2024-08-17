/datum/heretic_knowledge/rust_regen/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	ADD_TRAIT(user, TRAIT_ETHEREAL_NO_OVERCHARGE, type)

/datum/heretic_knowledge/rust_regen/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_ETHEREAL_NO_OVERCHARGE, type)
