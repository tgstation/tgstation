/mob/living/proc/find_nearby_disease()//only tries to find Contact and Blood spread diseases. Airborne ones are handled by breath_airborne_diseases()
	if(buckled)//Riding a vehicle?
		return
	if(HAS_TRAIT(src, TRAIT_MOVE_FLYING))//Flying?
		return

	var/turf/T = get_turf(src)

	//Virus Dishes aren't toys, handle with care, especially when they're open.
	for(var/obj/effect/decal/cleanable/virusdish/dish in T)
		dish.infection_attempt(src)

	for(var/obj/item/weapon/virusdish/dish in T)
		if (dish.open && dish.contained_virus)
			dish.infection_attempt(src, dish.contained_virus)

	var/obj/item/weapon/virusdish/dish = locate() in held_items
	if (dish && dish.open && dish.contained_virus)
		dish.infection_attempt(src, dish.contained_virus)

	//Now to check for stuff that's on the floor
	var/block = 0
	var/bleeding = 0
	if (body_position == LYING_DOWN)
		block = check_contact_sterility(BODY_ZONE_EVERYTHING)
		bleeding = check_bodypart_bleeding(BODY_ZONE_EVERYTHING)
	else
		block = check_contact_sterility(BODY_ZONE_LEGS)
		bleeding = check_bodypart_bleeding(BODY_ZONE_LEGS)


	var/static/list/viral_cleanable_types = list(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/vomit,
		)

	for(var/obj/effect/decal/cleanable/C in T)
		if (is_type_in_list(C,viral_cleanable_types))
			assume_contact_diseases(C.diseases, C, block, bleeding)

	return FALSE

//This one is used for one-way infections, such as getting splashed with someone's blood due to clobbering them to death
/mob/living/proc/oneway_contact_diseases(mob/living/carbon/L, block=0, bleeding=0)
	assume_contact_diseases(L.diseases,L,block,bleeding)

//This one is used for two-ways infections, such as hand-shakes, hugs, punches, people bumping into each others, etc
/mob/living/proc/share_contact_diseases(mob/living/carbon/L, block=0, bleeding=0)
	L.assume_contact_diseases(diseases ,src,block,bleeding)
	assume_contact_diseases(L.diseases, L, block, bleeding)

///////////////////////DISEASE STUFF///////////////////////////////////////////////////////////////////

//Blocked is whether clothing prevented the spread of contact/blood
/mob/living/proc/assume_contact_diseases(list/disease_list, atom/source, blocked=0, bleeding=0)
	if (istype(disease_list) && disease_list.len > 0)
		for(var/datum/disease/advanced/V as anything in disease_list)
			if (!V)
				message_admins("[key_name(src)] is trying to assume contact diseases from touching \a [source], but the disease_list contains an ID ([V.uniqueID]-[V.subID]) that isn't associated to an actual disease datum! Ping Dwasint about it please.")
				return
			if(!blocked && V.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
				infect_disease(V, notes="(Contact, from [source])")
			/*
			else if(suitable_colony() && V.spread & SPREAD_COLONY)
				infect_disease(V, notes="(Colonized, from [source])")
			*/
			else if(!blocked && bleeding && (V.spread_flags & DISEASE_SPREAD_BLOOD))
				infect_disease(V, notes="(Blood, from [source])")

//Called in Life() by humans (in handle_breath.dm), monkeys and mice
/mob/living/proc/breath_airborne_diseases()//only tries to find Airborne spread diseases. Blood and Contact ones are handled by find_nearby_disease()
	if (!check_airborne_sterility() && isturf(loc))//checking for sterile mouth protections
		breath_airborne_diseases_from_clouds()

		var/turf/T = get_turf(src)
		var/list/breathable_cleanable_types = list(
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/vomit,
			)

		for(var/obj/effect/decal/cleanable/C in T)
			if (is_type_in_list(C,breathable_cleanable_types))
				if(istype(C.diseases,/list) && C.diseases.len > 0)
					for(var/datum/disease/advanced/V as anything in C.diseases)
						if(V.spread_flags & DISEASE_SPREAD_AIRBORNE)
							infect_disease(V, notes="(Airborne, from [C])")
		/*
		for(var/obj/effect/rune/R in T)
			if(istype(R.virus2,/list) && R.virus2.len > 0)
				for(var/datum/disease/advanced/V as anything in R.diseases)
					if(V.spread_flags & DISEASE_SPREAD_AIRBORNE)
						infect_disease(V, notes="(Airborne, from [R])")
		*/

		spawn (1)
			//we don't want the rest of the mobs to start breathing clouds before they've settled down
			//otherwise it can produce exponential amounts of lag if many mobs are in an enclosed space
			spread_airborne_diseases()

/mob/living/proc/breath_airborne_diseases_from_clouds()
	for(var/turf/T in range(1, src))
		var/sanity = 0
		for(var/obj/effect/pathogen_cloud/cloud in T.contents)
			if(sanity > 10)
				break
			sanity++ //anything more than 10 and you aint getting air really
			if (!cloud.sourceIsCarrier || cloud.source != src || cloud.modified)
				if (Adjacent(cloud))
					for (var/datum/disease/advanced/V in cloud.viruses)
						//if (V.spread & SPREAD_AIRBORNE)	//Anima Syndrome allows for clouds of non-airborne viruses
						infect_disease(V, notes="(Airborne, from a pathogenic cloud[cloud.source ? " created by [key_name(cloud.source)]" : ""])")

/mob/living/proc/handle_virus_updates(seconds_per_tick)
	if(status_flags & GODMODE)
		return 0

	find_nearby_disease()//getting diseases from blood/mucus/vomit splatters and open dishes

	activate_diseases(seconds_per_tick)

/mob/living/proc/activate_diseases(seconds_per_tick)
	if (length(diseases))
		var/active_disease = pick(diseases)//only one disease will activate its effects at a time.
		for (var/datum/disease/advanced/V  as anything in diseases)
			if(istype(V))
				V.activate(src, active_disease != V, seconds_per_tick)

				if(HAS_TRAIT(src, TRAIT_IRRADIATED))
					if (prob(50))//radiation turns your body into an inefficient pathogenic incubator.
						V.incubate(src, 1)
						//effect mutations won't occur unless the mob also has ingested mutagen
						//and even if they occur, the new effect will have a badness similar to the old one, so helpful pathogen won't instantly become deadly ones.
	else
		//Slowly decay back to regular strength immune system while you are sick
		if(immune_system?.strength > 1)
			immune_system.strength = max(immune_system.strength - 0.01, 1)

/mob/living/proc/try_contact_infect(datum/disease/advanced/D, zone = BODY_ZONE_EVERYTHING, note = "Try Contact Infect")
	if(!(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
		return
	var/block = check_contact_sterility(zone)
	if(block)
		infect_disease(D, notes = note)

