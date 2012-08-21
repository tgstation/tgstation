/mob/living/silicon/decoy/New()
	src.icon = 'icons/mob/AI.dmi'
	src.icon_state = "ai"
	src.anchored = 1
	src.canmove = 0

/mob/living/silicon/decoy/say_understands(var/other)
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/carbon/human/tajaran))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	if (istype(other, /mob/living/silicon/ai))
		return 1
	return ..()

/mob/living/silicon/decoy/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[copytext(text, 1, length(text))]\"";

	return "states, \"[text]\"";