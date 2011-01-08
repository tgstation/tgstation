/mob/living/carbon/human/say(var/message)
	if(src.mutantrace == "lizard")
		if(copytext(message, 1, 2) != "*")
			message = dd_replaceText(message, "s", stutter("ss"))
	if(src.mutantrace == "metroid" && prob(5))
		if(copytext(message, 1, 2) != "*")
			message = "SKR"
			var/imax = rand(5,20)
			for(var/i = 0,i<imax,i++)
				message += "E"
	if(istype(src.virus, /datum/disease/pierrot_throat))
		var/list/temp_message = dd_text2list(message, " ")
		var/list/pick_list = list()
		for(var/i = 1, i <= temp_message.len, i++)
			pick_list += i
		for(var/i=1, ((i <= src.virus.stage) && (i <= temp_message.len)), i++)
			if(prob(5 * src.virus.stage))
				var/H = pick(pick_list)
				if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
				temp_message[H] = "HONK"
				pick_list -= H
			message = dd_list2text(temp_message, " ")
	..(message)

/mob/living/carbon/human/say_understands(var/other)
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/aihologram))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	return ..()