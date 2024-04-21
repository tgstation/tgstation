/datum/antagonist/battlecruiser/ally/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/target = mob_override || owner.current
	target.faction |= ROLE_SYNDICATE

/datum/antagonist/battlecruiser/ally/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/target = mob_override || owner.current
	target.faction -= ROLE_SYNDICATE
