/mob/living/silicon/pai/say_understands(var/other)
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	if (istype(other, /mob/living/silicon/pai))
		return 1
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/decoy))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	return ..()

/mob/living/silicon/pai/say_quote(var/text)
	var/base_text = strip_html_full(text)
	var/ending = copytext(base_text, length(base_text))
	if (ending == "?")
		return "[src.speakQuery], \"[text]\"";
	else if (ending == "!")
		return "[src.speakExclamation], \"[text]\"";

	return "[src.speakStatement], \"[text]\"";

/mob/living/silicon/pai/say(var/msg)
	if(silence_time)
		src << "<font color=green>Communication circuits remain unitialized.</font>"
	else
		..(msg)