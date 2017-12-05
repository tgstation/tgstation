/datum/component/caltrop
	var/damage
	var/flags

	var/cooldown = 0

/datum/component/caltrop/Initialize(_damage, _flags = NONE)
	damage = _damage
	flags = _flags
	RegisterSignal(list(COMSIG_MOVABLE_CROSSED), .proc/Crossed)

/datum/component/caltrop/proc/Crossed(atom/movable/AM)
	var/atom/A = parent
	if(!A.has_gravity())
		return

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(PIERCEIMMUNE in H.dna.species.species_traits)
			return

		if((flags & CALTROP_IGNORE_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
			return

		var/picked_def_zone = pick("l_leg", "r_leg")
		var/obj/item/bodypart/O = H.get_bodypart(picked_def_zone)
		if(!istype(O))
			return
		if(O.status == BODYPART_ROBOTIC)
			return

		var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

		if(!(flags & CALTROP_BYPASS_SHOES) && (H.shoes || feetCover))
			return

		if((H.movement_type & FLYING) || H.buckled)
			return

		H.apply_damage(damage, BRUTE, picked_def_zone)

		if(cooldown < world.time - 10) //cooldown to avoid message spam.
			if(!H.incapacitated())
				H.visible_message("<span class='danger'>[H] steps on [A].</span>", \
						"<span class='userdanger'>You step on [A]!</span>")
			else
				H.visible_message("<span class='danger'>[H] slides on [A]!</span>", \
						"<span class='userdanger'>You slide on [A]!</span>")

			cooldown = world.time
		H.Knockdown(60)
