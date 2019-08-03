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
	parent_atom.density = 0
	parent_atom.opacity = 0
	if(isliving(parent_atom))
		var/mob/living/L = parent_atom
		L.add_movespeed_modifier(MOVESPEED_ID_SHRINK_RAY, update=TRUE, priority=100, multiplicative_slowdown=4, movetypes=GROUND)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.unequip_everything()
			C.visible_message("<span class='warning'>[C]'s belongings fall off of [C.p_them()] as they shrink down!</span>",
			"<span class='userdanger'>Your belonings fall away as everything grows bigger!</span>")
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				H.physiology.damage_resistance -= 100//carbons take double damage while shrunk
//		addtimer(CALLBACK(src, .proc/grow_back_living, L), shrink_time)
	else
		parent_atom.visible_message("<span class='warning'>[parent_atom] shrinks down to a tiny size!</span>",
		"<span class='userdanger'>Everything grows bigger!</span>")
//		addtimer(CALLBACK(src, .proc/grow_back), shrink_time)
	QDEL_IN(src, shrink_time)
/*
/datum/component/shrink/proc/grow_back(var/del_after = TRUE)
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(2,2)
	parent_atom.density = olddens
	parent_atom.opacity = oldopac
	if(del_after)
		qdel(src)

/datum/component/shrink/proc/grow_back_living(var/mob/living/L)
	grow_back(FALSE)
	L.remove_movespeed_modifier(MOVESPEED_ID_SHRINK_RAY)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.damage_resistance += 100
	qdel(src)
*/
/datum/component/shrink/Destroy()
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(2,2)
	parent_atom.density = olddens
	parent_atom.opacity = oldopac
	if(isliving(parent_atom))
		var/mob/living/L = parent_atom
		L.remove_movespeed_modifier(MOVESPEED_ID_SHRINK_RAY)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.physiology.damage_resistance += 100
