/datum/component/shrink
	var/atom/parent_atom
	var/shrink_remaining_timer
	var/olddens
	var/oldopac

/datum/component/shrink/Initialize(shrink_time)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	parent_atom = parent
	RegisterSignal(parent_atom, COMSIG_SHRINK_TIME_RESET, .proc/reset_timer)
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
				addtimer(VARSET_CALLBACK(H, physiology.damage_resistance, H.physiology.damage_resistance + 100), shrink_time)
		shrink_remaining_timer = addtimer(CALLBACK(src, .proc/grow_back_living, L), shrink_time, TIMER_STOPPABLE)
	else
		parent_atom.visible_message("<span class='warning'>[parent_atom] shrinks down to a tiny size!</span>",
		"<span class='userdanger'>Everything grows bigger!</span>")
		shrink_remaining_timer = addtimer(CALLBACK(src, .proc/grow_back), shrink_time, TIMER_STOPPABLE)

/datum/component/shrink/proc/grow_back(var/del_after = TRUE)
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

/datum/component/shrink/proc/reset_timer(shrink_time)//if we get shrunk again while shrunken, just restart the timer on how long we should be shrunk for
	deltimer(shrink_remaining_timer)
	if(isliving(parent_atom))
		var/mob/living/L = parent_atom
		shrink_remaining_timer = addtimer(CALLBACK(src, .proc/grow_back_living, L), shrink_time, TIMER_STOPPABLE)
	else
		shrink_remaining_timer = addtimer(CALLBACK(src, .proc/grow_back), shrink_time, TIMER_STOPPABLE)
