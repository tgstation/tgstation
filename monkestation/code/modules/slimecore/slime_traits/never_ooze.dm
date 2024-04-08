/datum/slime_trait/never_ooze
	name = "Ooze Prevention"
	desc = "Prevents slimes from making ooze."

/datum/slime_trait/never_ooze/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.slime_flags |= NOOOZE_SLIME

/datum/slime_trait/never_ooze/on_remove(mob/living/basic/slime/parent)
	. = ..()
	parent.slime_flags &= ~NOOOZE_SLIME
