
GLOBAL_LIST_INIT(infected_items, list())

/obj/item
	//how sterile an item is, not used for much atm
	var/sterility = 0
/obj/item
	var/list/viruses = list()

/obj/item/attack_hand(mob/user, list/modifiers)
	. = ..()
	disease_contact(user)

//Called by attack_hand(), transfers diseases between the mob and the item
/obj/item/proc/disease_contact(mob/living/carbon/M, bodypart = null)
	//first let's try to infect them with our viruses
	for(var/datum/disease/advanced/V as anything in viruses)
		infection_attempt(M, V, bodypart)

	if (!bodypart)//no bodypart specified? that should mean we're being held.
		bodypart = BODY_ZONE_ARMS

	//secondly, do they happen to carry contact-spreading viruses themselves?
	var/list/contact_diseases = filter_disease_by_spread(M.diseases, required = DISEASE_SPREAD_CONTACT_SKIN)
	if (contact_diseases?.len)
		//if so are their hands protected?
		var/block = M.check_contact_sterility(bodypart)
		for (var/datum/disease/advanced/D in contact_diseases)
			if(!block)
				infect_disease(D, notes="(Contact, from being touched by [M])")

//Called by disease_contact(), trying to infect people who pick us up
/obj/item/infection_attempt(mob/living/perp, datum/disease/advanced/D, bodypart = null)
	if (!istype(D))
		return

	if (src in perp.held_items)
		bodypart = BODY_ZONE_ARMS

	if (bodypart)
		var/block = perp.check_contact_sterility(bodypart)
		var/bleeding = perp.check_bodypart_bleeding(bodypart)
		if (!block && (D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN))
			perp.infect_disease(D, notes="(Contact, from picking up \a [src])")
		else if (bleeding && (D.spread_flags & DISEASE_SPREAD_BLOOD))//if we're covered with a blood-spreading disease, we may infect people with bleeding hands.
			perp.infect_disease(D, notes="(Blood, from picking up \a [src])")

/obj/item/infect_disease(datum/disease/advanced/disease, forced = FALSE, notes = "", decay = TRUE)
	if(!istype(disease))
		return FALSE
	if(!disease.spread_flags)
		return FALSE
	if(prob(disease.infectionchance) || forced)
		var/datum/disease/advanced/D = disease.Copy()
		D.log += "<br />[ROUND_TIME()] Infected \a [src] [notes]"

		GLOB.infected_items |= src

		LAZYADD(viruses, D)
		//SSdisease.active_diseases += D
		D.after_add()

		logger.Log(LOG_CATEGORY_VIRUS, "[src.name] was infected by virus [D.real_name()] at [loc_name(loc)]", list("disease_data" = D.admin_details(), "location" = loc_name(loc)))

		if (!pathogen)
			pathogen = image('monkestation/code/modules/virology/icons/effects.dmi', src, "pathogen_contact")
			pathogen.plane = HUD_PLANE
			pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/L in GLOB.science_goggles_wearers)
			if (L.client)
				L.client.images |= pathogen
		if (decay)
			addtimer(CALLBACK(src, PROC_REF(remove_disease), D), (disease.infectionchance/10) MINUTES)

/obj/item/proc/remove_disease(datum/disease/disease)
	viruses -= disease
	SSdisease.active_diseases -= disease
	if(!length(viruses))
		GLOB.infected_items -= src
		if (pathogen)
			for (var/mob/L in GLOB.science_goggles_wearers)
				if(L.client)
					L.client.images -= pathogen


/obj/item/try_infect_with_mobs_diseases(mob/living/carbon/infectee)
	if(!infectee)
		return
	if(!length(infectee.diseases))
		return
	var/list/blood_diseases = filter_disease_by_spread(infectee.diseases, required = DISEASE_SPREAD_BLOOD)
	if(length(blood_diseases))
		for(var/datum/disease/advanced/V as anything in blood_diseases)
			infect_disease(V, TRUE, "(Blood, coming from [infectee])")
