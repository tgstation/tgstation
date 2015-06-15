/proc/attempt_initiate_surgery(obj/item/I, mob/living/M, mob/user)
	if(istype(M))
		if(M.lying || isslime(M))	//if they're prone or a slime
			var/list/all_surgeries = surgeries_list.Copy()
			var/list/available_surgeries = list()
			for(var/i in all_surgeries)
				var/datum/surgery/S = all_surgeries[i]

				if(locate(S.type) in M.surgeries)
					continue
				if(S.user_species_restricted)
					if(!istype(user, /mob/living/carbon/human))
						continue
					var/mob/living/carbon/human/doc = user
					if(!(doc.dna.species.id in S.user_species_ids))
						continue
				if(S.target_must_be_dead && M.stat != DEAD)
					continue
				if(S.target_must_be_fat && !(M.disabilities & FAT))
					continue

				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M //So we can use get_organ and not some terriblly long Switch or something worse - RR

					if(S.requires_organic_chest && H.getlimb(/obj/item/organ/limb/robot/chest)) //This a seperate case to below, see "***" in surgery.dm - RR
						continue


					var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))

					if(affecting.status == ORGAN_ROBOTIC && affecting.body_part != HEAD) //Cannot operate on Robotic organs except for the head. - RR
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
					if(get_location_accessible(M, procedure.location) || procedure.ignore_clothes)
						if(procedure.location == "anywhere") // if location == "anywhere" change location to the surgeon's target, otherwise leave location as is.
							procedure.location = user.zone_sel.selecting
						M.surgeries += procedure
						user.visible_message("[user] drapes [I] over [M]'s [parse_zone(procedure.location)] to prepare for \an [procedure.name].", "<span class='notice'>You drape [I] over [M]'s [parse_zone(procedure.location)] to prepare for \an [procedure.name].</span>")

						add_logs(user, M, "operated", addition="Operation type: [procedure.name]")
						feedback_add_details("surgery_initiated","[procedure.name]")
						return 1
					else
						user << "<span class='warning'>You need to expose [M]'s [procedure.location] first!</span>"
						return 1	//return 1 so we don't slap the guy in the dick with the drapes.
			else
				return 1	//once the input menu comes up, cancelling it shouldn't hit the guy with the drapes either.
	return 0



/proc/get_location_modifier(mob/M)
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
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask, C.head))
			covered_locations |= I.body_parts_covered
			face_covered |= I.flags_inv
			eyesmouth_covered |= I.flags
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.ears))
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
			if(covered_locations & HEAD || face_covered & HIDEFACE || eyesmouth_covered & MASKCOVERSMOUTH || eyesmouth_covered & HEADCOVERSMOUTH)
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

