/mob/living/carbon/human/mutant/lizard/say(var/message)

	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", stutter("ss"))
	..(message)

/mob/living/carbon/human/mutant/fly/say(var/message)
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "z", stutter("zz"))
	..(message)