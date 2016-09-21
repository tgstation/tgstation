/mob/living/carbon/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"

	if (handcuffed)
		msg += "<span class='warning'>It is \icon[src.handcuffed] handcuffed!</span>\n"
	if (head)
		msg += "It has \icon[src.head] \a [src.head] on its head. \n"
	if (wear_mask)
		msg += "It has \icon[src.wear_mask] \a [src.wear_mask] on its face.\n"

	for(var/obj/item/I in held_items)
		if(!(I.flags & ABSTRACT))
			if(I.blood_DNA)
				msg += "<span class='warning'>It has \icon[I] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in its [get_held_index_name(get_held_index_of_item(I))]!</span>\n"
			else
				msg += "It has \icon[I] \a [I] in its [get_held_index_name(get_held_index_of_item(I))].\n"

	if (back)
		msg += "It has \icon[src.back] \a [src.back] on its back.\n"
	var/appears_dead = 0
	if (stat == DEAD)
		appears_dead = 1
		if(getorgan(/obj/item/organ/brain))
			msg += "<span class='deadsay'>It is limp and unresponsive, with no signs of life.</span>\n"
		else if(get_bodypart("head"))
			msg += "<span class='deadsay'>It appears that it's brain is missing...</span>\n"

	var/list/missing = get_missing_limbs()
	for(var/t in missing)
		if(t=="head")
			msg += "<span class='deadsay'><B>Its [parse_zone(t)] is missing!</B></span>\n"
			continue
		msg += "<<span class='warning'><B>Its [parse_zone(t)] is missing!</B></span>\n"

	msg += "<span class='warning'>"
	var/temp = getBruteLoss()
	if(temp)
		if (temp < 30)
			msg += "It has minor bruising.\n"
		else
			msg += "<B>It has severe bruising!</B>\n"

	temp = getFireLoss()
	if(temp)
		if (temp < 30)
			msg += "It has minor burns.\n"
		else
			msg += "<B>It has severe burns!</B>\n"

	temp = getCloneLoss()
	if(temp)
		if(getCloneLoss() < 30)
			msg += "It is slightly deformed.\n"
		else
			msg += "<b>It is severely deformed.</b>\n"

	if(getBrainLoss() > 60)
		msg += "It seems to be clumsy and unable to think.\n"

	if(fire_stacks > 0)
		msg += "It's covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "It's soaked in water.\n"

	if(pulledby && pulledby.grab_state)
		msg += "It's restrained by [pulledby]'s grip.\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "It isn't responding to anything around it; it seems to be asleep.\n"

		if(digitalcamo)
			msg += "It is moving its body in an unnatural and blatantly unsimian manner.\n"



	msg += "*---------*</span>"

	user << msg
