/datum/slime_trait/never_evolving
	name = "Never Changing Slime"
	desc = "Prevents the slime from splitting or mutating"


/datum/slime_trait/never_evolving/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.slime_flags |= NOEVOLVE_SLIME

/datum/slime_trait/never_evolving/on_remove(mob/living/basic/slime/parent)
	. = ..()
	parent.slime_flags &= ~NOEVOLVE_SLIME
