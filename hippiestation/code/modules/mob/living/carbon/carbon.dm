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

/mob/living/carbon/proc/throw_hats(var/how_many, var/list/throw_directions)
	// Using a list so random directions are possible for all the hats we're trying to throw
	if (how_many <= 0 || LAZYLEN(throw_directions) <= 0 || !head)
		return

	var/obj/item/clothing/head/Hat = head

	if (!istype(Hat))
		return

	if (LAZYLEN(Hat.stacked_hats) <= 0)
		return

	if (how_many > LAZYLEN(Hat.stacked_hats))
		how_many = LAZYLEN(Hat.stacked_hats)

	while (how_many > 0)
		how_many -= 1
		var/obj/item/clothing/head/J = pop(Hat.stacked_hats)

		if (istype(J))
			J.forceMove(loc)

			// Taken from the knock_out_teeth() proc because we want similar behaviour
			var/turf/target = get_turf(loc)
			var/range = rand(2, J.throw_range)

			for (var/i = 1; i < range; i++)
				var/turf/new_turf = get_step(target, pick(throw_directions))
				target = new_turf
				if (new_turf.density)
					break

			J.throw_at(target, J.throw_range, J.throw_speed)

	Hat.update_overlays()
	Hat.update_name()
	update_inv_head()