/mob/living/carbon/human/say(var/message)

	if (silent)
		return

	//Mimes dont speak! Changeling hivemind and emotes are allowed.
	if(miming)
		if(length(message) >= 2)
			if(mind && mind.changeling)
				if(copytext(message, 1, 2) != "*" && copytext(message, 1, 3) != ":g" && copytext(message, 1, 3) != ":G" && copytext(message, 1, 3) != ":ï")
					return
				else
					return ..(message)
			if(stat == DEAD)
				return ..(message)

		if(length(message) >= 1) //In case people forget the '*help' command, this will slow them the message and prevent people from saying one letter at a time
			if (copytext(message, 1, 2) != "*")
				return

	if(src.dna)
		/*if(src.dna.mutantrace == "lizard") //Soghun stutterss-s-ss-sss.
			if(copytext(message, 1, 2) != "*")
				message = dd_replacetext(message, "s", stutter("ss"))
*/
		if(src.dna.mutantrace == "metroid" && prob(5))
			if(copytext(message, 1, 2) != "*")
				if(copytext(message, 1, 2) == ";")
					message = ";"
				else
					message = ""
				message += "SKR"
				var/imax = rand(5,20)
				for(var/i = 0,i<imax,i++)
					message += "E"

	if(stat != DEAD)
		for(var/datum/disease/pierrot_throat/D in viruses)
			var/list/temp_message = dd_text2list(message, " ") //List each word in the message
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++) //Create a second list for excluding words down the line
				pick_list += i
			for(var/i=1, ((i <= D.stage) && (i <= temp_message.len)), i++) //Loop for each stage of the disease or until we run out of words
				if(prob(3 * D.stage)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
					var/H = pick(pick_list)
					if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
					temp_message[H] = "HONK"
					pick_list -= H //Make sure that you dont HONK the same word twice
				message = dd_list2text(temp_message, " ")

	if(istype(src.wear_mask, /obj/item/clothing/mask/luchador))
		if(copytext(message, 1, 2) != "*")
			message = dd_replacetext(message, "captain", "CAPITÁN")
			message = dd_replacetext(message, "station", "ESTACIÓN")
			message = dd_replacetext(message, "sir", "SEÑOR")
			message = dd_replacetext(message, "the ", "el ")
			message = dd_replacetext(message, "my ", "mi ")
			message = dd_replacetext(message, "is ", "es ")
			message = dd_replacetext(message, "it's", "es")
			message = dd_replacetext(message, "friend", "amigo")
			message = dd_replacetext(message, "buddy", "amigo")
			message = dd_replacetext(message, "hello", "hola")
			message = dd_replacetext(message, " hot", " caliente")
			message = dd_replacetext(message, " very ", " muy ")
			message = dd_replacetext(message, "sword", "espada")
			message = dd_replacetext(message, "library", "biblioteca")
			message = dd_replacetext(message, "traitor", "traidor")
			message = dd_replacetext(message, "wizard", "mago")
			message = uppertext(message) //Things end up looking better this way (no mixed cases), and it fits the macho wrestler image.
			if(prob(25))
				message += " OLE!"

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
			message = dd_replacetext(message, "o", "¤")
			message = dd_replacetext(message, "p", "þ")
			message = dd_replacetext(message, "l", "£")
			message = dd_replacetext(message, "s", "§")
			message = dd_replacetext(message, "u", "µ")
			message = dd_replacetext(message, "b", "ß")
			/*This text is hilarious but also absolutely retarded.
			message = dd_replacetext(message, "l", "r")
			message = dd_replacetext(message, "rr", "ru")
			message = dd_replacetext(message, "v", "b")
			message = dd_replacetext(message, "f", "hu")
			message = dd_replacetext(message, "'t", "")
			message = dd_replacetext(message, "t ", "to ")
			message = dd_replacetext(message, " I ", " ai ")
			message = dd_replacetext(message, "th", "z")
			message = dd_replacetext(message, "ish", "isu")
			message = dd_replacetext(message, "is", "izu")
			message = dd_replacetext(message, "ziz", "zis")
			message = dd_replacetext(message, "se", "su")
			message = dd_replacetext(message, "br", "bur")
			message = dd_replacetext(message, "ry", "ri")
			message = dd_replacetext(message, "you", "yuu")
			message = dd_replacetext(message, "ck", "cku")
			message = dd_replacetext(message, "eu", "uu")
			message = dd_replacetext(message, "ow", "au")
			message = dd_replacetext(message, "are", "aa")
			message = dd_replacetext(message, "ay", "ayu")
			message = dd_replacetext(message, "ea", "ii")
			message = dd_replacetext(message, "ch", "chi")
			message = dd_replacetext(message, "than", "sen")
			message = dd_replacetext(message, ".", "")
			message = lowertext(message)
			*/
	if (src.slurring)
		message = slur(message)
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

/mob/living/carbon/human/GetVoice()
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = src.wear_mask
		if(V.vchange)
			return V.voice
		else
			return name
	if(mind && mind.changeling && mind.changeling.mimicing)
		return mind.changeling.mimicing
	return real_name

