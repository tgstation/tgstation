/mob/living/carbon/human/say(var/message)
	if(src.mutantrace == "lizard")
		if(copytext(message, 1, 2) != "*")
			message = dd_replaceText(message, "s", stutter("ss"))
	if(src.mutantrace == "metroid" && prob(5))
		if(copytext(message, 1, 2) != "*")
			if(copytext(message, 1, 2) == ";")
				message = ";"
			else
				message = ""
			message += "SKR"
			var/imax = rand(5,20)
			for(var/i = 0,i<imax,i++)
				message += "E"

	for(var/datum/disease/pierrot_throat/D in viruses)
		var/list/temp_message = dd_text2list(message, " ")
		var/list/pick_list = list()
		for(var/i = 1, i <= temp_message.len, i++)
			pick_list += i
		for(var/i=1, ((i <= D.stage) && (i <= temp_message.len)), i++)
			if(prob(5 * D.stage))
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
				temp_message[H] = "HONK"
				pick_list -= H
			message = dd_list2text(temp_message, " ")

	//Ninja mask obscures text and voice if set to do so.
	//Would make it more global but it's sort of ninja specific.
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja)&&src.wear_mask:voice=="Unknown")
		if(copytext(message, 1, 2) != "*")
			var/list/temp_message = dd_text2list(message, " ")
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++)
				pick_list += i
			for(var/i=1, i <= abs(temp_message.len/3), i++)
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
				temp_message[H] = ninjaspeak(temp_message[H])
				pick_list -= H
			message = dd_list2text(temp_message, " ")
			message = dd_replaceText(message, "o", "¤")
			message = dd_replaceText(message, "p", "þ")
			message = dd_replaceText(message, "l", "£")
			message = dd_replaceText(message, "s", "§")
			message = dd_replaceText(message, "u", "µ")
			message = dd_replaceText(message, "b", "ß")
			/*This text is hilarious but also absolutely retarded.
			message = dd_replaceText(message, "l", "r")
			message = dd_replaceText(message, "rr", "ru")
			message = dd_replaceText(message, "v", "b")
			message = dd_replaceText(message, "f", "hu")
			message = dd_replaceText(message, "'t", "")
			message = dd_replaceText(message, "t ", "to ")
			message = dd_replaceText(message, " I ", " ai ")
			message = dd_replaceText(message, "th", "z")
			message = dd_replaceText(message, "ish", "isu")
			message = dd_replaceText(message, "is", "izu")
			message = dd_replaceText(message, "ziz", "zis")
			message = dd_replaceText(message, "se", "su")
			message = dd_replaceText(message, "br", "bur")
			message = dd_replaceText(message, "ry", "ri")
			message = dd_replaceText(message, "you", "yuu")
			message = dd_replaceText(message, "ck", "cku")
			message = dd_replaceText(message, "eu", "uu")
			message = dd_replaceText(message, "ow", "au")
			message = dd_replaceText(message, "are", "aa")
			message = dd_replaceText(message, "ay", "ayu")
			message = dd_replaceText(message, "ea", "ii")
			message = dd_replaceText(message, "ch", "chi")
			message = dd_replaceText(message, "than", "sen")
			message = dd_replaceText(message, ".", "")
			message = lowertext(message)
			*/
	..(message)

/mob/living/carbon/human/say_understands(var/other)
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/decoy))
		return 1
	if (istype(other, /mob/living/silicon/pai))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	if (istype(other, /mob/living/carbon/metroid))
		return 1
	return ..()