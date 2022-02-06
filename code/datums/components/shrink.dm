/datum/component/shrink
	var/olddens
	var/oldopac
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

/datum/component/shrink/Initialize(shrink_time)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(0.5,0.5)
	olddens = parent_atom.density
	oldopac = parent_atom.opacity
	parent_atom.set_density(FALSE)
	parent_atom.set_opacity(FALSE)
	if(isliving(parent_atom))
		var/mob/living/L = parent_atom
		L.add_movespeed_modifier(/datum/movespeed_modifier/shrink_ray)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.unequip_everything()
			C.visible_message(span_warning("[C]'s belongings fall off of [C.p_them()] as they shrink down!"),
			span_userdanger("Your belongings fall away as everything grows bigger!"))
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				H.physiology.damage_resistance -= 100//carbons take double damage while shrunk
	parent_atom.visible_message(span_warning("[parent_atom] shrinks down to a tiny size!"),
	span_userdanger("Everything grows bigger!"))
	QDEL_IN(src, shrink_time)

/datum/component/shrink/Destroy()
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(2,2)
	parent_atom.set_density(olddens)
	parent_atom.set_opacity(oldopac)
	if(isliving(parent_atom))
		var/mob/living/L = parent_atom
		L.remove_movespeed_modifier(/datum/movespeed_modifier/shrink_ray)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.physiology.damage_resistance += 100
	return ..()
