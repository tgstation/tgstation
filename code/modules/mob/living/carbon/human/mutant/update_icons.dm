///update_base_icon_state///

/mob/living/carbon/human/mutant/update_base_icon_state()
	base_icon_state = "[racename]_[(gender == FEMALE) ? "f" : "m"]"
	icon_state = "[base_icon_state]_s"

/mob/living/carbon/human/mutant/skeleton/update_base_icon_state()
	base_icon_state = "skeleton"
	icon_state = "[base_icon_state]_s"

///update_hair///

/mob/living/carbon/human/mutant/update_hair()
	return