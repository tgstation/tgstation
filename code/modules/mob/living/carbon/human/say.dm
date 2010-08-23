/mob/living/carbon/human/say(var/message)
	if(src.mutantrace == "lizard")
		message = dd_replaceText(message, "s", stutter("ss"))
	..(message)

/mob/living/carbon/human/say_understands(var/other)
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	return ..()
