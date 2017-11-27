/mob/living/carbon
	var/fist_casted = FALSE

/mob/living/carbon/proc/reset_fist_casted()
	if(fist_casted)
		fist_casted = FALSE

/mob/living/carbon/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	var/hurt = TRUE
	if(istype(throwingdatum, /datum/thrownthing))
		var/datum/thrownthing/D = throwingdatum
		if(iscyborg(D.thrower))
			var/mob/living/silicon/robot/R = D.thrower
			if(!R.emagged)
				hurt = FALSE
	if(hit_atom.density && isturf(hit_atom))
		if(hurt)
			Knockdown(20)
			take_bodypart_damage(10)
		if(fist_casted)
			var/turf/T = get_turf(src)
			visible_message("<span class='danger'>[src] slams into [T] with explosive force!</span>", "<span class='userdanger'>You slam into [T] so hard everything nearby feels it!</span>")
			explosion(T, -1, 1, 4, 0, 0, 0) //No fire and no flash, this is less an explosion and more a shockwave from beign punched THAT hard.
			fist_casted = FALSE
	if(iscarbon(hit_atom) && hit_atom != src)
		var/mob/living/carbon/victim = hit_atom
		if(victim.movement_type & FLYING)
			return
		if(hurt)
			victim.take_bodypart_damage(10)
			take_bodypart_damage(10)
			victim.Knockdown(20)
			Knockdown(20)
			visible_message("<span class='danger'>[src] crashes into [victim], knocking them both over!</span>", "<span class='userdanger'>You violently crash into [victim]!</span>")
			playsound(src,'sound/weapons/punch1.ogg',50,1)
		if(fist_casted)
			visible_message("<span class='danger'>[src] slams into [victim] with enough force to level a skyscraper!</span>", "<span class='userdanger'>You crash into [victim] like a thunderbolt!</span>")
			var/turf/T = get_turf(src)
			explosion(T, -1, 3, 5, 0, 0, 0) //The reward for lining the spell up to hit another person is a bigger boom!
