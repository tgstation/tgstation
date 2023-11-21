GLOBAL_LIST_INIT(infected_items, list())

/obj/item
	var/image/pathogen
	var/list/viruses = list()

//Called by disease_contact(), trying to infect people who pick us up
/obj/item/infection_attempt(mob/living/perp, datum/disease/D, bodypart = null)
	if (!istype(D))
		return

	if (src in perp.held_items)
		bodypart = HANDS

	var/obj/item/bodypart/bp = perp.get_bodypart(bodypart)
	if (bodypart)
		var/block = perp.check_contact_sterility(bodypart)
		var/bleeding = bp.get_modified_bleed_rate()
		if (!block)
			if (D.spread & SPREAD_CONTACT)
				perp.infect_disease(D, notes="(Contact, from picking up \a [src])")
			else if (bleeding && (D.spread & SPREAD_BLOOD))//if we're covered with a blood-spreading disease, we may infect people with bleeding hands.
				perp.infect_disease(D, notes="(Blood, from picking up \a [src])")

/obj/item/infect_disease(datum/disease/disease, forced = FALSE, notes = "", decay = TRUE)
	if(!istype(disease))
		return FALSE
	if(!disease.spread)
		return FALSE
	if(prob(disease.infectionchance) || forced)
		var/datum/disease/D = disease.Copy()
		D.log += "<br />[ROUND_TIME()] Infected \a [src] [notes]"

		GLOB.infected_items |= src

		LAZYADD(viruses, D)
		SSdisease.active_diseases += D
		D.after_add()

		if (!pathogen)
			pathogen = image('monkestation/code/modules/virology/icons/effects.dmi',src,"pathogen_contact")
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
