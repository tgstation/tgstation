/mob/living/carbon/whisper(message as text)

	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja)&&src.wear_mask:voice=="Unknown")
		if(copytext(message, 1, 2) != "*")
			var/list/temp_message = text2list(message, " ")
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++)
				pick_list += i
			for(var/i=1, i <= abs(temp_message.len/3), i++)
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
				temp_message[H] = ninjaspeak(temp_message[H])
				pick_list -= H
			message = dd_list2text(temp_message, " ")
			message = replacetext(message, "o", "¤")
			message = replacetext(message, "p", "þ")
			message = replacetext(message, "l", "£")
			message = replacetext(message, "s", "§")
			message = replacetext(message, "u", "µ")
			message = replacetext(message, "b", "ß")
	..(message)