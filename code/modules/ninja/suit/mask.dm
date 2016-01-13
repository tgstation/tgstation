
/*

Contents:
- The Ninja Space Mask
- Ninja Space Mask speech modification

*/




/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1
	strip_delay = 120

/obj/item/clothing/mask/gas/voice/space_ninja/speechModification(message)
	if(voice == "Unknown")
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
			message = list2text(temp_message, " ")

			//The Alternate speech mod is now the main one.
			message = replacetext(message, "l", "r")
			message = replacetext(message, "rr", "ru")
			message = replacetext(message, "v", "b")
			message = replacetext(message, "f", "hu")
			message = replacetext(message, "'t", "")
			message = replacetext(message, "t ", "to ")
			message = replacetext(message, " I ", " ai ")
			message = replacetext(message, "th", "z")
			message = replacetext(message, "is", "izu")
			message = replacetext(message, "ziz", "zis")
			message = replacetext(message, "se", "su")
			message = replacetext(message, "br", "bur")
			message = replacetext(message, "ry", "ri")
			message = replacetext(message, "you", "yuu")
			message = replacetext(message, "ck", "cku")
			message = replacetext(message, "eu", "uu")
			message = replacetext(message, "ow", "au")
			message = replacetext(message, "are", "aa")
			message = replacetext(message, "ay", "ayu")
			message = replacetext(message, "ea", "ii")
			message = replacetext(message, "ch", "chi")
			message = replacetext(message, "than", "sen")
			message = replacetext(message, ".", "")
			message = lowertext(message)

	return message



/obj/item/clothing/mask/gas/voice/space_ninja/New()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Ninja Equip"

	var/mob/U = loc//Can't toggle voice when you're not wearing the mask.
	var/vchange = (alert("Would you like to synthesize a new name or turn off the voice synthesizer?",,"New Name","Turn Off"))
	if(vchange == "New Name")
		var/chance = rand(1,100)
		switch(chance)
			if(1 to 50)//High chance of a regular name.
				voice = "[rand(0,1) == 1 ? pick(first_names_female) : pick(first_names_male)] [pick(last_names)]"
			if(51 to 70)//Smaller chance of a lizard name.
				voice = "[pick(lizard_name(MALE),lizard_name(FEMALE))]"
			if(71 to 80)//Small chance of a clown name.
				voice = "[pick(clown_names)]"
			if(81 to 90)//Small chance of a wizard name.
				voice = "[pick(wizard_first)] [pick(wizard_second)]"
			if(91 to 100)//Small chance of an existing crew name.
				var/list/names = list()
				for(var/mob/living/carbon/human/M in player_list)
					if(M == U || !M.client || !M.real_name)
						continue
					names.Add(M.real_name)
				voice = !names.len ? "Cuban Pete" : pick(names)
		U << "You are now mimicking <B>[voice]</B>."
	else
		U << "The voice synthesizer is [voice!="Unknown"?"now":"already"] deactivated."
		voice = "Unknown"
	return


/obj/item/clothing/mask/gas/voice/space_ninja/examine(mob/user)
	..()
	user << "Voice mimicking algorithm is set <B>[!vchange?"inactive":"active"]</B>."
