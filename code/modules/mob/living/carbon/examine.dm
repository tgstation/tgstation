/mob/living/carbon/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	var/msg = "<span class='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"

	if (handcuffed)
		msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] handcuffed!</span>\n"
	if (head)
		msg += "[t_He] [t_is] wearing [bicon(head)] \a [src.head] on [t_his] head. \n"
	if (wear_mask)
		msg += "[t_He] [t_is] wearing [bicon(wear_mask)] \a [src.wear_mask] on [t_his] face.\n"
	if (wear_neck)
		msg += "[t_He] [t_is] wearing [bicon(wear_neck)] \a [src.wear_neck] around [t_his] neck.\n"

	for(var/obj/item/I in held_items)
		if(!(I.flags & ABSTRACT))
			if(I.blood_DNA)
				msg += "<span class='warning'>[t_He] [t_is] holding [bicon(I)] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in [t_his] [get_held_index_name(get_held_index_of_item(I))]!</span>\n"
			else
				msg += "[t_He] [t_is] holding [bicon(I)] \a [I] in [t_his] [get_held_index_name(get_held_index_of_item(I))].\n"

	if (back)
		msg += "[t_He] [t_has] [bicon(back)] \a [src.back] on [t_his] back.\n"
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
			if(prob(50))
				msg += "[t_He] [t_has] small bruises.\n"
			else
				msg += "[t_He] [t_has] minor bruising.\n"
		else
			if(prob(33))
				msg += "<B>[t_He] [t_is] bloodied!</B>\n"
			else if(prob(50))
				msg += "<B>[t_his] body is mangled!</B>\n"
			else
				msg += "<B>[t_his] body is battered and bruised!</B>\n"

	temp = getFireLoss()
	if(temp)
		if (temp < 30)
			if(prob(50))
				msg += "[t_his] skin is bright red.\n"
			else
				msg += "[t_his] skin is covered in small burns.\n"
		else
			if(prob(33))
				msg += "<B>[t_his] skin is covered in large blisters!</B>\n"
			else if(prob(50))
				msg += "<B>[t_his] skin is charred and blistering!</B>\n"
			else
				msg += "<B>[t_his] skin is blackened and burned!</B>\n"

	temp = getCloneLoss()
	if(temp)
		if(getCloneLoss() < 30)
			if(prob(50))
				msg += "[t_He] [t_is] covered in minor deformities.\n"
			else
				msg += "[t_his] body is deformed.\n"
		else
			if(prob(33))
				msg += "<B>[t_his] skin is covered in large, unnatural genetic deformities!</B>\n"
			else if(prob(50))
				msg += "<B>[t_his] body is covered in lumps and warts!</B>\n"
			else
				msg += "<B>[t_his] body and limbs are severely deformed in several areas!</B>\n"

	if(getBrainLoss() > 60)
		msg += "[t_He] has a blank, dumb look on his face.\n"

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
