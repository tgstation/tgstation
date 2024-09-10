/datum/wound/slash/flesh/show_wound_topic(mob/user)
	return (user == victim && blood_flow)

/datum/wound/slash/flesh/Topic(href, href_list)
	. = ..()
	if(href_list["wound_topic"])
		if(usr != victim)
			return
		victim.grabbedby(usr, grabbed_part = limb)

/datum/wound/pierce/bleed/show_wound_topic(mob/user)
	return (user == victim && blood_flow)

/datum/wound/slash/bleed/Topic(href, href_list)
	. = ..()
	if(href_list["wound_topic"])
		if(usr != victim)
			return
		victim.grabbedby(usr, grabbed_part = limb)
