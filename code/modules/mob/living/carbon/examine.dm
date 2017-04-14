/mob/living/carbon/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"

	if (handcuffed)
		msg += "<span class='warning'>[t_He] [t_is] \icon[src.handcuffed] handcuffed!</span>\n"
	if (head)
		msg += "[t_He] [t_is] wearing \icon[src.head] \a [src.head] on [t_his] head. \n"
	if (wear_mask)
		msg += "[t_He] [t_is] wearing \icon[src.wear_mask] \a [src.wear_mask] on [t_his] face.\n"
	if (wear_neck)
		msg += "[t_He] [t_is] wearing \icon[src.wear_neck] \a [src.wear_neck] around [t_his] neck.\n"

	for(var/obj/item/I in held_items)
		if(!(I.flags & ABSTRACT))
			if(I.blood_DNA)
				msg += "<span class='warning'>[t_He] [t_is] holding \icon[I] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in [t_his] [get_held_index_name(get_held_index_of_item(I))]!</span>\n"
			else
				msg += "[t_He] [t_is] holding \icon[I] \a [I] in [t_his] [get_held_index_name(get_held_index_of_item(I))].\n"

	if (back)
		msg += "[t_He] [t_has] \icon[src.back] \a [src.back] on [t_his] back.\n"
	var/appears_dead = 0
	if (stat == DEAD)
		appears_dead = 1
		if(getorgan(/obj/item/organ/brain))
			msg += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive, with no signs of life.</span>\n"
		else if(get_bodypart("head"))
			msg += "<span class='deadsay'>[t_He] appears that [t_his] brain is missing...</span>\n"

	var/list/missing = get_missing_limbs()
	for(var/t in missing)
		if(t=="head")
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B></span>\n"
			continue
		msg += "<span class='warning'><B>[t_His] [parse_zone(t)] is missing!</B></span>\n"

	msg += "<span class='warning'>"
	var/temp = getBruteLoss()
	if(temp)
		if (temp < 30)
			msg += "[t_He] [t_has] minor bruising.\n"
		else
			msg += "<B>[t_He] [t_has] severe bruising!</B>\n"

	temp = getFireLoss()
	if(temp)
		if (temp < 30)
			msg += "[t_He] [t_has] minor burns.\n"
		else
			msg += "<B>[t_He] [t_has] severe burns!</B>\n"

	temp = getCloneLoss()
	if(temp)
		if(getCloneLoss() < 30)
			msg += "[t_He] [t_is] slightly deformed.\n"
		else
			msg += "<b>[t_He] [t_is] severely deformed.</b>\n"

	if(getBrainLoss() > 60)
		msg += "[t_He] seems to be clumsy and unable to think.\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] [t_is] looks a little soaked.\n"

	if(pulledby && pulledby.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.\n"

		if(digitalcamo)
			msg += "[t_He] [t_is] moving [t_his] body in an unnatural and blatantly unsimian manner.\n"



	msg += "*---------*</span>"

	to_chat(user, msg)
