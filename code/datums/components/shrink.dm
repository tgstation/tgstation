/datum/component/shrink
	var/olddens
	var/oldopac
	/// Tracks the squashable component we apply when we make the small mob squashable
	var/datum/component/squashable/newsquash
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

/datum/component/shrink/Initialize(shrink_time)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(0.5,0.5)
	olddens = parent_atom.density
	oldopac = parent_atom.opacity

	parent_atom.set_opacity(FALSE)
	if(isliving(parent_atom))
		var/mob/living/living = parent_atom
		ADD_TRAIT(living, TRAIT_UNDENSE, SHRUNKEN_TRAIT)
		RegisterSignal(living, COMSIG_MOB_SAY, PROC_REF(handle_shrunk_speech))
		living.add_movespeed_modifier(/datum/movespeed_modifier/shrink_ray)
		living.damage_resistance -= 100
		if(iscarbon(living))
			var/mob/living/carbon/carbon = living
			carbon.unequip_everything()
			carbon.visible_message(span_warning("[carbon]'s belongings fall off of [carbon.p_them()] as [carbon.p_they()] shrink down!"),
			span_userdanger("Your belongings fall away as everything grows bigger!"))
		if(!living.GetComponent(/datum/component/squashable))
			newsquash = living.AddComponent( \
				/datum/component/squashable, \
				squash_chance = 75, \
				squash_damage = 10, \
				squash_flags = SQUASHED_ALWAYS_IF_DEAD|SQUASHED_DONT_SQUASH_IN_CONTENTS, \
			)
	else
		parent_atom.set_density(FALSE) // this is handled by the UNDENSE trait on mobs
	parent_atom.visible_message(span_warning("[parent_atom] shrinks down to a tiny size!"),
	span_userdanger("Everything grows bigger!"))
	if(shrink_time >= 0) // negative shrink time is permanent
		QDEL_IN(src, shrink_time)

/datum/component/shrink/proc/handle_shrunk_speech(mob/living/little_guy, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_SMALL_VOICE

/datum/component/shrink/Destroy()
	if(newsquash)
		qdel(newsquash)
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(2,2)
	parent_atom.set_opacity(oldopac)
	if(isliving(parent_atom))
		var/mob/living/living = parent_atom
		living.remove_movespeed_modifier(/datum/movespeed_modifier/shrink_ray)
		REMOVE_TRAIT(living, TRAIT_UNDENSE, SHRUNKEN_TRAIT)
		UnregisterSignal(living, COMSIG_MOB_SAY)
		living.damage_resistance += 100
	else
		parent_atom.set_density(olddens) // this is handled by the UNDENSE trait on mobs
	return ..()
