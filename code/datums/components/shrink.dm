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
		var/mob/living/L = parent_atom
		ADD_TRAIT(L, TRAIT_UNDENSE, SHRUNKEN_TRAIT)
		RegisterSignal(L, COMSIG_MOB_SAY, PROC_REF(handle_shrunk_speech))
		L.add_movespeed_modifier(/datum/movespeed_modifier/shrink_ray)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.unequip_everything()
			C.visible_message(span_warning("[C]'s belongings fall off of [C.p_them()] as they shrink down!"),
			span_userdanger("Your belongings fall away as everything grows bigger!"))
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				H.physiology.damage_resistance -= 100//carbons take double damage while shrunk
		if(!L.GetComponent(/datum/component/squashable))
			newsquash = L.AddComponent( \
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
		var/mob/living/L = parent_atom
		L.remove_movespeed_modifier(/datum/movespeed_modifier/shrink_ray)
		REMOVE_TRAIT(L, TRAIT_UNDENSE, SHRUNKEN_TRAIT)
		UnregisterSignal(L, COMSIG_MOB_SAY)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.physiology.damage_resistance += 100
	else
		parent_atom.set_density(olddens) // this is handled by the UNDENSE trait on mobs
	return ..()
