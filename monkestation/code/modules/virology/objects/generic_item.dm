//Called by disease_contact(), trying to infect people who pick us up
/obj/item/proc/infection_attempt(mob/living/perp, datum/disease/D, bodypart = null)
	if (!istype(D))
		return

	if (src in perp.held_items)
		bodypart = HANDS

	if (bodypart)
		var/block = perp.check_contact_sterility(bodypart)
		var/bleeding = perp.check_bodypart_bleeding(bodypart)
		if (!block)
			if (D.spread & SPREAD_CONTACT)
				perp.infect_disease2(D, notes="(Contact, from picking up \a [src])")
			else if (bleeding && (D.spread & SPREAD_BLOOD))//if we're covered with a blood-spreading disease, we may infect people with bleeding hands.
				perp.infect_disease2(D, notes="(Blood, from picking up \a [src])")
