/datum/action/cooldown/spell/jaunt
	school = SCHOOL_TRANSMUTATION

	invocation_type = INVOCATION_NONE
	spell_requirements = (SPELL_REQUIRES_NON_ABSTRACT|SPELL_REQUIRES_UNPHASED)

	/// The sound played when jaunt is exited
	var/exit_jaunt_sound = 'sound/magic/ethereal_exit.ogg'
	/// For how long are we jaunting?
	var/jaunt_duration = 5 SECONDS
	/// For how long we become immobilized after exiting the jaunt.
	var/jaunt_in_time = 0.5 SECONDS
	/// For how long we become immobilized when using this spell.
	var/jaunt_out_time = 0 SECONDS
	/// Visual for jaunting
	var/obj/effect/jaunt_in_type = /obj/effect/temp_visual/wizard
	/// Visual for exiting the jaunt
	var/obj/effect/jaunt_out_type = /obj/effect/temp_visual/wizard/out
	/// List of valid exit points
	var/list/exit_point_list

/datum/action/cooldown/spell/jaunt/can_cast_spell()
	. = ..()
	if(!.)
		return FALSE
	var/area/owner_area = get_area(owner)
	if(owner_area?.area_flags & NOTELEPORT)
		to_chat(user, span_danger("Some dull, universal force is stopping you from jaunting here."))
		return FALSE

	return isliving(owner)

/datum/action/cooldown/spell/jaunt/proc/is_jaunting(mob/living/cast_on)
	return istype(cast_on.loc, /obj/effect/dummy)

/datum/action/cooldown/spell/jaunt/Remove(mob/living/user)
	// TODO jaunting dummies are dumb and eject their contents on Destroy()
	if(is_jaunting(user))
		qdel(user.loc)
	return ..()
