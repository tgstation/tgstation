/proc/attempt_initiate_surgery(obj/item/I, mob/living/M, mob/user)
	if(istype(M))
		if(M.lying || isslime(M))	//if they're prone or a slime
			var/list/all_surgeries = surgeries_list.Copy()
			var/list/available_surgeries = list()
			for(var/i in all_surgeries)
				var/datum/surgery/S = all_surgeries[i]

				if(locate(S.type) in M.surgeries)
					continue
				if(S.target_must_be_dead && M.stat != DEAD)
					continue
				if(S.target_must_be_fat && !(FAT in M.mutations))
					continue
				for(var/path in S.species)
					if(istype(M, path))
						available_surgeries[S.name] = S
						break

			var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in available_surgeries
			if(P)
				var/datum/surgery/S = available_surgeries[P]
				var/datum/surgery/procedure = new S.type
				if(procedure)
					if(get_location_accessible(M, procedure.location))
						M.surgeries += procedure
						user.visible_message("<span class='notice'>[user] drapes [I] over [M]'s [procedure.location] to prepare for \an [procedure.name].</span>")

						user.attack_log += "\[[time_stamp()]\]<font color='red'>Initiated a [procedure.name] on [M.name] ([M.ckey])</font>"
						M.attack_log += "\[[time_stamp()]\]<font color='red'>[user.name] ([user.ckey]) initiated a [procedure.name]</font>"
						log_attack("<font color='red'>[user.name] ([user.ckey]) initiated a [procedure.name] on [M.name] ([M.ckey])</font>")
						return 1
					else
						user << "<span class='notice'>You need to expose [M]'s [procedure.location] first.</span>"
						return 1	//return 1 so we don't slap the guy in the dick with the drapes.
			else
				return 1	//once the input menu comes up, cancelling it shouldn't hit the guy with the drapes either.
	return 0


proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/structure/optable, T))
		return 1
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/stool/bed, T))
		return 0.7
	else
		return 0.5


/proc/get_location_accessible(mob/M, location)
	var/covered_locations	= 0	//based on body_parts_covered
	var/face_covered		= 0	//based on flags_inv
	var/eyesmouth_covered	= 0	//based on flags
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask))
			covered_locations |= I.body_parts_covered
			face_covered |= I.flags_inv
			eyesmouth_covered |= I.flags
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.head, H.ears))
				covered_locations |= I.body_parts_covered
				face_covered |= I.flags_inv
				eyesmouth_covered |= I.flags

	switch(location)
		if("head")
			if(covered_locations & HEAD)
				return 0
		if("eyes")
			if(covered_locations & HEAD || face_covered & HIDEEYES || eyesmouth_covered & GLASSESCOVERSEYES)
				return 0
		if("mouth")
			if(covered_locations & HEAD || face_covered & HIDEFACE || eyesmouth_covered & MASKCOVERSMOUTH)
				return 0
		if("chest")
			if(covered_locations & CHEST)
				return 0
		if("groin")
			if(covered_locations & GROIN)
				return 0
		if("l_arm")
			if(covered_locations & ARM_LEFT)
				return 0
		if("r_arm")
			if(covered_locations & ARM_RIGHT)
				return 0
		if("l_leg")
			if(covered_locations & LEG_LEFT)
				return 0
		if("r_leg")
			if(covered_locations & LEG_RIGHT)
				return 0
		if("l_hand")
			if(covered_locations & HAND_LEFT)
				return 0
		if("r_hand")
			if(covered_locations & HAND_RIGHT)
				return 0
		if("l_foot")
			if(covered_locations & FOOT_LEFT)
				return 0
		if("r_foot")
			if(covered_locations & FOOT_RIGHT)
				return 0

	return 1