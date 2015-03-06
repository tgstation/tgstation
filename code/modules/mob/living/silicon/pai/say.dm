/mob/living/silicon/pai/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "[src.speakQuery], \"<span class = 'robot'>[text]</span>\"";
	else if(copytext(text, length(text) - 1) == "!!")
		return "[src.speakDoubleExclamation], \"<span class = 'robot'><span class = 'yell'>[text]</span></span>\"";
	else if (ending == "!")
		return "[src.speakExclamation], \"<span class = 'robot'>[text]</span>\"";

	return "[src.speakStatement], \"<span class = 'robot'>[text]</span>\"";

/mob/living/silicon/pai/say(var/msg)
	if(silence_time)
		src << "<span class='warning'>Communication circuits remain unitialized.</span>"
	else
		..(msg)

/mob/living/silicon/pai/binarycheck()
	return 0
