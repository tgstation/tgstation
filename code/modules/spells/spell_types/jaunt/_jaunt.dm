/datum/action/cooldown/spell/jaunt
	school = SCHOOL_TRANSMUTATION

	invocation_type = INVOCATION_NONE
	spell_requirements = (SPELL_REQUIRES_NON_ABSTRACT|SPELL_REQUIRES_UNPHASED)

/datum/action/cooldown/spell/jaunt/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/area/owner_area = get_area(owner)
	if(owner_area?.area_flags & NOTELEPORT)
		if(feedback)
			to_chat(owner, span_danger("Some dull, universal force is stopping you from jaunting here."))
		return FALSE

	return isliving(owner)

/datum/action/cooldown/spell/jaunt/proc/is_jaunting(mob/living/cast_on)
	return istype(cast_on.loc, /obj/effect/dummy)

/datum/action/cooldown/spell/jaunt/Remove(mob/living/user)
	// MELBERT TODO jaunting dummies are dumb and eject their contents on Destroy()
	if(is_jaunting(user))
		qdel(user.loc)
	return ..()
