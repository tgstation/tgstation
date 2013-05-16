/mob/living/silicon/robot/say_understands(var/other)
	if (istype(other, /mob/living/silicon/ai))
		return 1
	if (istype(other, /mob/living/silicon/decoy))
		return 1
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	if (istype(other, /mob/living/silicon/pai))
		return 1
//	if (istype(other, /mob/living/silicon/hivebot))
//		return 1
	return ..()

/mob/living/silicon/robot/say_quote(var/text)
	var/base_text = strip_html_full(text)
	var/ending = copytext(base_text, length(base_text))
	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/robot/IsVocal()
	return !config.silent_borg