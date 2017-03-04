/mob/living/silicon/pai/say(msg)
	if(silent)
		src << "<span class='warning'>Communication circuits remain unitialized.</span>"
	else
		..(msg)

/mob/living/silicon/pai/binarycheck()
	return 0
