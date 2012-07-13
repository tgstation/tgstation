/mob/living/carbon/monkey/examine()
	set src in oview()

	if(!usr || !src)	return
	if(((usr.disabilities & 128) || usr.blinded || usr.stat) && !(istype(usr,/mob/dead/observer/)))
		usr << "<span class='notice'>Something is there but you can't see it.</span>"
		return

	var/msg = "<span class='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"

	if (src.handcuffed)
		msg += "It is \icon[src.handcuffed] handcuffed!\n"
	if (src.wear_mask)
		msg += "It has \icon[src.wear_mask] \a [src.wear_mask] on its head.\n"
	if (src.l_hand)
		msg += "It has \icon[src.l_hand] \a [src.l_hand] in its left hand.\n"
	if (src.r_hand)
		msg += "It has \icon[src.r_hand] \a [src.r_hand] in its right hand.\n"
	if (src.back)
		msg += "It has \icon[src.back] \a [src.back] on its back.\n"
	if (src.stat == DEAD)
		msg += "<span class='deadsay'>It is limp and unresponsive, with no signs of life.</span>\n"
	else
		msg += "<span class='warning'>"
	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	for(var/named in organs)
		var/datum/organ/external/temp = organs[named]
		if(temp)
			if(temp.status & ORGAN_DESTROYED)
				is_destroyed["[temp.display_name]"] = 1
				wound_flavor_text["[temp.display_name]"] = "<span class='warning'><b>It is missing its [temp.display_name].</b></span>\n"
				continue
			if(temp.status & ORGAN_ROBOT)
				if(!(temp.brute_dam + temp.burn_dam))
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>It has a robot [temp.display_name]!</span>\n"
					continue
				else
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>It has a robot [temp.display_name], it has"
				if(temp.brute_dam) switch(temp.brute_dam)
					if(0 to 20)
						wound_flavor_text["[temp.display_name]"] += " some dents"
					if(21 to INFINITY)
						wound_flavor_text["[temp.display_name]"] += pick(" a lot of dents"," severe denting")
				if(temp.brute_dam && temp.burn_dam)
					wound_flavor_text["[temp.display_name]"] += " and"
				if(temp.burn_dam) switch(temp.burn_dam)
					if(0 to 20)
						wound_flavor_text["[temp.display_name]"] += " some burns"
					if(21 to INFINITY)
						wound_flavor_text["[temp.display_name]"] += pick(" a lot of burns"," severe melting")
				wound_flavor_text["[temp.display_name]"] += "!</span>\n"
			else if(temp.wound_descs)
				var/list/wound_descriptors = list()
				for(var/time in temp.wound_descs)
					for(var/wound in temp.wound_descs[time])
						if(wound in wound_descriptors)
							wound_descriptors[wound]++
							continue
						wound_descriptors[wound] = 1
				var/list/flavor_text = list()
				var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
				"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
				for(var/wound in wound_descriptors)
					switch(wound_descriptors[wound])
						if(1)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>It has[prob(10) && !(wound in no_exclude)  ? " what might be" : ""] a [wound]"
							else
								flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a [wound]"
						if(2)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>It has[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
							else
								flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
						if(3 to 5)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>It has several [wound]s"
							else
								flavor_text += " several [wound]s"
						if(6 to INFINITY)
							if(!flavor_text.len)
								flavor_text += "<span class='warning'>It has a bunch of [wound]s"
							else
								flavor_text += " a ton of [wound]\s"
				var/flavor_text_string = ""
				for(var/text = 1, text <= flavor_text.len, text++)
					if(text == flavor_text.len && flavor_text.len > 1)
						flavor_text_string += ", and"
					else if(flavor_text.len > 1 && text > 1)
						flavor_text_string += ","
					flavor_text_string += flavor_text[text]
				flavor_text_string += " on its [named].</span><br>"
				wound_flavor_text["[named]"] = flavor_text_string
			else
				wound_flavor_text["[temp.display_name]"] = ""

	//Handles the text strings being added to the actual description.
	if(wound_flavor_text["head"])
		msg += wound_flavor_text["head"]
	if(wound_flavor_text["chest"])
		msg += wound_flavor_text["chest"]
	if(wound_flavor_text["left arm"])
		msg += wound_flavor_text["left arm"]
	if(wound_flavor_text["left hand"])
		msg += wound_flavor_text["left hand"]
	if(wound_flavor_text["right arm"])
		msg += wound_flavor_text["right arm"]
	if(wound_flavor_text["right hand"])
		msg += wound_flavor_text["right hand"]
	if(wound_flavor_text["groin"])
		msg += wound_flavor_text["groin"]
	if(wound_flavor_text["left leg"])
		msg += wound_flavor_text["left leg"]
	if(wound_flavor_text["left foot"])
		msg += wound_flavor_text["left foot"]
	if(wound_flavor_text["right leg"])
		msg += wound_flavor_text["right leg"]
	if(wound_flavor_text["right foot"])
		msg += wound_flavor_text["right foot"]

	if (src.stat == UNCONSCIOUS)
		msg += "It isn't responding to anything around it; it seems to be asleep.\n"
	msg += "</span>"

	if (src.digitalcamo)
		msg += "It is repulsively uncanny!\n"
	if(print_flavor_text()) msg += "[print_flavor_text()]\n"

	msg += "*---------*</span>"

	usr << msg
	return